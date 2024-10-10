#!/bin/bash

create_product() {
  local fullName=$1
  local shortName=$2
  local contactEmail=$3

  for i in 1 2 3; do
    response=$(curl -s -X POST http://localhost:8081/db/product \
      -H "Content-Type: application/json" \
      -d "{
        \"fullName\": \"$fullName\",
        \"shortName\": \"$shortName\",
        \"contactEmail\": \"$contactEmail\"
      }")
    
    if [ -n "$response" ]; then
      product_id=$(echo $response | jq -r '.id')
      if [ "$product_id" != "null" ]; then
        echo $product_id
        return 0
      fi
    fi
    
    sleep 1
  done
  
  echo "Failed to create product" >&2
  return 1
}

report_results() {
  local product_id=$1
  local file=$2
  curl -X POST http://localhost:8081/report/results \
    -F "productId=$product_id" \
    -F "file=@$file"
}

create_integration() {
  local product_id1=$1
  local product_id2=$2

  response=$(curl -s -X POST http://localhost:8081/db/integration \
    -H "Content-Type: application/json" \
    -d "{
      \"productID1\": \"$product_id1\",
      \"productID2\": \"$product_id2\"
    }")

  if [ -n "$response" ]; then
    integration_id=$(echo $response | jq -r '.id')
    if [ "$integration_id" != "null" ]; then
      echo $integration_id
      return 0
    fi
  fi

  echo "Failed to create integration" >&2
  return 1
}

rm -rf dev-tools/junit/*
echo "Deleted contents of dev-tools/junit directory"

product_id1=$(create_product "OpenShift" "OCP" "ocp@email.com")
product_id2=$(create_product "Migration Toolkit for Containers" "MTC" "mtc@email.com")

if [ -n "$product_id1" ] && [ -n "$product_id2" ]; then
  integration_id=$(create_integration "$product_id1" "$product_id2")
  if [ -n "$integration_id" ]; then
    export INTEGRATION_ID=$integration_id
    echo "Integration ID: $INTEGRATION_ID"
    python3 dev-tools/scripts/generate-test-data.py

    junit_files=(dev-tools/junit/*.xml)
    shuffled_files=($(shuf -e "${junit_files[@]}"))

    half_length=$(( (${#shuffled_files[@]} + 1) / 2 ))
    product1_files=("${shuffled_files[@]:0:$half_length}")
    product2_files=("${shuffled_files[@]:$half_length}")

    for file in "${product1_files[@]}"; do
      report_results "$product_id1" "$file"
    done

    for file in "${product2_files[@]}"; do
      report_results "$product_id2" "$file"
    done
  fi
fi