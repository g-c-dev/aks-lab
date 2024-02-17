#!/usr/bin/env bash
set -e

if [ "$#" -lt 1 ]; then
  echo "cluster identifier required"
  exit 1
fi

cluster_identifier=$1

subscription_id=$(az account show --query "id" --output tsv)
resource_group_name="rg-terraform-state"
storage_account_name="saterraformstate$(echo -n "$subscription_id" | cut -d'-' -f1)"

echo "Ensuring terraform state storage exists for [$cluster_identifier]"

# ensure resource group
az group create --name $resource_group_name --location "westeurope" \
  --subscription $subscription_id \
  --query "id" --output tsv \
  2>/dev/null


# ensure storage account
az storage account create -n $storage_account_name -g $resource_group_name \
  --subscription $subscription_id \
  --sku "Standard_LRS" \
  --location "northeurope" \
  --min-tls-version TLS1_2 \
  --query "id" --output tsv \
  2>/dev/null

# ensure versioning
az storage account blob-service-properties update -n $storage_account_name -g $resource_group_name \
  --subscription $subscription_id \
  --enable-versioning true \
  --query "id" --output tsv \
  2>/dev/null


# ensure container
az storage container create --name $1 \
  --subscription $subscription_id \
  --account-name $storage_account_name \
  --query "id" --output tsv \
  2>/dev/null
