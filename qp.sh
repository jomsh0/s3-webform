key="[\"$1\"]"

exec < policy.json
echo -n $( jq -r ".conditions[]$key? | strings" )
