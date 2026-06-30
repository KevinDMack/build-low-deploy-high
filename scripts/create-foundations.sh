#!/usr/bin/env bash
set -euo pipefail

DEFAULT_LOCATION="${DEFAULT_LOCATION:-usgovarizona}"
LOW_RESOURCE_GROUP_NAME="${LOW_RESOURCE_GROUP_NAME:-build-low-rg}"
LOW_VNET_NAME="${LOW_VNET_NAME:-build-low-vnet}"
LOW_VNET_CIDR="${LOW_VNET_CIDR:-10.10.0.0/16}"
HIGH_RESOURCE_GROUP_NAME="${HIGH_RESOURCE_GROUP_NAME:-deploy-high-rg}"
HIGH_VNET_NAME="${HIGH_VNET_NAME:-deploy-high-vnet}"
HIGH_VNET_CIDR="${HIGH_VNET_CIDR:-10.20.0.0/16}"

az cloud set --name AzureUSGovernment >/dev/null
az account show >/dev/null

ensure_resource_group() {
  local name="$1"
  if [[ "$(az group exists --name "$name")" != "true" ]]; then
    az group create --name "$name" --location "$DEFAULT_LOCATION" >/dev/null
  fi
}

ensure_subnet() {
  local resource_group="$1"
  local vnet_name="$2"
  local subnet_name="$3"
  local subnet_prefix="$4"
  if ! az network vnet subnet show --resource-group "$resource_group" --vnet-name "$vnet_name" --name "$subnet_name" >/dev/null 2>&1; then
    az network vnet subnet create --resource-group "$resource_group" --vnet-name "$vnet_name" --name "$subnet_name" --address-prefixes "$subnet_prefix" >/dev/null
  fi
}

ensure_vnet() {
  local resource_group="$1"
  local vnet_name="$2"
  local vnet_prefix="$3"
  if ! az network vnet show --resource-group "$resource_group" --name "$vnet_name" >/dev/null 2>&1; then
    az network vnet create --resource-group "$resource_group" --name "$vnet_name" --location "$DEFAULT_LOCATION" --address-prefixes "$vnet_prefix" >/dev/null
  fi
}

configure_low_environment() {
  ensure_resource_group "$LOW_RESOURCE_GROUP_NAME"
  ensure_vnet "$LOW_RESOURCE_GROUP_NAME" "$LOW_VNET_NAME" "$LOW_VNET_CIDR"
  ensure_subnet "$LOW_RESOURCE_GROUP_NAME" "$LOW_VNET_NAME" vm 10.10.1.0/24
  ensure_subnet "$LOW_RESOURCE_GROUP_NAME" "$LOW_VNET_NAME" aoai 10.10.2.0/24
  ensure_subnet "$LOW_RESOURCE_GROUP_NAME" "$LOW_VNET_NAME" acr 10.10.3.0/24
  ensure_subnet "$LOW_RESOURCE_GROUP_NAME" "$LOW_VNET_NAME" storage 10.10.4.0/24
  ensure_subnet "$LOW_RESOURCE_GROUP_NAME" "$LOW_VNET_NAME" AzureBastionSubnet 10.10.5.0/24
  az network vnet subnet update --resource-group "$LOW_RESOURCE_GROUP_NAME" --vnet-name "$LOW_VNET_NAME" --name aoai --disable-private-endpoint-network-policies true >/dev/null
  az network vnet subnet update --resource-group "$LOW_RESOURCE_GROUP_NAME" --vnet-name "$LOW_VNET_NAME" --name acr --disable-private-endpoint-network-policies true >/dev/null
  az network vnet subnet update --resource-group "$LOW_RESOURCE_GROUP_NAME" --vnet-name "$LOW_VNET_NAME" --name storage --disable-private-endpoint-network-policies true >/dev/null
}

configure_high_environment() {
  ensure_resource_group "$HIGH_RESOURCE_GROUP_NAME"
  ensure_vnet "$HIGH_RESOURCE_GROUP_NAME" "$HIGH_VNET_NAME" "$HIGH_VNET_CIDR"
  ensure_subnet "$HIGH_RESOURCE_GROUP_NAME" "$HIGH_VNET_NAME" aoai 10.20.2.0/24
  ensure_subnet "$HIGH_RESOURCE_GROUP_NAME" "$HIGH_VNET_NAME" acr 10.20.3.0/24
  ensure_subnet "$HIGH_RESOURCE_GROUP_NAME" "$HIGH_VNET_NAME" storage 10.20.4.0/24
  ensure_subnet "$HIGH_RESOURCE_GROUP_NAME" "$HIGH_VNET_NAME" AzureBastionSubnet 10.20.5.0/24
  az network vnet subnet update --resource-group "$HIGH_RESOURCE_GROUP_NAME" --vnet-name "$HIGH_VNET_NAME" --name aoai --disable-private-endpoint-network-policies true >/dev/null
  az network vnet subnet update --resource-group "$HIGH_RESOURCE_GROUP_NAME" --vnet-name "$HIGH_VNET_NAME" --name acr --disable-private-endpoint-network-policies true >/dev/null
  az network vnet subnet update --resource-group "$HIGH_RESOURCE_GROUP_NAME" --vnet-name "$HIGH_VNET_NAME" --name storage --disable-private-endpoint-network-policies true >/dev/null
}

configure_low_environment
configure_high_environment

echo "Azure Government network foundations are ready in ${DEFAULT_LOCATION}."
