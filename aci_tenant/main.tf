

#  Define data sources

data "mso_site" "aws_site" {
  name = var.aws_site_name
}


data "mso_user" "admin" {
  username = "admin"
}

data "mso_user" "user1" {
  username = var.user_association
}


#  Define your terraform script here   put in file main.tf

## create the tenant

resource "mso_tenant" "tenant" {
  name         = var.tenant_stuff.tenant_name
  display_name = var.tenant_stuff.display_name
  description  = var.tenant_stuff.description
  site_associations {
    site_id           = data.mso_site.aws_site.id
    vendor            = "aws"
    aws_account_id    = var.awsstuff.aws_account_id
    aws_access_key_id = var.awsstuff.aws_access_key_id
    aws_secret_key    = var.awsstuff.aws_secret_key
  }
  user_associations { user_id = data.mso_user.admin.id }
  user_associations { user_id = data.mso_user.user1.id }
}

## create schema

resource "mso_schema" "schema1" {
  name          = var.schema_name
  template_name = var.template_name
  tenant_id     = mso_tenant.tenant.id
}

## Associate Schema / template with Site

resource "mso_schema_site" "aws_site" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema.schema1.template_name
}

## Create VRF

resource "mso_schema_template_vrf" "vrf1" {
  schema_id        = mso_schema.schema1.id
  template         = mso_schema.schema1.template_name
  name             = var.vrf_name
  display_name     = var.vrf_name
  layer3_multicast = false
  vzany            = false
}

resource "mso_schema_site_vrf" "aws_site" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
  vrf_name      = mso_schema_template_vrf.vrf1.name
}



## associate with Region and zones in Site Local Templates
resource "mso_schema_site_vrf_region" "vrfRegion" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.aws_site.template_name
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_site_vrf.aws_site.vrf_name
  region_name        = var.region_name
  vpn_gateway        = false
  hub_network_enable = true
  hub_network = {
    name        = var.tgw_name
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.cidr_ip
    primary = true

    subnet {
      ip    = var.subnet1
      zone  = var.zone1
      usage = "gateway"
    }

    subnet {
      ip    = var.subnet2
      zone  = var.zone2
      usage = "gateway"
    }

    subnet {
      ip   = var.subnet3
      zone = var.zone3
      #usage = "not_used_since_each_zone_can_have_1_TGW_gateway"
    }

  }
}

## create ANP

resource "mso_schema_template_anp" "anp1" {
  schema_id    = mso_schema.schema1.id
  template     = mso_schema.schema1.template_name
  name         = var.anp_name
  display_name = var.anp_name
}


resource "mso_schema_site_anp" "anp1" {
  schema_id     = mso_schema.schema1.id
  anp_name      = mso_schema_template_anp.anp1.name
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
}

## create EPG

resource "mso_schema_template_anp_epg" "anp_epg" {
  schema_id                  = mso_schema.schema1.id
  template_name              = mso_schema.schema1.template_name
  anp_name                   = mso_schema_template_anp.anp1.name
  name                       = var.epg_name
  bd_name                    = var.bd_name
  vrf_name                   = mso_schema_template_vrf.vrf1.name
  display_name               = var.epg_name
  useg_epg                   = false
  intra_epg                  = "unenforced"
  intersite_multicast_source = false
  preferred_group            = false
}

resource "mso_schema_site_anp_epg" "site_anp_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
  anp_name      = mso_schema_site_anp.anp1.anp_name
  epg_name      = mso_schema_template_anp_epg.anp_epg.name
}

### define epg selector

resource "mso_schema_site_anp_epg_selector" "epgSel1" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema_site.aws_site.template_name
  anp_name      = mso_schema_site_anp_epg.site_anp_epg.anp_name
  epg_name      = mso_schema_site_anp_epg.site_anp_epg.epg_name
  name          = "epgSel1"
  expressions {
    key      = "ipAddress"
    operator = "equals"
    value    = var.epg_selector_value
  }
}

## create extEPG
resource "mso_schema_template_external_epg" "template_externalepg" {
  schema_id         = mso_schema_site_anp_epg_selector.epgSel1.schema_id     #mso_schema.schema1.id
  template_name     = mso_schema_site_anp_epg_selector.epgSel1.template_name #mso_schema.schema1.template_name
  external_epg_name = "extEPG1"
  external_epg_type = "cloud"
  display_name      = "extEPG1"
  vrf_name          = mso_schema_template_vrf.vrf1.name
  anp_name          = mso_schema_template_anp.anp1.name
  selector_name     = "extEPGsel1"
  selector_ip       = "0.0.0.0/0"
}

