#!/bin/bash

set -e

REGION="ap-northeast-1"
PROFILE="hsu-programmatic-role"

ALB_NAME="dashboard-alb"
TG_V1_NAME="dashboard-tg"
TG_V2_NAME="dashboard-new-tg"

URL="https://dashboard.hsu-team8.io"

REQUESTS=${1:-1000}

echo "=============================================="
echo "       ALB Weighted Routing Test"
echo "=============================================="
echo

# ------------------------------------------------
# Find ALB ARN
# ------------------------------------------------

echo "Finding ALB..."

ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names "$ALB_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

if [[ -z "$ALB_ARN" || "$ALB_ARN" == "None" ]]; then
  echo "ERROR: Could not find ALB: $ALB_NAME"
  exit 1
fi

# CloudWatch ALB dimension:
# app/dashboard-alb/xxxxxxxx

ALB_DIMENSION=${ALB_ARN#*loadbalancer/}

echo "ALB found:"
echo "$ALB_ARN"
echo

# ------------------------------------------------
# Find target group ARNs
# ------------------------------------------------

echo "Finding target groups..."

TG_V1_ARN=$(aws elbv2 describe-target-groups \
  --names "$TG_V1_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

TG_V2_ARN=$(aws elbv2 describe-target-groups \
  --names "$TG_V2_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

if [[ "$TG_V1_ARN" == "None" || -z "$TG_V1_ARN" ]]; then
  echo "ERROR: Could not find $TG_V1_NAME"
  exit 1
fi

if [[ "$TG_V2_ARN" == "None" || -z "$TG_V2_ARN" ]]; then
  echo "ERROR: Could not find $TG_V2_NAME"
  exit 1
fi

# Convert ARN:
# arn:aws:elasticloadbalancing:...:targetgroup/dashboard-tg/xxx
#
# to:
# targetgroup/dashboard-tg/xxx

TG_V1_DIMENSION=${TG_V1_ARN#*targetgroup/}
TG_V1_DIMENSION="targetgroup/$TG_V1_DIMENSION"

TG_V2_DIMENSION=${TG_V2_ARN#*targetgroup/}
TG_V2_DIMENSION="targetgroup/$TG_V2_DIMENSION"

echo "V1: $TG_V1_NAME"
echo "V2: $TG_V2_NAME"
echo

# ------------------------------------------------
# Read configured listener weights
# ------------------------------------------------

echo "Reading configured ALB weights..."

LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn "$ALB_ARN" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'Listeners[?Port==`443`].ListenerArn | [0]' \
  --output text)

if [[ -z "$LISTENER_ARN" || "$LISTENER_ARN" == "None" ]]; then
  echo "ERROR: HTTPS 443 listener not found."
  exit 1
fi

V1_WEIGHT=$(aws elbv2 describe-listeners \
  --listener-arns "$LISTENER_ARN" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "Listeners[0].DefaultActions[0].ForwardConfig.TargetGroups[?TargetGroupArn=='$TG_V1_ARN'].Weight | [0]" \
  --output text)

V2_WEIGHT=$(aws elbv2 describe-listeners \
  --listener-arns "$LISTENER_ARN" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "Listeners[0].DefaultActions[0].ForwardConfig.TargetGroups[?TargetGroupArn=='$TG_V2_ARN'].Weight | [0]" \
  --output text)

echo
echo "Configured weights:"
echo "  OLD $TG_V1_NAME : $V1_WEIGHT"
echo "  NEW $TG_V2_NAME : $V2_WEIGHT"
echo

TOTAL_WEIGHT=$((V1_WEIGHT + V2_WEIGHT))

V1_EXPECTED=$(awk "BEGIN {printf \"%.1f\", ($V1_WEIGHT/$TOTAL_WEIGHT)*100}")
V2_EXPECTED=$(awk "BEGIN {printf \"%.1f\", ($V2_WEIGHT/$TOTAL_WEIGHT)*100}")

echo "Expected:"
echo "  OLD: ${V1_EXPECTED}%"
echo "  NEW: ${V2_EXPECTED}%"
echo

# ------------------------------------------------
# Record start time
# ------------------------------------------------

START_TIME=$(date -u -v-1M '+%Y-%m-%dT%H:%M:%SZ')

echo "Sending $REQUESTS requests to:"
echo "$URL"
echo

# ------------------------------------------------
# Send requests
# ------------------------------------------------

SUCCESS=0
FAILED=0

for ((i=1; i<=REQUESTS; i++)); do

  STATUS=$(curl -sk \
    -o /dev/null \
    -w "%{http_code}" \
    "$URL/")

  if [[ "$STATUS" =~ ^2 ]]; then
    ((SUCCESS++)) || true
  else
    ((FAILED++)) || true
  fi

  if (( i % 100 == 0 || i == REQUESTS )); then
    printf "\rRequests: %d / %d" "$i" "$REQUESTS"
  fi

done

echo
echo
echo "Finished."
echo "HTTP success: $SUCCESS"
echo "HTTP failed : $FAILED"

END_TIME=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

echo
echo "Waiting 120 seconds for CloudWatch metrics..."
sleep 120

# ------------------------------------------------
# Read CloudWatch Target 2XX count
# ------------------------------------------------

echo
echo "Reading CloudWatch..."

V1=$(aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_2XX_Count \
  --dimensions \
    Name=LoadBalancer,Value="$ALB_DIMENSION" \
    Name=TargetGroup,Value="$TG_V1_DIMENSION" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 60 \
  --statistics Sum \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'sum(Datapoints[].Sum)' \
  --output text)

V2=$(aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_2XX_Count \
  --dimensions \
    Name=LoadBalancer,Value="$ALB_DIMENSION" \
    Name=TargetGroup,Value="$TG_V2_DIMENSION" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 60 \
  --statistics Sum \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'sum(Datapoints[].Sum)' \
  --output text)

# CloudWatch may return None
if [[ -z "$V1" || "$V1" == "None" ]]; then
  V1=0
fi

if [[ -z "$V2" || "$V2" == "None" ]]; then
  V2=0
fi

TOTAL=$(awk "BEGIN {print $V1 + $V2}")

if awk "BEGIN {exit !($TOTAL > 0)}"; then

  V1_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($V1/$TOTAL)*100}")
  V2_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($V2/$TOTAL)*100}")

else

  V1_PERCENT="0.0"
  V2_PERCENT="0.0"

fi

# ------------------------------------------------
# Results
# ------------------------------------------------

echo
echo "=============================================="
echo "                 RESULT"
echo "=============================================="
echo

printf "%-25s %12s %12s\n" \
  "Target Group" \
  "Requests" \
  "Actual"

printf "%-25s %12s %12s\n" \
  "------------------------" \
  "------------" \
  "------------"

printf "%-25s %12.0f %11s%%\n" \
  "$TG_V1_NAME" \
  "$V1" \
  "$V1_PERCENT"

printf "%-25s %12.0f %11s%%\n" \
  "$TG_V2_NAME" \
  "$V2" \
  "$V2_PERCENT"

printf "%-25s %12.0f %11s%%\n" \
  "TOTAL" \
  "$TOTAL" \
  "100.0"

echo
echo "Expected:"
echo "  OLD ${TG_V1_NAME}: ${V1_EXPECTED}%"
echo "  NEW ${TG_V2_NAME}: ${V2_EXPECTED}%"

echo
echo "Actual:"
echo "  OLD ${TG_V1_NAME}: ${V1_PERCENT}%"
echo "  NEW ${TG_V2_NAME}: ${V2_PERCENT}%"
echo
