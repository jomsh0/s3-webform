set -e

export AWS_PROFILE=poster

secret=$( aws configure get aws_secret_access_key )
region=$( aws configure get region )
date=$( ./qp.sh x-amz-date < policy.json )
date=${date%%T*}
service=s3
end=aws4_request

hmac() {
    local nm=${2:-hexkey}
    openssl dgst -sha256 -mac HMAC -macopt "$nm:$1" | \
        ( read -d' ' && cat )
        #( read _ sig; echo -n $sig )
}

key="AWS4$secret"
key=$( echo -n "$date" | hmac "$key" key )

for txt in "$region" "$service" "$end"; do
    key=$( echo -n "$txt" | hmac "$key" )
done

echo -n $(base64 -w0 < policy.json | hmac "$key")
