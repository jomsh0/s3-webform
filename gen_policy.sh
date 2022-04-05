set -e

TODAY_d=$(date -u -I)
MONTH_s=$((60 * 60 * 24 * 30))
EXP_s=$(( $(date +%s) + $MONTH_s ))
EXP_d=$(date -u -I --date=@$EXP_s)

MIDNIGHT=T00:00:00Z
SIZE_LIM=$((100 * 1024 * 1024)) # 100 MiB

EXP="${EXP_d}${MIDNIGHT}"
DATE_short=${TODAY_d//-}
DATE_long="${DATE_short}${MIDNIGHT//:}"

export AWS_PROFILE=poster

ACCESS_KEY=$(aws configure get aws_access_key_id)
REGION=$(aws configure get region)
BUCKET=j-kqz

cat <<EOF
{ "expiration": "$EXP",
    "conditions": [
        { "bucket": "$BUCKET" },
        { "x-amz-algorithm": "AWS4-HMAC-SHA256" },
        { "x-amz-credential": "$ACCESS_KEY/$DATE_short/$REGION/s3/aws4_request" },
        { "x-amz-date": "$DATE_long" },
        [ "starts-with", "\$key", "" ],
        [ "content-length-range", 0, $SIZE_LIM ]
    ]
}
EOF

