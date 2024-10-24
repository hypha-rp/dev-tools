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

# Create first product
product_id1=$(create_product "Product One" "P1" "contact1@example.com")
if [ $? -ne 0 ]; then
  echo "Failed to create the first product"
  exit 1
fi

# Create second product
product_id2=$(create_product "Product Two" "P2" "contact2@example.com")
if [ $? -ne 0 ]; then
  echo "Failed to create the second product"
  exit 1
fi

echo "Created products with IDs: $product_id1, $product_id2"