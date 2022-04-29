set -eu -o pipefail

export AWS_PROFILE=poster
POLICY=policy.json

query() {
    key="[\"$1\"]"

    echo -n $( jq -r ".conditions[]$key? | strings" < $POLICY)
}

# also hmac256 from libgcrypt
# step crypto auth digest
hmac() {
    local nm=${2:-hexkey}
    openssl dgst -sha256 -mac HMAC -macopt "$nm:$1" | \
        ( read -d' ' && cat )
        #( read _ sig; echo -n $sig )
}

sign() {
    local secret region date key txt

    secret=$( aws configure get aws_secret_access_key )
    region=$( aws configure get region )

    date=$( $0 query x-amz-date )
    date=${date%%T*}

    key=AWS4$secret
    key=$( echo -n $date | hmac $key key )

    for txt in $region s3 aws4_request; do
        key=$( echo -n $txt | hmac $key )
    done

    echo -n $(base64 -w0 < $POLICY | hmac $key)
}

gen() {
    local TODAY_d MONTH_s exp_s exp_d exp midnight DATE_short DATE_long
    local size_lim access_key region bucket

    midnight=T00:00:00Z
    TODAY_d=$(date -u -I)
    MONTH_s=$((60 * 60 * 24 * 30))
    DATE_short=${TODAY_d//-}
    DATE_long="${DATE_short}${midnight//:}"

    exp_s=$(( $(date +%s) + MONTH_s ))
    exp_d=$(date -u -I --date=@$exp_s)
    exp="${exp_d}${midnight}"

    size_lim=$((100 * 1024 * 1024)) # 100 MiB
    access_key=$(aws configure get aws_access_key_id)
    region=$(aws configure get region)
    bucket=j-kqz

    cat >$POLICY <<EOF
{ "expiration": "$exp",
    "conditions": [
        { "bucket": "$bucket" },
        { "x-amz-algorithm": "AWS4-HMAC-SHA256" },
        { "x-amz-credential": "$access_key/$DATE_short/$region/s3/aws4_request" },
        { "x-amz-date": "$DATE_long" },
        [ "starts-with", "\$key", "" ],
        [ "content-length-range", 0, $size_lim ]
    ]
}
EOF
}

case "${1:-}" in
    gen) shift; gen "$@"   ;;
  query) shift; query "$@" ;;
   sign) shift; sign "$@"  ;;
      *) exit 1            ;;
esac