resource "mso_schema_site_external_epg" "site_externalepg" {
  schema_id         = mso_schema_template_external_epg.template_externalepg.schema_id
  template_name     = mso_schema_template_external_epg.template_externalepg.template_name
  site_id           = mso_schema_site.aws_site.site_id
  external_epg_name = mso_schema_template_external_epg.template_externalepg.external_epg_name
}

# Create Filters and Contracts

## create Filter
resource "mso_schema_template_filter_entry" "filter_entry" {
  schema_id          = mso_schema_site_external_epg.site_externalepg.schema_id     #mso_schema.schema1.id
  template_name      = mso_schema_site_external_epg.site_externalepg.template_name #mso_schema.schema1.template_name
  name               = "Any"
  display_name       = "Any"
  entry_name         = "Any"
  entry_display_name = "Any"
  destination_from   = "unspecified"
  destination_to     = "unspecified"
  source_from        = "unspecified"
  source_to          = "unspecified"
  arp_flag           = "unspecified"
}


## Create Contract
resource "mso_schema_template_contract" "template_contract" {
  schema_id     = mso_schema_template_filter_entry.filter_entry.schema_id
  template_name = mso_schema_template_filter_entry.filter_entry.template_name
  contract_name = try("C1")
  display_name  = try("C1")
  scope         = "context"
  directives    = ["none"]
}

### Associate filter with Contract
resource "mso_schema_template_contract_filter" "Any" {
  schema_id     = mso_schema_template_contract.template_contract.schema_id
  template_name = mso_schema_template_contract.template_contract.template_name
  contract_name = mso_schema_template_contract.template_contract.contract_name # "C1"
  filter_type   = "bothWay"
  filter_name   = mso_schema_template_filter_entry.filter_entry.name
  directives    = ["none", "log"]
}

#### add Contract Provider and Consumer to EPg
resource "mso_schema_template_anp_epg_contract" "c1_epg_provider" {
  schema_id         = mso_schema_template_contract_filter.Any.schema_id
  template_name     = mso_schema_template_contract_filter.Any.template_name
  anp_name          = mso_schema_site_anp_epg.site_anp_epg.anp_name
  epg_name          = mso_schema_site_anp_epg.site_anp_epg.epg_name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "provider"

}


resource "mso_schema_template_anp_epg_contract" "c1_epg_consumer" {
  schema_id         = mso_schema_template_anp_epg_contract.c1_epg_provider.schema_id
  template_name     = mso_schema_template_anp_epg_contract.c1_epg_provider.template_name
  anp_name          = mso_schema_template_anp_epg_contract.c1_epg_provider.anp_name
  epg_name          = mso_schema_template_anp_epg_contract.c1_epg_provider.epg_name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "consumer"

}

#### Add Provider and Consumer to extEPGs
resource "mso_schema_template_external_epg_contract" "c1_ext_epg_provider" {
  schema_id         = mso_schema_template_anp_epg_contract.c1_epg_consumer.schema_id
  template_name     = mso_schema_template_anp_epg_contract.c1_epg_consumer.template_name
  external_epg_name = mso_schema_template_external_epg.template_externalepg.external_epg_name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "provider"

}

resource "mso_schema_template_external_epg_contract" "c1_ext_epg_consumer" {
  schema_id         = mso_schema_template_external_epg_contract.c1_ext_epg_provider.schema_id
  template_name     = mso_schema_template_external_epg_contract.c1_ext_epg_provider.template_name
  external_epg_name = mso_schema_template_external_epg.template_externalepg.external_epg_name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "consumer"

}

### Deploy Template:
resource "mso_schema_template_deploy" "template_deployer" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema.schema1.template_name
  depends_on = [
    mso_tenant.tenant,
    mso_schema.schema1,
    mso_schema_site.aws_site,
    mso_schema_template_vrf.vrf1,
    mso_schema_site_vrf.aws_site,
    mso_schema_site_vrf_region.vrfRegion,
    mso_schema_template_anp.anp1,
    mso_schema_template_anp_epg.anp_epg,
    mso_schema_site_anp_epg.site_anp_epg,
    mso_schema_site_anp_epg_selector.epgSel1,
    mso_schema_template_external_epg.template_externalepg,
    mso_schema_site_external_epg.site_externalepg,
    mso_schema_template_filter_entry.filter_entry,
    mso_schema_template_contract.template_contract,
    mso_schema_template_contract_filter.Any,
    mso_schema_template_anp_epg_contract.c1_epg_provider,
    mso_schema_template_anp_epg_contract.c1_epg_consumer,
    mso_schema_template_external_epg_contract.c1_ext_epg_provider,
    mso_schema_template_external_epg_contract.c1_ext_epg_consumer

  ]
  #undeploy = true
}

