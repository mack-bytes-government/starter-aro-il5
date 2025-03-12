param aro_cluster_name string
param location string = resourceGroup().location
param subnet_id string

@secure()
param rehat_pull_secret string

param cluster_sku string = 'Standard'
param control_plane_vm_size string = 'Standard_D8s_v3'
param pool_cluster_size string = 'Standard_D4s_v3'
param pool_cluster_disk_size int = 128
param pool_cluster_count int = 3

param service_principal_client_id string
@secure()
param service_principal_client_secret string

param pod_cidr string = '10.0.1.0/24'
param service_cidr string = '10.0.1.0/24'
param dns_service_ip string = '10.0.1.10'

param api_server_visibility string = 'Public'

param ingress_server_visibility string = 'Public'

param cluster_domain string = ''

// Tag Configuration:
param default_tag_name string
param default_tag_value string

resource cluster 'Microsoft.RedHatOpenShift/OpenShiftClusters@2020-04-30' = {
  name: aro_cluster_name
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    clusterProfile: {
      domain: cluster_domain
      pullSecret: rehat_pull_secret
    }
    networkProfile: {
      podCidr: pod_cidr
      serviceCidr: service_cidr
      dnsServiceIp: dns_service_ip
    }
    servicePrincipalProfile: {
      clientId: service_principal_client_id
      clientSecret: service_principal_client_secret
    }
    masterProfile: {
      vmSize: control_plane_vm_size
      subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', clusterVnetName, 'master')
    }
    workerProfiles: [
      {
        name: 'worker'
        vmSize: pool_cluster_size
        diskSizeGB: pool_cluster_disk_size
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', clusterVnetName, 'worker')
        count: pool_cluster_count
      }
    ]
    apiserverProfile: {
      visibility: api_server_visibility
    }
    ingressProfiles: [
      {
        name: 'default'
        visibility: ingress_server_visibility
      }
    ]
  }
}

output aroId string = cluster.id
