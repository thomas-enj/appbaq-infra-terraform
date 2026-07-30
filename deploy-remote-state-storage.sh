export OWNER="thomas-enjalbert"
export RG_BACKEND="tenjalbertRG"
export SA_BACKEND="ststate${OWNER//-/}"
export LOCATION="francecentral"
export CONTAINER_BACKEND="tfstate-appbaq"

az group create --name "$RG_BACKEND" --location "$LOCATION"

az storage account create \
  --name           "$SA_BACKEND" \
  --resource-group "$RG_BACKEND" \
  --location       "$LOCATION" \
  --sku            Standard_LRS

sleep 15

az storage container create \
  --name         "$CONTAINER_BACKEND" \
  --account-name "$SA_BACKEND"

az storage blob list \
  --container-name "$CONTAINER_BACKEND" \
  --account-name   "$SA_BACKEND" \
  --output         table

sleep 15

cd terraform

terraform init \
  -backend-config="resource_group_name=${RG_BACKEND}" \
  -backend-config="storage_account_name=${SA_BACKEND}" \
  -backend-config="container_name=$CONTAINER_BACKEND" \
  -backend-config="key=${OWNER}.terraform.tfstate" \
  -migrate-state