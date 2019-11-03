# Overview
These tests focuses on performing configuration verification. These tests typically focus on individual components of the configuration, so a typical test suite would consist of test from different configuration categories

## anyDomP.robot
### Template Description:
Verifies Physical, External Bridged, External Routed, and VMware VMM domain configuration including VLAN pool association.

> The configuration of the VLAN pool itself are not verified by this template.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
type | Domain type | True |   | DAFE Excel Sheet
name | Domain Name | True |   | DAFE Excel Sheet
vlan_pool | Associated VLAN Pool Name | True |   | DAFE Excel Sheet


### Template Body:
```
{% if config['type'] == 'physical' %} 
Verify ACI Physical Domain Configuration - Domain {{config['name']}}, VLAN Pool {{config['vlan_pool']}}
    [Documentation]   Verifies that Physical Domain '{{config['name']}}' are configured with the expected parameters:
	...  - Domain Name: {{config['name']}}
	...  - Associated VLAN Pool: {{config['vlan_pool']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/phys-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].physDomP.attributes.name}   {{config['name']}}   Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].physDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool '{{config['vlan_pool']}}' not associated with domain
{% elif config['type'] == 'external_l3' %}
Verify ACI L3 External Domain Configuration - Domain {{config['name']}}, VLAN Pool {{config['vlan_pool']}}
    [Documentation]   Verifies that L3 External Domain '{{config['name']}}' are configured with the expected parameters
	...  - Domain Name: {{config['name']}}
	...  - Associated VLAN Pool: {{config['vlan_pool']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/l3dom-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings		${return.payload[0].l3extDomP.attributes.name}   {{config['name']}}     Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].l3extDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool '{{config['vlan_pool']}}' not associated with domain
{% elif config['type'] == 'external_l2' %}
Verify ACI L2 External Domain Configuration - Domain {{config['name']}}, VLAN Pool {{config['vlan_pool']}}
    [Documentation]   Verifies that L2 External Domain '{{config['name']}}' are configured with the expected parameters
	...  - Domain Name: {{config['name']}}
	...  - Associated VLAN Pool: {{config['vlan_pool']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/l2dom-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].l2extDomP.attributes.name}   {{config['name']}}  Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].l2extDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool '{{config['vlan_pool']}}' not associated with domain
{% elif config['type'] == 'vmm_vmware' %}
Verify ACI VMware VMM Domain VLAN Pool Configuration - Domain {{config['name']}}, VLAN Pool {{config['vlan_pool']}}
    [Documentation]   Verifies that VMware VMM Domain '{{config['name']}}' are configured with the expected parameters
	...  - Domain Name: {{config['name']}}
	...  - Associated VLAN Pool: {{config['vlan_pool']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].vmmDomP.attributes.name}   {{config['name']}}  Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].vmmDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[{{config['vlan_pool']}}]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool '{{config['vlan_pool']}}' not associated with domain
{% endif %}


```
### Template Data Validation Model:
```json
{'name': {'descr': 'Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'type': {'descr': 'Domain type',
          'enum': ['physical', 'external_l3', 'external_l2', 'vmm_vmware'],
          'mandatory': True,
          'source': 'workbook'},
 'vlan_pool': {'descr': 'Associated VLAN Pool Name',
               'length': [1, 64],
               'mandatory': True,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'}}
```
## bgpInstP.robot
### Template Description:
Verifies the Fabric BGP AS number and route reflector configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
bgp_rr_node_id | BGP Route Reflector Node id | True | None | DAFE Excel Sheet
pod_id | BGP Route Reflector POD id | True | None | DAFE Excel Sheet
fabric_bgp_as | Fabric BGP AS Number | True | None | DAFE Excel Sheet


### Template Body:
```
Verify ACI Fabric BGP Configuration - Route Reflector Node '{{config['bgp_rr_node_id']}}'
    [Documentation]   Verifies that ACI Fabric BGP Configuration are configured with the expected parameters
    ...  - Policy Name: default
    ...  - BGP AS Number: {{config['fabric_bgp_as']}}
    ...  - BGP Route Reflector POD ID: {{config['pod_id']}}
    ...  - BGP Route Reflector Node: {{config['bgp_rr_node_id']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-bgp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/bgpInstP-default/as
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers		${return.payload[0].bgpAsP.attributes.asn}   {{config['fabric_bgp_as']}}    BGP AS Number not matching expected configuration               values=False
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/bgpInstP-default/rr/node-{{config['bgp_rr_node_id']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP RR)		values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		                                                Node not defined as Fabric BGP Route Refelector		            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.payload[0].bgpRRNodePEp.attributes.podId}  {{config['pod_id']}}		        POD ID for Node not matching expected configuration		        values=False


```
### Template Data Validation Model:
```json
{'bgp_rr_node_id': {'default': 'None',
                    'descr': 'BGP Route Reflector Node id',
                    'mandatory': True,
                    'range': [101, 4000],
                    'source': 'workbook',
                    'type': 'int'},
 'fabric_bgp_as': {'default': 'None',
                   'descr': 'Fabric BGP AS Number',
                   'mandatory': True,
                   'range': [1, 65535],
                   'source': 'workbook',
                   'type': 'int'},
 'pod_id': {'default': 'None',
            'descr': 'BGP Route Reflector POD id',
            'mandatory': True,
            'range': [1, 10],
            'source': 'workbook',
            'type': 'int'}}
```
## bgpPeerP.robot
### Template Description:
Verifies L3 Node Level BGP Peer configuration

If not specified:
* BGP Control knobs 'send community' and 'send extended community' assumed to be configured as enabled
* Local BGP AS Configuration assumed to be configued as replace-as


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
control | BGP Controls | False | send-com,send-ext-com | DAFE Excel Sheet
bgp_peer_ip | BGP Peer IP Address | True |   | DAFE Excel Sheet
local_bgp_as | Local BGP AS Number | False | None |  
l3out_node_profile | L3Out Node Profile Name | True |   | DAFE Excel Sheet
isGolfPeer | Boolean Define if BGP Peer is used for GOLF/L3EVPN (fabricExtControl Peering) | False | no | DAFE Excel Sheet
l3out | Parent L3 Out Name | True |   | DAFE Excel Sheet
bgp_peer_name | L3Out Node Profile Description | False |   | DAFE Excel Sheet
remote_bgp_as | Remote BGP AS Number | True | None |  
ttl | BGP Multihop TTL | True |   |  
local_bgp_as_config | Local BGP AS Configuration | False | asnPropagate | DAFE Excel Sheet
tenant | Parent tenant name | True |   | DAFE Excel Sheet


### Template Body:
```
{% if 'bgp_peer_name' not in config %}
  {% set x=config.__setitem__('bgp_peer_name', '') %}
{% endif %}
{% if 'isGolfPeer' not in config %}
  {% set x=config.__setitem__('isGolfPeer', 'no') %}
{% elif config['isGolfPeer'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('isGolfPeer', 'no') %}
{% endif %}
{% if 'control' not in config %}
  {% set x=config.__setitem__('control', 'send-com,send-ext-com') %}
{% endif %}
{% if 'local_bgp_as' not in config %}
  {% set x=config.__setitem__('local_bgp_as', '') %}
{% endif %}
{% if 'local_bgp_as_config' not in config %}
  {% set x=config.__setitem__('local_bgp_as_config', 'replace-as') %}
{% endif %}
Verify ACI L3Out Node Level BGP Peer Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['l3out_node_profile']}}, Peer {{config['bgp_peer_ip']}}
    [Documentation]   Verifies that ACI L3Out Node Level BGP Peer '{{config['bgp_peer_ip']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}', Node Profile '{{config['l3out_node_profile']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - BGP Peer: {{config['bgp_peer_ip']}}
    {% if config['bgp_peer_name'] != "" %}
    ...  - Description: {{config['bgp_peer_name']}}
    {% endif %}
    ...  - Local BGP AS Number: {{config['local_bgp_as']}}
    ...  - Local AS Configuration: {{config['local_bgp_as_config']}}
    ...  - Remote BGP AS Number: {{config['remote_bgp_as']}}
    ...  - BGP Multihop TTL: {{config['ttl']}}
    ...  - BGP Controls: {{config['control']}}
    ...  - Golf / L3EVPN BGP Peer: {{config['isGolfPeer']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    {% if config['tenant'] == "infra" and config['isGolfPeer'] == "yes" %}
    # GOLF BGP Peer
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/infraPeerP--[{{config['bgp_peer_ip']}}]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Level BGP Peer does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.addr}"   "{{config['bgp_peer_ip']}}"    Failure retreiving configuration    values=False
    {% if config['bgp_peer_name'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.descr}"  "{{config['bgp_peer_name']}}"               Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.ttl}"  "{{config['ttl']}}"                           TTL not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.ctrl}"  "{{config['control']}}"                      BGP Controls not matching expected configuration                 values=False
    # Remote AS
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/infraPeerP-[{{config['bgp_peer_ip']}}]/as
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpAsP.attributes.asn}"  "{{config['remote_bgp_as']}}"                        Remote BGP AS not matching expected configuration                 values=False
    {% else %}
    # Regular BGP Peer (none-GOLF)
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Level BGP Peer does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.addr}"   "{{config['bgp_peer_ip']}}"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.descr}"  "{{config['bgp_peer_name']}}"                    Description not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.ttl}"  "{{config['ttl']}}"                                TTL not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.ctrl}"  "{{config['control']}}"                           BGP Controls not matching expected configuration                 values=False
    # Remote AS
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]/as
	  ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpAsP.attributes.asn}"  "{{config['remote_bgp_as']}}"                        Remote BGP AS not matching expected configuration                 values=False
    {% if config['local_bgp_as'] != "" %}
    # Local AS
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]/localasn
	  ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpLocalAsnP.attributes.localAsn}"  "{{config['local_bgp_as']}}"                    Local BGP AS not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpLocalAsnP.attributes.asnPropagate}"  "{{config['local_bgp_as_config']}}"         Local BGP AS Configuration not matching expected configuration                 values=False
    {% endif %}
    {% endif %}


```
### Template Data Validation Model:
```json
{'bgp_peer_ip': {'descr': 'BGP Peer IP Address',
                 'mandatory': True,
                 'source': 'workbook',
                 'type': 'str'},
 'bgp_peer_name': {'descr': 'L3Out Node Profile Description',
                   'length': [1, 64],
                   'mandatory': False,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'control': {'default': 'send-com,send-ext-com',
             'descr': 'BGP Controls',
             'length': [1, 64],
             'mandatory': False,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'workbook',
             'type': 'str'},
 'isGolfPeer': {'default': 'no',
                'descr': 'Boolean Define if BGP Peer is used for GOLF/L3EVPN (fabricExtControl Peering)',
                'enum': ['yes', 'no'],
                'mandatory': False,
                'source': 'workbook'},
 'l3out': {'descr': 'Parent L3 Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'l3out_node_profile': {'descr': 'L3Out Node Profile Name',
                        'length': [1, 64],
                        'mandatory': True,
                        'regex': {'exact_match': False,
                                  'pattern': '[a-zA-Z0-9_.:-]+'},
                        'source': 'workbook',
                        'type': 'str'},
 'local_bgp_as': {'default': 'None',
                  'descr': 'Local BGP AS Number',
                  'mandatory': False,
                  'range': [0, 4294967295],
                  'type': 'int'},
 'local_bgp_as_config': {'default': 'asnPropagate',
                         'descr': 'Local BGP AS Configuration',
                         'length': [1, 64],
                         'mandatory': False,
                         'regex': {'exact_match': False,
                                   'pattern': '[a-zA-Z0-9_.:-]+'},
                         'source': 'workbook',
                         'type': 'str'},
 'remote_bgp_as': {'default': 'None',
                   'descr': 'Remote BGP AS Number',
                   'mandatory': True,
                   'range': [0, 4294967295],
                   'type': 'int'},
 'tenant': {'descr': 'Parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'ttl': {'descr': 'BGP Multihop TTL',
         'mandatory': True,
         'range': [0, 255],
         'type': 'int'}}
```
## bgpRtTargetP.robot
### Template Description:
Verifies IPv4 and IPv6 BGP Route-Target Profile configuration under a VRF.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
routeTarget | Route-Target | True | None | DAFE Excel Sheet
vrfName | VRF Name | True | None | DAFE Excel Sheet
addressFamily | Route-Target Address Family | True | None | DAFE Excel Sheet
tenant | VRF parent Tenant Name | True | None | DAFE Excel Sheet
routeTargetType | Route-Target Type | True | None | DAFE Excel Sheet


### Template Body:
```
Verify ACI VRF BGP Route-Target Configuration - Tenant {{config['tenant']}}, VRF {{config['vrfName']}}, Address-Family {{config['addressFamily']}}, Route-Target: {{config['routeTarget']}}
    [Documentation]   Verifies that ACI BGP Route-Target Profile for VRF '{{config['vrfName']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['vrfName']}}
    ...  - Address-Family: {{config['addressFamily']}}
    ...  - BGP Route-Target: {{config['routeTarget']}}
    ...  - BGP Route-Target Type: {{config['routeTargetType']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve BGP Route Target
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['vrfName']}}/rtp-{{config['addressFamily']}}/rt-[{{config['routeTarget']}}]-{{config['routeTargetType']}}
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}    1		BGP Route-Target not configured with expected parameters        values=False


```
### Template Data Validation Model:
```json
{'addressFamily': {'default': 'None',
                   'descr': 'Route-Target Address Family',
                   'enum': ['ipv4-ucast', 'ipv6-ucast'],
                   'mandatory': True,
                   'source': 'workbook'},
 'routeTarget': {'default': 'None',
                 'descr': 'Route-Target',
                 'mandatory': True,
                 'regex': {'exact_match': True,
                           'pattern': 'route-target:as4-nn2:[0-9]+:[0-9]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'routeTargetType': {'default': 'None',
                     'descr': 'Route-Target Type',
                     'enum': ['import', 'export'],
                     'mandatory': True,
                     'source': 'workbook'},
 'tenant': {'default': 'None',
            'descr': 'VRF parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'vrfName': {'default': 'None',
             'descr': 'VRF Name',
             'length': [1, 64],
             'mandatory': True,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'workbook',
             'type': 'str'}}
```
## cdpIfPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
cdp_state | CDP Policy Name | True | None | DAFE Excel Sheet
name | CDP Interface Policy Name | True | None | DAFE Excel Sheet
description | CDP Interface Policy Description | False | None | DAFE Excel Sheet


### Template Body:
```
Verify ACI CDP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that CDP Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
	...  - Description: {{config['description']}}
	...  - Admin State: {{config['cdp_state']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/cdpIfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.name}		{{config['name']}}     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.adminSt}	{{config['cdp_state']}}     Admin State not matching expected configuration                   values=False


```
### Template Data Validation Model:
```json
{'cdp_state': {'default': 'None',
               'descr': 'CDP Policy Name',
               'enum': ['enabled', 'disabled'],
               'mandatory': True,
               'source': 'workbook'},
 'description': {'default': 'None',
                 'descr': 'CDP Interface Policy Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'default': 'None',
          'descr': 'CDP Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## datetimeNtpProv.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
name | NTP FQDN or IP | True | None | wordbook
is_preferred | Define the NTP Server as preferred for this profile | False | no | wordbook
management_epg | Management EPG | True | None |  
max_poll | Maximum Poll time in seconds | False | 4 | wordbook
datetime_pol_name | NTP Profile Name | True | None | wordbook
min_poll | Minimum Poll time in seconds | False | 4 | wordbook
key_id | Id of the Authentication key, use '0' if no auth key is used | False | 0 | wordbook
description | NTP Profile Description | False | None | wordbook


### Template Body:
```
{% if 'min_poll' not in config or config['min_poll'] == "" %}
  {% set x=config.__setitem__('min_poll', '4') %}
{% endif %}
{% if 'max_poll' not in config or config['max_poll'] == "" %}
  {% set x=config.__setitem__('max_poll', '6') %}
{% endif %}
Verify ACI Datetime NTP Provider Configuration - Provider '{{config['name']}}'
    [Documentation]   Verifies that ACI NTP Provider '{{config['name']}}' are configured with the expected parameters
    ...  - Datetime Profile Name: {{config['datetime_pol_name']}}
    ...  - NTP Provider: {{config['name']}}
    ...  - Minimum Poll Interval: {{config['min_poll']}}
    ...  - Maximum Poll Interval: {{config['max_poll']}}
    ...  - Preferred: {{config['is_preferred']}}
    ...  - Management EPG: {{config['management_epg']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-ntp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/time-{{config['datetime_pol_name']}}/ntpprov-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		NTP Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.minPoll}"       "{{config['min_poll']}}"                                    Minimum Poll Interval not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.maxPoll}"       "{{config['max_poll']}}"                                    Maximum Poll Interval not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.preferred}"     "{{config['is_preferred']}}"                                Preferred setting not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.epgDn}"         "uni/tn-mgmt/mgmtp-default/{{config['management_epg']}}-default"            Management EPG not matching expected configuration                 values=False


```
### Template Data Validation Model:
```json
{'datetime_pol_name': {'default': 'None',
                       'descr': 'NTP Profile Name',
                       'length': [1, 64],
                       'mandatory': True,
                       'regex': {'exact_match': False,
                                 'pattern': '[a-zA-Z0-9_.:-]+'},
                       'source': 'wordbook',
                       'type': 'str'},
 'description': {'default': 'None',
                 'descr': 'NTP Profile Description',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'wordbook',
                 'type': 'str'},
 'is_preferred': {'default': 'no',
                  'descr': 'Define the NTP Server as preferred for this profile',
                  'enum': ['yes', 'no'],
                  'mandatory': False,
                  'source': 'wordbook'},
 'key_id': {'default': '0',
            'descr': "Id of the Authentication key, use '0' if no auth key is used",
            'mandatory': False,
            'range': [0, 65535],
            'source': 'wordbook',
            'type': 'int'},
 'management_epg': {'default': 'None',
                    'descr': 'Management EPG',
                    'enum': ['inb', 'oob'],
                    'mandatory': True},
 'max_poll': {'default': '4',
              'descr': 'Maximum Poll time in seconds',
              'mandatory': False,
              'range': [4, 16],
              'source': 'wordbook',
              'type': 'int'},
 'min_poll': {'default': '4',
              'descr': 'Minimum Poll time in seconds',
              'mandatory': False,
              'range': [4, 16],
              'source': 'wordbook',
              'type': 'int'},
 'name': {'default': 'None',
          'descr': 'NTP FQDN or IP',
          'mandatory': True,
          'source': 'wordbook',
          'type': 'str'}}
```
## datetimePol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
authentication_state | NTP Authentication state | True | None | wordbook
stratum_value | Stratum Value used when NTP Master is enabled | False | 8 | wordbook
admin_state | NTP admin state | True | None | wordbook
name | NTP Profile Name | False | default | wordbook
master_mode | Toggle between master clock mode | False | disabled | wordbook
server_state | Enable or disable NTP server mode | False | disabled | wordbook
description | NTP Profile Description" | False | None | wordbook


### Template Body:
```
Verify ACI Datetime Profile Configuration - Profile '{{config['name']}}'
    [Documentation]   Verifies that ACI Datetime Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name: {{config['name']}}
    ...  - Description: {{config['description']}}
    ...  - Admin State: {{config['admin_state']}}
    ...  - Authentication State: {{config['authentication_state']}}
    ...  - Server State: {{config['server_state']}}
    ...  - Master Mode: {{config['master_mode']}}
    ...  - Stratum Value: {{config['stratum_value']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-ntp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/time-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Datetime Profile not defined		values=False
    {% if config['description'] and config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.descr}"   "{{config['description']}}"                                            Description not matching expected configuration                 values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.adminSt}"   "{{config['admin_state']}}"                                          Admin State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.authSt}"   "{{config['authentication_state']}}"                                  Authentication State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.serverState}"   "{{config['server_state']}}"                                     Server State not matching expected configuration                 values=False
    {% if config['server_state'] == "enabled" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.masterMode}"   "{{config['master_mode']}}"                                       Master Mode not matching expected configuration                 values=False
    {% endif %}
    {% if config['server_state'] == "enabled" and config['master_mode'] == "enabled"%}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.StratumValue}"   "{{config['stratum_value']}}"                                   Stratum Value not matching expected configuration                 values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'admin_state': {'default': 'None',
                 'descr': 'NTP admin state',
                 'enum': ['enabled', 'disabled'],
                 'mandatory': True,
                 'source': 'wordbook'},
 'authentication_state': {'default': 'None',
                          'descr': 'NTP Authentication state',
                          'enum': ['enabled', 'disabled'],
                          'mandatory': True,
                          'source': 'wordbook'},
 'description': {'default': 'None',
                 'descr': 'NTP Profile Description"',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'wordbook',
                 'type': 'str'},
 'master_mode': {'default': 'disabled',
                 'descr': 'Toggle between master clock mode',
                 'enum': ['enabled', 'disabled'],
                 'mandatory': False,
                 'source': 'wordbook'},
 'name': {'default': 'default',
          'descr': 'NTP Profile Name',
          'length': [1, 64],
          'mandatory': False,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'wordbook',
          'type': 'str'},
 'server_state': {'default': 'disabled',
                  'descr': 'Enable or disable NTP server mode',
                  'enum': ['enabled', 'disabled'],
                  'mandatory': False,
                  'source': 'wordbook'},
 'stratum_value': {'default': '8',
                   'descr': 'Stratum Value used when NTP Master is enabled',
                   'mandatory': False,
                   'range': [1, 14],
                   'source': 'wordbook',
                   'type': 'int'}}
```
## dnsProfile.robot
### Template Description:
Verifies DNS Profile configuration including association to management EPG.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
management_epg | EPG used for DNS resolution | True | None | wordbook
description | DNS Profile Description | False | None | wordbook
is_default_domain | Define the Domain name as default for this profile | False | no | wordbook
domain_name | Domain Name | False | None | wordbook
name | DNS Profile name | True | None | wordbook


### Template Body:
```
{% if config['domain_name'] and config['domain_name'] != "" %}
Verify ACI DNS Profile Configuration - Profile '{{config['name']}}', Domain Name '{{config['domain_name']}}'
{% else %}
Verify ACI DNS Profile Configuration - Profile '{{config['name']}}'
{% endif %}
    [Documentation]   Verifies that ACI DNS Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name: {{config['name']}}
    ...  - Description: {{config['description']}}
    ...  - Management EPG: {{config['management_epg']}}
    {% if config['domain_name'] and config['domain_name'] != "" %}
    ...  - Domain Name: {{config['domain_name']}}
    ...  - Default Domain Name: {{config['is_default_domain']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (DNS Profile)		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Profile not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProfile.attributes.epgDn}"   "uni/tn-mgmt/mgmtp-default/{{config['management_epg']}}-default"       Management EPG not matching expected configuration              values=False
    {% if config['description'] and config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProfile.attributes.descr}"   "{{config['description']}}"                                            Description not matching expected configuration                 values=False
    {% endif %}
    {% if config['domain_name'] and config['domain_name'] != "" %}
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-{{config['name']}}/dom-{{config['domain_name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Domain Name)		values=False
	Should Be Equal as Integers     ${return.totalCount}  1            Domain Name not associated with DNS Profile	            values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].dnsDomain.attributes.isDefault}"  "{{config['is_default_domain']}}"	Default Domain Name Setting not matching expected configuration		        values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'DNS Profile Description',
                 'length': [1, 128],
                 'mandatory': False,
                 'regexp': {'exact_match': False,
                            'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'wordbook',
                 'type': 'str'},
 'domain_name': {'default': 'None',
                 'descr': 'Domain Name',
                 'length': [0, 255],
                 'mandatory': False,
                 'source': 'wordbook',
                 'type': 'str'},
 'is_default_domain': {'default': 'no',
                       'descr': 'Define the Domain name as default for this profile',
                       'enum': ['yes', 'no'],
                       'mandatory': False,
                       'source': 'wordbook'},
 'management_epg': {'default': 'None',
                    'descr': 'EPG used for DNS resolution',
                    'enum': ['inb', 'oob'],
                    'mandatory': True,
                    'source': 'wordbook'},
 'name': {'default': 'None',
          'descr': 'DNS Profile name',
          'length': [1, 64],
          'mandatory': True,
          'regexp': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'wordbook',
          'type': 'str'}}
```
## dnsProv.robot
### Template Description:
Verifies DNS Provider configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
is_preferred_dns | Is this DNS preferred for the parent DNS Profile | False | no | wordbook
name |   | True | None | wordbook
dns_server_address | DNS Server IPv4 Address. | True | None | wordbook
dns_profile_name | Parent DNS Profile Name | True | None | wordbook


### Template Body:
```
Verify ACI DNS Profile Configuration - Profile '{{config['dns_profile_name']}}', DNS Server '{{config['dns_server_address']}}'
    [Documentation]   Verifies that ACI DNS Provider '{{config['dns_server_address']}}' under Profile '{{config['dns_profile_name']}}' are configured with the expected parameters
    ...  - DNS Profile Name: {{config['dns_profile_name']}}
    ...  - DNS Server Name: {{config['dns_server_name']}}
    ...  - DNS Server Address: {{config['dns_server_address']}}
    ...  - Preferred DNS Server: {{config['is_preferred_dns']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-{{config['dns_profile_name']}}/prov-[{{config['dns_server_address']}}]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.preferred}"     "{{config['is_preferred_dns']}}"       Preferred DNS Server Setting not matching expected configuration              values=False
    {% if config['dns_server_name'] and config['dns_server_name'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.name}"          "{{config['dns_server_name']}}"        DNS Server Name not matching expected configuration                 values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'dns_profile_name': {'default': 'None',
                      'descr': 'Parent DNS Profile Name',
                      'length': [1, 64],
                      'mandatory': True,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'wordbook',
                      'type': 'str'},
 'dns_server_address': {'default': 'None',
                        'descr': 'DNS Server IPv4 Address.',
                        'mandatory': True,
                        'source': 'wordbook'},
 'is_preferred_dns': {'default': 'no',
                      'descr': 'Is this DNS preferred for the parent DNS Profile',
                      'enum': ['yes', 'no'],
                      'mandatory': False,
                      'source': 'wordbook'},
 'name': {'default': 'None',
          'dns_server_name': 'DNS Server Provider Name',
          'length': [1, 64],
          'mandatory': True,
          'regexp': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'wordbook',
          'type': 'str'}}
```
## fabricHIfPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
name | Link Interface Policy Name | True | None | DAFE Excel Sheet
fec_mode | Forwarding Error Correction Mode | False | inherit | wordbook
debounce | Interface debounce time in ms | False | 100 | wordbook
autoneg | Interface Negotiation mode | True | None | wordbook
speed | Interface Speed | True | None | wordbook
description | Link Interface Policy Description | False | None | DAFE Excel Sheet


### Template Body:
```
{% if 'debounce' not in config or config['debounce'] == "" %}
  {% set x=config.__setitem__('debounce', '100') %}
{% endif %}
{% if 'fec_mode' not in config or config['fec_mode'] == "" %}
  {% set x=config.__setitem__('fec_mode', 'inherit') %}
{% endif %}
Verify ACI Link Level Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that Link Level Channel Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
	...  - Speed: {{config['speed']}}
	...  - Auto Negotiation: {{config['autoneg']}}
	...  - Link Debounce Interval: {{config['debounce']}}
	...  - FEC Mode: {{config['fec_mode']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	{{config['name']}}      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			{{config['speed']}}         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		{{config['autoneg']}}          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	{{config['debounce']}}         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	{{config['debounce']}}         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		{{config['fec_mode']}}         	FEC Mode not matching expected configuration            	values=False


```
### Template Data Validation Model:
```json
{'autoneg': {'default': 'None',
             'descr': 'Interface Negotiation mode',
             'enum': ['on', 'off'],
             'mandatory': 'True',
             'source': 'wordbook'},
 'debounce': {'default': '100',
              'descr': 'Interface debounce time in ms',
              'mandatory': False,
              'range': [0, 5000],
              'source': 'wordbook',
              'type': 'int'},
 'description': {'default': 'None',
                 'descr': 'Link Interface Policy Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'fec_mode': {'default': 'inherit',
              'descr': 'Forwarding Error Correction Mode',
              'enum': ['inherit',
                       'cl74-fc-fec',
                       'cl91-rs-fec',
                       'disable-fec'],
              'mandatory': False,
              'source': 'wordbook'},
 'name': {'default': 'None',
          'descr': 'Link Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'speed': {'default': 'None',
           'descr': 'Interface Speed',
           'enum': ['inherit', '100G', '40G', '10G', '1G', '100M'],
           'mandatory': True,
           'source': 'wordbook'}}
```
## fvAEPg.robot
### Template Description:
Verifies EPG configuration

If not specified:
* QoS Class assumed to be configured as unspecified
* Intra-EPG Isolation assumed to be configured as disabled
* Preferred Group Member assumed to be configured as exclude
* Flood on Encapsulation assumed to be configured as disabled

> The Tenant and Bridge Domain must pre-exist.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
custom_qos_pol | Name of the custom QOS Policy the EPG will be associated with | False | None | DAFE Excel Sheet
name | EPG name | True | None | DAFE Excel Sheet
app_profile | EPG parent Application Profile Name | True | None | DAFE Excel Sheet
dataPlanePolicer | Name of the ingress dataplane policer assigned to this EPG | False | None | DAFE Excel Sheet
prefGrMemb | Mark an EPG as being part of a preferred group or not | False | exclude | DAFE Excel Sheet
floodOnEncap | A property to specify whether flooding is enabled for the EPGs. If flooding is disabled, the value specified in the BD mode is taken into account. | False | disabled | DAFE Excel Sheet
qos_class | EPG QoS Class | False | unspecified | DAFE Excel Sheet
nameAlias | EPG Name Alias | False | None | DAFE Excel Sheet
bridge_domain | Name of the bridge domain the EPG will be associated with | True | None | DAFE Excel Sheet
intra_epg_isolation | Indicates whether the EPG has Intra-EPG Isolation enforced. | False | unenforced | DAFE Excel Sheet
tenant | EPG parent Tenant Name | True | None | DAFE Excel Sheet
description | EPG description string | False | None | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'custom_qos_pol' not in config %}
  {% set x=config.__setitem__('custom_qos_pol', '') %}
{% endif %}
{% if 'intra_epg_isolation' not in config %}
  {% set x=config.__setitem__('intra_epg_isolation', 'unenforced') %}
{% elif config['intra_epg_isolation'] not in ['unenforced', 'enforced'] %}
  {% set x=config.__setitem__('intra_epg_isolation', 'unenforced') %}
{% endif %}
{% if 'dataPlanePolicer' not in config %}
  {% set x=config.__setitem__('dataPlanePolicer', '') %}
{% endif %}
{% if 'prefGrMemb' not in config %}
  {% set x=config.__setitem__('prefGrMemb', 'exclude') %}
{% elif config['prefGrMemb'] not in ['exclude', 'include'] %}
  {% set x=config.__setitem__('prefGrMemb', 'exclude') %}
{% endif %}
{% if 'floodOnEncap' not in config %}
  {% set x=config.__setitem__('floodOnEncap', 'disabled') %}
{% elif config['floodOnEncap'] not in ['disabled', 'enabled'] %}
  {% set x=config.__setitem__('floodOnEncap', 'disabled') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['unspecified', 'level1', 'level2', 'level3'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
Verify ACI EPG Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}
    [Documentation]   Verifies that ACI EPG '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Associated to BD: {{config['bridge_domain']}}
    {% if config['custom_qos_pol'] != "" %}
    ...  - Custom QoS Policy: {{config['custom_qos_pol']}}
    {% endif %}
    ...  - QoS Class: {{config['qos_class']}}
    ...  - Intra EPG Isolation: {{config['intra_epg_isolation']}}
    {% if config['dataPlanePolicer'] != "" %}
    ...  - Data-Plane Policer: {{config['dataPlanePolicer']}}
    {% endif %}
    ...  - Preferred Group Member: {{config['prefGrMemb']}}
    ...  - Flood on Encapsulation: {{config['floodOnEncap']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvAEPg.attributes.name}   {{config['name']}}                            Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.nameAlias}"  "{{config['nameAlias']}}"               Name alias not matching expected configuration                values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.descr}"  "{{config['description']}}"                 Description not matching expected configuration               values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.prio}"  "{{config['qos_class']}}"                    QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.prefGrMemb}"  "{{config['prefGrMemb']}}"             Preferred Group Member not matching expected configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.pcEnfPref}"  "{{config['intra_epg_isolation']}}"     Intra EPG Isolation not matching expected configuration       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.floodOnEncap}"  "{{config['floodOnEncap']}}"         Flood on Encapsulation not matching expected configuration    values=False
    # Verify BD association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rsbd
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvRsBd.attributes.tnFvBDName}   {{config['bridge_domain']}}   Associated Bridge Domain not matching expected configuration		values=False
    {% if config['custom_qos_pol'] != "" %}
    # Verify Custom QoS Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rscustQosPol
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCustQosPol.attributes.tnQosCustomPolName}"   "{{config['custom_qos_pol']}}"   Custom QoS Policy not matching expected configuration		values=False
    {% endif %}
    # Verify Data-Plane Policer
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rsdppPol
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    {% if config['dataPlanePolicer'] == "" %}
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Data-Plane Policer not matching expected configuration		values=False
    {% else %}
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvRsDppPol.attributes.tnQosDppPolName}   {{config['dataPlanePolicer']}}   Data-Plane Policer not matching expected configuration		values=True
    {% endif %}


```
### Template Data Validation Model:
```json
{'app_profile': {'default': 'None',
                 'descr': 'EPG parent Application Profile Name',
                 'length': [1, 64],
                 'mandatory': True,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'bridge_domain': {'default': 'None',
                   'descr': 'Name of the bridge domain the EPG will be associated with',
                   'length': [1, 64],
                   'mandatory': True,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'custom_qos_pol': {'default': 'None',
                    'descr': 'Name of the custom QOS Policy the EPG will be associated with',
                    'length': [1, 64],
                    'mandatory': False,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'workbook',
                    'type': 'str'},
 'dataPlanePolicer': {'default': 'None',
                      'descr': 'Name of the ingress dataplane policer assigned to this EPG',
                      'length': [1, 64],
                      'mandatory': False,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'description': {'default': 'None',
                 'descr': 'EPG description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'floodOnEncap': {'default': 'disabled',
                  'descr': 'A property to specify whether flooding is enabled for the EPGs. If flooding is disabled, the value specified in the BD mode is taken into account.',
                  'enum': ['enabled', 'disabled'],
                  'mandatory': False,
                  'source': 'workbook'},
 'intra_epg_isolation': {'default': 'unenforced',
                         'descr': 'Indicates whether the EPG has Intra-EPG Isolation enforced.',
                         'enum': ['enforced', 'unenforced'],
                         'mandatory': False,
                         'source': 'workbook'},
 'name': {'default': 'None',
          'descr': 'EPG name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'EPG Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'prefGrMemb': {'default': 'exclude',
                'descr': 'Mark an EPG as being part of a preferred group or not',
                'enum': ['exclude', 'include'],
                'mandatory': False,
                'source': 'workbook'},
 'qos_class': {'default': 'unspecified',
               'descr': 'EPG QoS Class',
               'enum': ['unspecified', 'level1', 'level2', 'level3'],
               'mandatory': False,
               'source': 'workbook'},
 'tenant': {'default': 'None',
            'descr': 'EPG parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvAEPgCtr.robot
### Template Description:
Verifies EPG contract association.

> The Tenant, Application Profile and EPG must pre-exist.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | EPG parent Tenant Name | True |   | DAFE Excel Sheet
name | EPG name | True |   | DAFE Excel Sheet
app_profile | EPG parent Application Profile Name | True |   | DAFE Excel Sheet
consumed_ctr | Boolean checking if contract is consumed | False | no | DAFE Excel Sheet
contract | Contract name | True |   | DAFE Excel Sheet
provided_ctr | Boolean checking if contract is provided | False | no | DAFE Excel Sheet


### Template Body:
```
{% if 'consumed_ctr' not in config %}
  {% set x=config.__setitem__('consumed_ctr', 'no') %}
{% elif config['consumed_ctr'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('consumed_ctr', 'no') %}
{% endif %}
{% if 'provided_ctr' not in config %}
  {% set x=config.__setitem__('provided_ctr', 'no') %}
{% elif config['provided_ctr'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('provided_ctr', 'no') %}
{% endif %}
Verify ACI EPG Contract Configuration - App Profile {{config['app_profile']}}, EPG {{config['name']}}, Contract {{config['contract']}}
    [Documentation]   Verifies that ACI EPG Contract association for '{{config['contract']}}' are configured under tenant '{{config['tenant']}}'are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    ...  - Contract name: {{config['contract']}}
    ...  - Consume Contract: {{config['consumed_ctr']}}
    ...  - Provide Contract: {{config['provided_ctr']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    {% if config['consumed_ctr'] == "yes" %}
    # Retrieve Configuration (consume contract)
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rscons-{{config['contract']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure      Should Be Equal as Integers     ${return.totalCount}  1		Contract not consumed by EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings         "${return.payload[0].fvRsCons.attributes.tnVzBrCPName}"  "{{config['contract']}}"               Consumed Contract not matching expected configuration                values=False
    {% endif %}
    {% if config['provided_ctr'] == "yes" %}
    # Retrieve Configuration (provide contract)
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rsprov-{{config['contract']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure      Should Be Equal as Integers     ${return.totalCount}  1		Contract not provided by EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings         "${return.payload[0].fvRsProv.attributes.tnVzBrCPName}"  "{{config['contract']}}"               Provided Contract not matching expected configuration                values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'app_profile': {'descr': 'EPG parent Application Profile Name',
                 'length': [1, 64],
                 'mandatory': True,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'consumed_ctr': {'default': 'no',
                  'descr': 'Boolean checking if contract is consumed',
                  'enum': ['yes', 'no'],
                  'mandatory': False,
                  'source': 'workbook'},
 'contract': {'descr': 'Contract name',
              'length': [1, 64],
              'mandatory': True,
              'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
              'source': 'workbook',
              'type': 'str'},
 'name': {'descr': 'EPG name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'provided_ctr': {'default': 'no',
                  'descr': 'Boolean checking if contract is provided',
                  'enum': ['yes', 'no'],
                  'mandatory': False,
                  'source': 'workbook'},
 'tenant': {'descr': 'EPG parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvAEPg_static_binding.robot
### Template Description:
Verified EPG static binding to either
* A Switch Access Port
* A Switch Port-Channel
* A Switch pair virtual Port-Channel

Binding mode can be:
* regular = Trunk mode
* native = Access mode with 802.1p
* untagged = Access mode untagged


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
name | EPG Name | True |   | DAFE Excel Sheet
right_node_id | Switch Node Id (only used for vPC connection) | False |   | DAFE Excel Sheet
app_profile | EPG parent application profile Name | True |   | DAFE Excel Sheet
encap_vlan_id | Primary EPG VLAN encapsulation Id | True |   | DAFE Excel Sheet
deployImedcy | Deployement Immedicay | False | lazy | DAFE Excel Sheet
left_node_id | Switch Node Id | True |   | DAFE Excel Sheet
interface_policy_group | PC or vPC Interface Policy Group Name | False |   | DAFE Excel Sheet
mode | Associated Port mode | True |   | DAFE Excel Sheet
access_port_id | Access Port id  (slot/port) | False |   | DAFE Excel Sheet
pod_id | Switch Pod Id | True |   | DAFE Excel Sheet
tenant | EPG parent Tenant Name | True |   | DAFE Excel Sheet


### Template Body:
```
{% if 'deployImedcy' not in config %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% elif config['deployImedcy'] not in ['immediate', 'lazy'] %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% endif %}
{% if config['static_binding_type'] == "vPC" %}
    {% set tDn %}topology/pod-{{config['pod_id']}}/protpaths-{{config['left_node_id']}}-{{config['right_node_id']}}/pathep-[{{config['interface_policy_group']}}]{% endset %}
{% elif config['static_binding_type'] == "PC" %}
    {% set tDn %}topology/pod-{{config['pod_id']}}/paths-{{config['left_node_id']}}/pathep-[{{config['interface_policy_group']}}]{% endset %}
{% elif config['static_binding_type'] == "Access" %}
    {% set tDn %}topology/pod-{{config['pod_id']}}/paths-{{config['left_node_id']}}/pathep-[eth{{config['access_port_id']}}]{% endset %}
{% endif %}
{% if config['static_binding_type'] == "vPC" %}
Verify ACI EPG Binding Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}, Interface Policy Group {{config['interface_policy_group']}}
{% elif config['static_binding_type'] == "PC" %}
Verify ACI EPG Binding Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}, Interface Policy Group {{config['interface_policy_group']}}
{% elif config['static_binding_type'] == "Access" %}
Verify ACI EPG Binding Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}, Node {{config['left_node_id']}}, Interface eth{{config['access_port_id']}}
{% endif %}
    [Documentation]   Verifies that ACI EPG Binding for '{{config['name']}}' are configured under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  with the parameters defined in the NIP
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    ...  - POD ID: {{config['pod_id']}}
	{% if config['static_binding_type'] == "vPC" %}
    ...  - Node (left): {{config['left_node_id']}}
    ...  - Node (right): {{config['right_node_id']}}
	...  - Interface Policy Group: {{config['interface_policy_group']}}
	{% elif config['static_binding_type'] == "PC" %}
	...  - Node: {{config['left_node_id']}}
	...  - Interface Policy Group: {{config['interface_policy_group']}}
	{% elif config['static_binding_type'] == "Access" %}
	...  - Node: {{config['left_node_id']}}
 	...  - Interface: eth{{config['access_port_id']}}
    {% endif %}
	...  - Encapsulation: vlan-{{config['encap_vlan_id']}}
    ...  - Deployment Immediacy: {{config['deployImedcy']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rspathAtt-[{{tDn}}]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Interface not having a static binding for the EPG		values=False
	Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.tDn}"   "{{tDn}}"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.mode}"  "{{config['mode']}}"               Binding Mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.instrImedcy}"  "{{config['deployImedcy']}}"               Deployment Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.encap}"  "vlan-{{config['encap_vlan_id']}}"               VLAN Encapsulation not matching expected configuration                values=False


```
### Template Data Validation Model:
```json
{'access_port_id': {'descr': 'Access Port id  (slot/port)',
                    'mandatory': False,
                    'regex': {'exact_match': True,
                              'pattern': '([1-9]/[1-9]+|N/A)'},
                    'source': 'workbook',
                    'type': 'str'},
 'app_profile': {'descr': 'EPG parent application profile Name',
                 'length': [1, 64],
                 'mandatory': True,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'deployImedcy': {'default': 'lazy',
                  'descr': 'Deployement Immedicay',
                  'enum': ['lazy', 'immediate'],
                  'mandatory': False,
                  'source': 'workbook'},
 'encap_vlan_id': {'descr': 'Primary EPG VLAN encapsulation Id',
                   'mandatory': True,
                   'range': [1, 4094],
                   'source': 'workbook',
                   'type': 'int'},
 'interface_policy_group': {'descr': 'PC or vPC Interface Policy Group Name',
                            'length': [1, 64],
                            'mandatory': False,
                            'regex': {'exact_match': False,
                                      'pattern': '[a-zA-Z0-9_.:-]+'},
                            'source': 'workbook',
                            'type': 'str'},
 'left_node_id': {'descr': 'Switch Node Id',
                  'mandatory': True,
                  'range': [101, 4000],
                  'source': 'workbook',
                  'type': 'int'},
 'mode': {'descr': 'Associated Port mode',
          'enum': ['regular', 'native', 'untagged'],
          'mandatory': True,
          'source': 'workbook'},
 'name': {'descr': 'EPG Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'pod_id': {'descr': 'Switch Pod Id',
            'mandatory': 'True',
            'source': 'workbook',
            'type': 'int'},
 'right_node_id': {'descr': 'Switch Node Id (only used for vPC connection)',
                   'mandatory': False,
                   'range': [101, 4000],
                   'source': 'workbook',
                   'type': 'int'},
 'tenant': {'descr': 'EPG parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvAP.robot
### Template Description:
Verifies Application Profile configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | Application Profile parent tenant name | True | None | DAFE Excel Sheet
qos_class | Application Profile QoS Class | False | unspecified | DAFE Excel Sheet
name | Application Profile name | True | None | DAFE Excel Sheet
nameAlias | Application Profile Name Alias | False | None | DAFE Excel Sheet
description | Description string | False | None | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['unspecified', 'level1', 'level2', 'level3'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
Verify ACI Application Profile Configuration - Tenant {{config['tenant']}}, App Profile {{config['name']}}
    [Documentation]   Verifies that ACI Application Profile '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Application Profile Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - QoS Class: {{config['qos_class']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-ap
    # Retrieve AP
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	Should Be Equal as Strings      ${return.payload[0].fvAp.attributes.name}   {{config['name']}}      Failure retreiving configuration		                          values=False
  {% if config['nameAlias'] != "" %}
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.nameAlias}"  "{{config['nameAlias']}}"             Name alias not matching expected configuration                       values=False
  {% endif %}
  {% if config['description'] != "" %}
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.descr}"  "{{config['description']}}"               Description not matching expected configuration                       values=False
  {% endif %}
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.prio}"  "{{config['qos_class']}}"                  QoS Class not matching expected configuration                       values=False


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'Description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'default': 'None',
          'descr': 'Application Profile name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'Application Profile Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'qos_class': {'default': 'unspecified',
               'descr': 'Application Profile QoS Class',
               'enum': ['unspecified', 'level1', 'level2', 'level3'],
               'mandatory': False,
               'source': 'workbook'},
 'tenant': {'default': 'None',
            'descr': 'Application Profile parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvBD.robot
### Template Description:
Verifies Bridge Domain configuration

> The association of BD subnet's are not verified in this test case template.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
l3_unknown_multicast | Forwarding parameter for Layer 3 unknown Multicast destinations" | True |   | DAFE Excel Sheet
l2_unknown_unicast | Forwarding parameter for L2 Unknown Unicast destinations | True |   | DAFE Excel Sheet
route_control_profile | Name of the route-control-profile applied to the BD | False | None | DAFE Excel Sheet
arp_flood | Enables ARP flooding | True |   | DAFE Excel Sheet
unicast_routing | Enable Unicast Routing | True |   | DAFE Excel Sheet
legacy_bd_vlan | BD Encapsulation used if BD Legacy mode is used. Mandatory if BD Legacy mode is enabled | False | None | DAFE Excel Sheet
igmpInterfacePolicy | IGMP Interface Policy Name. The template assumes the policy iscreated in the BD Tenant | False | None | DAFE Excel Sheet
vrf | name of the VRF this BD is associated with | True |   | DAFE Excel Sheet
l3out_for_route_profile | Name of the L3Out the route-control-profile is applied | False | None | DAFE Excel Sheet
description | Description string | False |   | DAFE Excel Sheet
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet
endpoint_retention_policy | Endpoint retention policy name | False | None | DAFE Excel Sheet
name | Bridge Domain Name | True |   | DAFE Excel Sheet
limit_ip_learning_to_subnet | Limits IP address learning to the bridge domain subnets only | False | yes | DAFE Excel Sheet
is_bd_legacy | When bridge domain legacy mode is specified, bridge domain encapsulation is used for all EPGs that reference the bridge domain | False | no | DAFE Excel Sheet
nameAlias | VRF Name Alias | False | None | DAFE Excel Sheet
igmp_snoop_policy | IGMP Snooping Policy Name | False | None | DAFE Excel Sheet
enablePim | Enables the Protocol Independent Multicast (PIM) protocol on the BD | False |   | DAFE Excel Sheet
endpoint_data_plane_learning | Enables or disables endpoint dataplane learning | False | yes | DAFE Excel Sheet
multi_dest_flood | The multiple destination forwarding method for L2 Multicast, Broadcast, and Link Layer traffic types | True |   | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'enablePim' not in config %}
  {% set x=config.__setitem__('enablePim', 'no') %}
{% elif config['enablePim'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('enablePim', 'no') %}
{% endif %}
{% if 'limit_ip_learning_to_subnet' not in config %}
  {% set x=config.__setitem__('limit_ip_learning_to_subnet', 'yes') %}
{% elif config['limit_ip_learning_to_subnet'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('limit_ip_learning_to_subnet', 'yes') %}
{% endif %}
{% if 'endpoint_data_plane_learning' not in config %}
  {% set x=config.__setitem__('endpoint_data_plane_learning', 'yes') %}
{% elif config['endpoint_data_plane_learning'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('endpoint_data_plane_learning', 'yes') %}
{% endif %}
{% if 'igmp_snoop_policy' not in config %}
  {% set x=config.__setitem__('igmp_snoop_policy', '') %}
{% endif %}
{% if 'endpoint_retention_policy' not in config %}
  {% set x=config.__setitem__('endpoint_retention_policy', '') %}
{% endif %}
{% if 'igmpInterfacePolicy' not in config %}
  {% set x=config.__setitem__('igmpInterfacePolicy', '') %}
{% endif %}
{% if 'is_bd_legacy' not in config %}
  {% set x=config.__setitem__('is_bd_legacy', 'no') %}
{% elif config['is_bd_legacy'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('is_bd_legacy', 'no') %}
{% endif %}
{% if 'legacy_bd_vlan' not in config %}
  {% set x=config.__setitem__('legacy_bd_vlan', '') %}
{% endif %}
{% if 'route_control_profile' not in config %}
  {% set x=config.__setitem__('route_control_profile', '') %}
{% endif %}
{% if 'l3out_for_route_profile' not in config %}
  {% set x=config.__setitem__('l3out_for_route_profile', '') %}
{% endif %}
Verify ACI BD Configuration - Tenant {{config['tenant']}}, BD {{config['name']}}
    [Documentation]   Verifies that ACI BD '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - BD Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Associated to VRF: {{config['vrf']}}
    ...  - L2 Unknown Unicast Flooding: {{config['l2_unknown_unicast']}}
    ...  - L3 Unknown Multicast Flooding: {{config['l3_unknown_multicast']}}
    ...  - Multi Destination Flooding: {{config['multi_dest_flood']}}
    ...  - Enable PIM: {{config['enablePim']}}
    ...  - ARP Flooding: {{config['arp_flood']}}
    ...  - Unicast Routing: {{config['unicast_routing']}}
    ...  - Limit IP Learning to Subnet: {{config['limit_ip_learning_to_subnet']}}
    ...  - Endpoint Dataplane Learning: {{config['endpoint_data_plane_learning']}}
    ...  - Endpoint Move Detection Mode: {{config['endpoint_move_detect_mode']}}
    {% if config['endpoint_retention_policy'] != "" %}
    ...  - Endpoint Retention Policy: {{config['endpoint_retention_policy']}}
    {% endif %}
    {% if config['igmp_snoop'] != "" %}
    ...  - IGMP Snooping Policy: {{config['igmp_snoop']}}
    {% endif %}
    {% if config['igmpInterfacePolicy'] != "" %}
    ...  - IGMP Interface Policy: {{config['igmpInterfacePolicy']}}
    {% endif %}
    ...  - Legacy Mode: {{config['is_bd_legacy']}}
    {% if config['is_bd_legacy'] == "yes" %}
    ...  - Legacy Encapsulation VLAN: {{config['legacy_bd_vlan']}}
    {% endif %}
    {% if config['route_control_profile'] == "yes" %}
    ...  - Route Profile: {{config['route_control_profile']}}
    {% endif %}
    {% if config['l3out_for_route_profile'] == "yes" %}
    ...  - L3Out for Route Profile: {{config['l3out_for_route_profile']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		BD not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvBD.attributes.name}   {{config['name']}}      Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.nameAlias}"  "{{config['nameAlias']}}"                    Name alias not matching expected configuration                       values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.descr}"  "{{config['description']}}"                      Description not matching expected configuration                values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMacUcastAct}"  "{{config['l2_unknown_unicast']}}"      L2 Unknown Unicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMcastAct}"  "{{config['l3_unknown_multicast']}}"       L3 Unknown Multicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.multiDstPktAct}"  "{{config['multi_dest_flood']}}"        Multi Destination Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.arpFlood}"  "{{config['arp_flood']}}"                     ARP Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unicastRoute}"  "{{config['unicast_routing']}}"           Unicast Routing not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.limitIpLearnToSubnets}"  "{{config['limit_ip_learning_to_subnet']}}"           Limit IP Learning to Subnet not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.ipLearning}"  "{{config['endpoint_data_plane_learning']}}"           Endpoint Dataplane Learning not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.mcastAllow}"  "{{config['enablePim']}}"                   PIM not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.epMoveDetectMode}"  "{{config['endpoint_move_detect_mode']}}"                   Endpoint Move Detection Mode not matching expected configuration                values=False
    # VRF Association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsctx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (VRF)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (VRF)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtx.attributes.tnFvCtxName}"  "{{config['vrf']}}"                    Associated VRF not matching expected configuration                       values=False
    {% if config['endpoint_retention_policy'] != "" %}
    # Endpoint Retention Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsbdToEpRet
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Endpoint Retention Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Endpoint Retention Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBdToEpRet.attributes.tnFvEpRetPolName}"  "{{config['endpoint_retention_policy']}}"                    Endpoint Retention Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['igmp_snoop'] != "" %}
    # IGMP Snooping
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsigmpsn
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Snooping)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Snooping)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsIgmpsn.attributes.tnIgmpSnoopPolName}"  "{{config['igmp_snoop']}}"                    IGMP Snooping Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['igmpInterfacePolicy'] != "" %}
    # IGMP Interface Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/igmpIfP/rsIfPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Interface Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Interface Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].igmpRsIfPol.attributes.tDn}"  "uni/tn-{{config['tenant']}}/igmpIfPol-{{config['igmpInterfacePolicy']}}"                    IGMP Interface Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['route_control_profile'] != "" %}
    # Route Profile
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsBDToProfile
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Route Profile)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Route Profile)		values=False
    {% if config['l3out_for_route_profile'] == "yes" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDToProfile.attributes.tnL3extOutName}"  "{{config['l3out_for_route_profile']}}"                    L3Out for Route Profile not matching expected configuration                       values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDToProfile.attributes.tnRtctrlProfileName}"  "{{config['route_control_profile']}}"                 Route Profile not matching expected configuration                       values=False
    {% endif %}
    {% if config['is_bd_legacy'] == "yes" %}
    # Legacy Mode
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/accp
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Legacy Mode)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Legacy Mode)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAccP.attributes.encap}"  "vlan-{{config['legacy_bd_vlan']}}"                    Legacy Mode Encapsulation not matching expected configuration                       values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'arp_flood': {'descr': 'Enables ARP flooding',
               'enum': ['yes', 'no'],
               'mandatory': True,
               'source': 'workbook'},
 'description': {'descr': 'Description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'enablePim': {'dafault': 'no',
               'descr': 'Enables the Protocol Independent Multicast (PIM) protocol on the BD',
               'enum': ['yes', 'no'],
               'mandatory': False,
               'source': 'workbook'},
 'endpoint_data_plane_learning': {'default': 'yes',
                                  'descr': 'Enables or disables endpoint dataplane learning',
                                  'enum': ['yes', 'no'],
                                  'mandatory': False,
                                  'source': 'workbook'},
 'endpoint_retention_policy': {'default': 'None',
                               'descr': 'Endpoint retention policy name',
                               'length': [1, 64],
                               'mandatory': False,
                               'regex': {'exact_match': False,
                                         'pattern': '[a-zA-Z0-9_.:-]+'},
                               'source': 'workbook',
                               'type': 'str'},
 'igmpInterfacePolicy': {'default': 'None',
                         'descr': 'IGMP Interface Policy Name. The template assumes the policy iscreated in the BD Tenant',
                         'length': [1, 64],
                         'mandatory': False,
                         'regex': {'exact_match': False,
                                   'pattern': '[a-zA-Z0-9_.:-]+'},
                         'source': 'workbook',
                         'type': 'str'},
 'igmp_snoop_policy': {'default': 'None',
                       'descr': 'IGMP Snooping Policy Name',
                       'length': [1, 64],
                       'mandatory': False,
                       'regex': {'exact_match': False,
                                 'pattern': '[a-zA-Z0-9_.:-]+'},
                       'source': 'workbook',
                       'type': 'str'},
 'is_bd_legacy': {'default': 'no',
                  'descr': 'When bridge domain legacy mode is specified, bridge domain encapsulation is used for all EPGs that reference the bridge domain',
                  'enum': ['yes', 'no'],
                  'mandatory': False,
                  'source': 'workbook'},
 'l2_unknown_unicast': {'descr': 'Forwarding parameter for L2 Unknown Unicast destinations',
                        'enum': ['flood', 'proxy'],
                        'mandatory': True,
                        'source': 'workbook'},
 'l3_unknown_multicast': {'descr': 'Forwarding parameter for Layer 3 unknown Multicast destinations"',
                          'enum': ['flood', 'opt-flood'],
                          'mandatory': True,
                          'source': 'workbook'},
 'l3out_for_route_profile': {'default': 'None',
                             'descr': 'Name of the L3Out the route-control-profile is applied',
                             'length': [1, 64],
                             'mandatory': False,
                             'regex': {'exact_match': False,
                                       'pattern': '[a-zA-Z0-9_.:-]+'},
                             'source': 'workbook',
                             'type': 'str'},
 'legacy_bd_vlan': {'default': 'None',
                    'descr': 'BD Encapsulation used if BD Legacy mode is used. Mandatory if BD Legacy mode is enabled',
                    'mandatory': False,
                    'range': [1, 4094],
                    'source': 'workbook',
                    'type': 'int'},
 'limit_ip_learning_to_subnet': {'default': 'yes',
                                 'descr': 'Limits IP address learning to the bridge domain subnets only',
                                 'enum': ['yes', 'no'],
                                 'mandatory': False,
                                 'source': 'workbook'},
 'multi_dest_flood': {'descr': 'The multiple destination forwarding method for L2 Multicast, Broadcast, and Link Layer traffic types',
                      'enum': ['bd-flood', 'drop', 'encap-flood'],
                      'mandatory': True,
                      'source': 'workbook'},
 'name': {'descr': 'Bridge Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'VRF Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'route_control_profile': {'default': 'None',
                           'descr': 'Name of the route-control-profile applied to the BD',
                           'length': [1, 64],
                           'mandatory': False,
                           'regex': {'exact_match': False,
                                     'pattern': '[a-zA-Z0-9_.:-]+'},
                           'source': 'workbook',
                           'type': 'str'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'unicast_routing': {'descr': 'Enable Unicast Routing',
                     'enum': ['yes', 'no'],
                     'mandatory': True,
                     'source': 'workbook'},
 'vrf': {'descr': 'name of the VRF this BD is associated with',
         'length': [1, 64],
         'mandatory': True,
         'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
         'source': 'workbook',
         'type': 'str'}}
```
## fvCtx.robot
### Template Description:
Verifies VRF configuration.

> The configuration of child objects like bgp_timers, ospf_timers, route_tag_policy, endpoint_retention policies

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
ospf_context_af | OSPF Context Policy Name | False |   | DAFE Excel Sheet
description | VRF description string | False |   | DAFE Excel Sheet
bgp_context_ipv4 | BGP IPv4 Address FAmily Context Policy name | False |   | DAFE Excel Sheet
ospf_timers | OSPF Timers Policy Name | False |   | DAFE Excel Sheet
vzAnyPrefGroup | Enable or Disbale vzAny Preferred Group Member | False |   | DAFE Excel Sheet
monitoring_policy | VRF parent Tenant Name | False |   | DAFE Excel Sheet
bgp_timers | BGP Timers Policy name | False |   | DAFE Excel Sheet
tenant | VRF parent Tenant Name | True |   | DAFE Excel Sheet
bgp_context_ipv6 | BGP IPv6 Address FAmily Context Policy name | False |   | DAFE Excel Sheet
dns_label | DNS Label Name | False |   | DAFE Excel Sheet
endpoint_retention_policy | Endpoint Retention Policy name | False |   | DAFE Excel Sheet
name | VRF Name | True |   | DAFE Excel Sheet
golf_opflex_mode | Boolean determining if GOLF Opflex mode is used, only relevant for template logic, do not match an ACI class or attribute | False |   | DAFE Excel Sheet
pref_group | Preferred Group Member, allows communications between EPGs in the group without a contract | False | disabled | DAFE Excel Sheet
policy_enforcement_direction | Policy Control Enforcement direction | False | ingress | DAFE Excel Sheet
nameAlias | VRF Name Alias | False | None | DAFE Excel Sheet
golf_vrf_name | VRF Name has pushed through Oplex to Opflex neighbor | False |   | DAFE Excel Sheet
route_tag_policy | Route Tag Policy Name | False |   | DAFE Excel Sheet
policy_enforcement | Policy Control Enforcement Preference | False | enforced | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'policy_enforcement' not in config %}
  {% set x=config.__setitem__('policy_enforcement', 'enforced') %}
{% elif config['policy_enforcement'] not in ['enforced', 'unenforced'] %}
  {% set x=config.__setitem__('policy_enforcement', 'enforced') %}
{% endif %}
{% if 'policy_enforcement_direction' not in config %}
  {% set x=config.__setitem__('policy_enforcement_direction', 'ingress') %}
{% elif config['policy_enforcement_direction'] not in ['ingress', 'egress'] %}
  {% set x=config.__setitem__('policy_enforcement_direction', 'ingress') %}
{% endif %}
{% if 'bgp_timers' not in config %}
  {% set x=config.__setitem__('bgp_timers', '') %}
{% endif %}
{% if 'ospf_timers' not in config %}
  {% set x=config.__setitem__('ospf_timers', '') %}
{% endif %}
{% if 'route_tag_policy' not in config %}
  {% set x=config.__setitem__('route_tag_policy', '') %}
{% endif %}
{% if 'monitoring_policy' not in config %}
  {% set x=config.__setitem__('monitoring_policy', '') %}
{% endif %}
{% if 'endpoint_retention_policy' not in config %}
  {% set x=config.__setitem__('endpoint_retention_policy', '') %}
{% endif %}
{% if 'dns_label' not in config %}
  {% set x=config.__setitem__('dns_label', '') %}
{% endif %}
{% if 'golf_vrf_name' not in config %}
  {% set x=config.__setitem__('golf_vrf_name', '') %}
{% endif %}
{% if 'bgp_context_ipv4' not in config %}
  {% set x=config.__setitem__('bgp_context_ipv4', '') %}
{% endif %}
{% if 'bgp_context_ipv6' not in config %}
  {% set x=config.__setitem__('bgp_context_ipv6', '') %}
{% endif %}
{% if 'ospf_context_af' not in config %}
  {% set x=config.__setitem__('ospf_context_af', '') %}
{% endif %}
{% if 'golf_opflex_mode' not in config %}
  {% set x=config.__setitem__('golf_opflex_mode', '') %}
{% endif %}
{% if 'golf_vrf_name' not in config %}
  {% set x=config.__setitem__('golf_vrf_name', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
Verify ACI VRF Configuration - Tenant {{config['tenant']}}, VRF {{config['name']}}
    [Documentation]   Verifies that ACI VRF '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - VRF Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Policy Enforcement: {{config['policy_enforcement']}}
    ...  - Policy Enforcement Direction: {{config['policy_enforcement_direction']}}
    {% if config['bgp_timers'] != "" %}
    ...  - BGP Timers: {{config['bgp_timers']}}
    {% endif %}
    {% if config['ospf_timers'] != "" %}
    ...  - OSPF Timers: {{config['ospf_timers']}}
    {% endif %}
    {% if config['route_tag_policy'] != "" %}
    ...  - Route Tag Policy: {{config['route_tag_policy']}}
    {% endif %}
    ...  - Monitoring Policy: {{config['monitoring_policy']}}
    {% if config['endpoint_retention_policy'] != "" %}
    ...  - Endpoint Retention Policy: {{config['endpoint_retention_policy']}}
    {% endif %}
    {% if config['dns_label'] != "" %}
    ...  - DNS Label: {{config['dns_label']}}
    {% endif %}
    {% if config['bgp_context_ipv4'] != "" %}
    ...  - BGP IPv4 Context Policy Name: {{config['bgp_context_ipv4']}}
    {% endif %}
    {% if config['bgp_context_ipv6'] != "" %}
    ...  - BGP IPv6 Context Policy Name: {{config['bgp_context_ipv6']}}
    {% endif %}
    ...  - GOLF Opflex Mode: {{config['golf_opflex_mode']}}
    ...  - GOLF VRF Name: {{config['golf_vrf_name']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve VRF
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvCtx.attributes.name}   {{config['name']}}      Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.nameAlias}"  "{{config['nameAlias']}}"             Name alias not matching expected configuration                       values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.descr}"  "{{config['description']}}"               Description not matching expected configuration                values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfPref}"  "{{config['policy_enforcement']}}"     Policy Control Enforcement Preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfDir}"  "{{config['policy_enforcement_direction']}}"     Policy Control Enforcement Direction not matching expected configuration                values=False
    {% if config['bgp_timers'] != "" %}
    # BGP Timers
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsbgpCtxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP Timer)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP Timer)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBgpCtxPol.attributes.tnBgpCtxPolName}"  "{{config['bgp_timers']}}"             BGP Timer not matching expected configuration                       values=False
    {% endif %}
    {% if config['ospf_timers'] != "" %}
    # OSPF Timers
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsospfCtxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (OSPF Timer)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (OSPF Timer)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsOspfCtxPol.attributes.tnOspfCtxPolName}"  "{{config['ospf_timers']}}"             OSPF Timer not matching expected configuration                       values=False
    {% endif %}
    {% if config['route_tag_policy'] != "" %}
    # Route Tag Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToExtRouteTagPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Route Tag Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Route Tag Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToExtRouteTagPol.attributes.tnL3extRouteTagPolName}"  "{{config['route_tag_policy']}}"             Route Tag Policy not matching expected configuration                       values=False
    {% endif %}
    # Monitoring Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsCtxMonPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Monitoring Policy)		values=False
    {% if config['monitoring_policy'] != "" %}
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Monitoring Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxMonPol.attributes.tnMonEPGPolName}"  "{{config['monitoring_policy']}}"             Monitoring Policy not matching expected configuration                       values=False
    {% else %}
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Monitoring Policy not matching expected configuration		values=False
    {% endif %}
    {% if config['endpoint_retention_policy'] != "" %}
    # Endpoint Retention Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToEpRet
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Endpoint Retention Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Endpoint Retention Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToEpRet.attributes.tnFvEpRetPolName}"  "{{config['endpoint_retention_policy']}}"             Endpoint Retention Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['dns_label'] != "" %}
    # DNS Label
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/dnslbl-{{config['dns_label']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (DNS Label)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (DNS Label)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].dnsLbl.attributes.name}"  "{{config['dns_label']}}"             DNS Label not matching expected configuration                       values=False
    {% endif %}
    {% if config['bgp_context_ipv4'] != "" %}
    # BGP IPv4 Context Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToBgpCtxAfPol-[{{config['bgp_context_ipv4']}}]-ipv4-ucast
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP IPv4 Context Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP IPv4 Context Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToBgpCtxAfPol.attributes.tnBgpCtxAfPolName}"  "{{config['bgp_context_ipv4']}}"             BGP IPv4 Context Policy Name not matching expected configuration                       values=False
    {% endif %}
    {% if config['bgp_context_ipv6'] != "" %}
    # BGP IPv6 Context Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToBgpCtxAfPol-[{{config['bgp_context_ipv6']}}]-ipv6-ucast
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP IPv6 Context Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP IPv6 Context Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToBgpCtxAfPol.attributes.tnBgpCtxAfPolName}"  "{{config['bgp_context_ipv6']}}"             BGP IPv6 Context Policy Name not matching expected configuration                       values=False
    {% endif %}
    {% if config['golf_opflex_mode'] == "yes" %}
    # Golf 
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/globalctxname
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (GOLF VRF name)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (GOLF VRF name)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extGlobalCtxName.attributes.name}"  "{{config['golf_vrf_name']}}"             Golf VRF Name not matching expected configuration                       values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'bgp_context_ipv4': {'descr': 'BGP IPv4 Address FAmily Context Policy name',
                      'mandatory': False,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'bgp_context_ipv6': {'descr': 'BGP IPv6 Address FAmily Context Policy name',
                      'mandatory': False,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'bgp_timers': {'descr': 'BGP Timers Policy name',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'description': {'descr': 'VRF description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'dns_label': {'descr': 'DNS Label Name',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'endpoint_retention_policy': {'descr': 'Endpoint Retention Policy name',
                               'length': [1, 64],
                               'mandatory': False,
                               'regex': {'exact_match': False,
                                         'pattern': '[a-zA-Z0-9_.:-]+'},
                               'source': 'workbook',
                               'type': 'str'},
 'golf_opflex_mode': {'descr': 'Boolean determining if GOLF Opflex mode is used, only relevant for template logic, do not match an ACI class or attribute',
                      'enum': ['yes', 'no'],
                      'mandatory': False,
                      'source': 'workbook'},
 'golf_vrf_name': {'descr': 'VRF Name has pushed through Oplex to Opflex neighbor',
                   'length': [1, 64],
                   'mandatory': False,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'monitoring_policy': {'descr': 'VRF parent Tenant Name',
                       'length': [1, 64],
                       'mandatory': False,
                       'regex': {'exact_match': False,
                                 'pattern': '[a-zA-Z0-9_.:-]+'},
                       'source': 'workbook',
                       'type': 'str'},
 'name': {'descr': 'VRF Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'VRF Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'ospf_context_af': {'descr': 'OSPF Context Policy Name',
                     'mandatory': False,
                     'regex': {'exact_match': False,
                               'pattern': '[a-zA-Z0-9_.:-]+'},
                     'source': 'workbook',
                     'type': 'str'},
 'ospf_timers': {'descr': 'OSPF Timers Policy Name',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'policy_enforcement': {'default': 'enforced',
                        'descr': 'Policy Control Enforcement Preference',
                        'enum': ['enforced', 'unenforced'],
                        'mandatory': False,
                        'source': 'workbook'},
 'policy_enforcement_direction': {'default': 'ingress',
                                  'descr': 'Policy Control Enforcement direction',
                                  'enum': ['ingress', 'egress'],
                                  'mandatory': False,
                                  'source': 'workbook'},
 'pref_group': {'default': 'disabled',
                'descr': 'Preferred Group Member, allows communications between EPGs in the group without a contract',
                'enum': ['enabled', 'disabled'],
                'mandatory': False,
                'source': 'workbook'},
 'route_tag_policy': {'descr': 'Route Tag Policy Name',
                      'length': [1, 64],
                      'mandatory': False,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'tenant': {'descr': 'VRF parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'vzAnyPrefGroup': {'descr': 'Enable or Disbale vzAny Preferred Group Member',
                    'enum': ['enabled', 'disabled'],
                    'mandatory': False,
                    'source': 'workbook'}}
```
## fvRsBDToOut.robot
### Template Description:
Verifies Bridge Domain L3Out Association configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
l3out_name | Name of the L3OUT associated to the BD | True |   | DAFE Excel Sheet
tenant | Bridge Domain parent tenant name | True |   | DAFE Excel Sheet
bd_name | Bridge Domain Name | True |   | DAFE Excel Sheet


### Template Body:
```
Verify ACI BD L3Out Configuration - Tenant {{config['tenant']}}, BD {{config['bd_name']}}, L3Out {{config['l3out_name']}}
    [Documentation]   Verifies that ACI BD L3Out '{{config['l3out_name']}}' under tenant '{{config['tenant']}}', BD '{{config['bridge_domain']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['bd_name']}}
    ...  - Associated L3Out: {{config['l3out_name']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bd_name']}}/rsBDToOut-{{config['l3out_name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		L3Out not associated with BD		values=False
	Should Be Equal as Strings      ${return.payload[0].fvRsBDToOut.attributes.tnL3extOutName}   {{config['l3out_name']}}      Failure retreiving configuration		                          values=False


```
### Template Data Validation Model:
```json
{'bd_name': {'descr': 'Bridge Domain Name',
             'length': [1, 64],
             'mandatory': True,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'workbook',
             'type': 'str'},
 'l3out_name': {'descr': 'Name of the L3OUT associated to the BD',
                'length': [1, 64],
                'mandatory': True,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'tenant': {'descr': 'Bridge Domain parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvRsDomAtt.robot
### Template Description:
Verifies EPG association of Physical or VMware VMM Domain

If not specified the deployment immediacy will default to "on-demand"
If not specified the resolution immediacy will default to "on-demand" (not applicable for physical domain)

> The Tenant, Application Profile and EPG must pre-exist.
> The configuration of domains are not verified by this template

If the EPG is associated to a VMware VMM Domain the resulting DVS port-group are assumed to have the following default properties:
  * allowPromiscuous="reject" 
  * forgedTransmits="reject" 
  * macChanges="reject"
  * switchingMode="native"


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
epg_name | EPG name | True | None | DAFE Excel Sheet
domainType | Domain Type | True | None | DAFE Excel Sheet
domainName | Domain Name the EPG is associated to | True | None | DAFE Excel Sheet
app_profile | EPG parent Application Profile Name | True | None | DAFE Excel Sheet
deployImedcy | Deployement Immedicay | False | lazy | DAFE Excel Sheet
tenant | EPG parent Tenant Name | True | None | DAFE Excel Sheet
staticVlanForVmm | Static VLAN id for VMM | False | None | DAFE Excel Sheet
netflowPref | Netflow preference for VMware DVS | False | None | DAFE Excel Sheet
resImedcy | Resoluton Immediacy | False | lazy | DAFE Excel Sheet


### Template Body:
```
{% if 'netflowPref' not in config %}
  {% set x=config.__setitem__('netflowPref', 'disabled') %}
{% elif config['netflowPref'] not in ['enabled', 'disabled'] %}
  {% set x=config.__setitem__('netflowPref', 'disabled') %}
{% endif %}
{% if 'staticVlanForVmm' not in config or config['staticVlanForVmm'] == ""  %}
  {% set x=config.__setitem__('staticVlanForVmm', 'unknown') %}
{% endif %}
{% if 'deployImedcy' not in config %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% elif config['deployImedcy'] not in ['immediate', 'lazy'] %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% endif %}
{% if 'resImedcy' not in config %}
  {% set x=config.__setitem__('resImedcy', 'lazy') %}
{% elif config['resImedcy'] not in ['immediate', 'lazy', 'pre-provision'] %}
  {% set x=config.__setitem__('resImedcy', 'lazy') %}
{% endif %}
{% if config['domainType'] == "vmm_vmware" %}
  {% set tDn %}uni/vmmp-VMware/dom-{{config['domainName']}}{% endset %}
{% else %}
  {% set tDn %}uni/phys-{{config['domainName']}}{% endset %}
{% endif %}
Verify ACI EPG Domain Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['epg_name']}}, Domain {{config['domainName']}}
    [Documentation]   Verifies that ACI EPG Domain association for '{{config['epg_name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG name: {{config['epg_name']}}
    ...  - Domain Name: {{config['domainName']}}
    ...  - Domain Type: {{config['domainType']}}
    ...  - Deployment Immediacy: {{config['deployImedcy']}}
    ...  - Resolution Immediacy: {{config['resImedcy']}}
    {% if config['domainType'] == "vmm_vmware" %}
    ...  - DVS Switching Mode: native
    ...  - DVS Netflow Preference: {{config['netflowPref']}}
    ...  - DVS Static Encapsulation: {{config['staticVlanForVmm']}}
    ...  - DVS Allow Promiscuous: reject
    ...  - DVS Forge Transmits: reject
    ...  - DVS Mac Changes: reject
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['epg_name']}}/rsdomAtt-[{{tDn}}]
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=vmmSecP
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Domain not associated with EPG		values=False
	  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.tDn}"   "{{tDn}}"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.instrImedcy}"  "{{config['deployImedcy']}}"               Deployment Immediacy not matching expected configuration                values=False
    {% if config['domainType'] == "vmm_vmware" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.resImedcy}"  "{{config['resImedcy']}}"                    Resolution Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.switchingMode}"  "native"                                 DVS switching mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.netflowPref}"  "{{config['netflowPref']}}"                DVS netflow preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.encap}"  "{{config['staticVlanForVmm']}}"                 DVS static encapsulation not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.allowPromiscuous}"  "reject"          DVS allow promiscuous not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.forgedTransmits}"  "reject"           DVS forged transmits not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.macChanges}"  "reject"                DVS mac changes not matching expected configuration                values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'app_profile': {'default': 'None',
                 'descr': 'EPG parent Application Profile Name',
                 'length': [1, 64],
                 'mandatory': True,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'deployImedcy': {'default': 'lazy',
                  'descr': 'Deployement Immedicay',
                  'enum': ['lazy', 'immediate'],
                  'mandatory': False,
                  'source': 'workbook'},
 'domainName': {'default': 'None',
                'descr': 'Domain Name the EPG is associated to',
                'length': [1, 64],
                'mandatory': True,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'domainType': {'default': 'None',
                'descr': 'Domain Type',
                'enum': ['physical', 'vmm_vmware'],
                'mandatory': True,
                'source': 'workbook'},
 'epg_name': {'default': 'None',
              'descr': 'EPG name',
              'length': [1, 64],
              'mandatory': True,
              'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
              'source': 'workbook',
              'type': 'str'},
 'netflowPref': {'default': 'None',
                 'descr': 'Netflow preference for VMware DVS',
                 'enum': ['disabled', 'enabled'],
                 'mandatory': False,
                 'source': 'workbook'},
 'resImedcy': {'default': 'lazy',
               'descr': 'Resoluton Immediacy',
               'enum': ['lazy', 'immediate', 'pre-provision'],
               'mandatory': False,
               'source': 'workbook'},
 'staticVlanForVmm': {'default': 'None',
                      'descr': 'Static VLAN id for VMM',
                      'mandatory': False,
                      'range': [1, 4094],
                      'source': 'workbook',
                      'type': 'int'},
 'tenant': {'default': 'None',
            'descr': 'EPG parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvSubnet.robot
### Template Description:
Verifies Bridge Domain Subnet configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
subnet_scope | Subnet scope | True | None | DAFE Excel Sheet
description | Subnet Description string | False | None | DAFE Excel Sheet
route_control_profile | Route-Control Profile Name associated to this subnet | False | None | DAFE Excel Sheet
ndRAprefixPolicy | ND RA Prefix Policy Name | False | None | DAFE Excel Sheet
is_primary_address | Defines if Subnet is the primary subnet on this BD | False | no | DAFE Excel Sheet
is_virtual_ip | Defines if Subnet is configured as Virtual IP on this BD | False | no | DAFE Excel Sheet
subnet_control | Subnet control IGMP Querier and or No Default SVI Gateway | False | None | DAFE Excel Sheet
tenant | Parent Tenant Name | True | None | DAFE Excel Sheet
bridge_domain | Parent Bridge Domain Name | True | None | DAFE Excel Sheet
l3out_for_route_control | L3OUT to which the Route-control Profile will be applied to | False | None | DAFE Excel Sheet
bd_subnet | BD IP Address in the form of IP/Mask | True | None | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'is_primary_address' not in config %}
  {% set x=config.__setitem__('is_primary_address', 'no') %}
{% elif config['is_primary_address'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('is_primary_address', 'no') %}
{% endif %}
{% if 'is_virtual_ip' not in config %}
  {% set x=config.__setitem__('is_virtual_ip', 'no') %}
{% elif config['is_virtual_ip'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('is_virtual_ip', 'no') %}
{% endif %}
{% if 'l3out_for_route_control' not in config %}
  {% set x=config.__setitem__('l3out_for_route_control', '') %}
{% endif %}
{% if 'route_control_profile' not in config %}
  {% set x=config.__setitem__('route_control_profile', '') %}
{% endif %}
{% if 'ndRAprefixPolicy' not in config %}
  {% set x=config.__setitem__('ndRAprefixPolicy', '') %}
{% endif %}
Verify ACI BD Subnet Configuration - Tenant {{config['tenant']}}, BD {{config['bridge_domain']}}, Subnet {{config['bd_subnet']}}
    [Documentation]   Verifies that ACI BD Subnet '{{config['bd_subnet']}}' under tenant '{{config['tenant']}}', BD '{{config['bridge_domain']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['bridge_domain']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
  	...  - Subnet: {{config['bd_subnet']}}
    ...  - Subnet Scope: {{config['subnet_scope']}}
    ...  - Primary IP Address: {{config['is_primary_address']}}
    ...  - Virtual IP Address: {{config['is_virtual_ip']}}
    ...  - Subnet Control: {{config['subnet_control']}}
    {% if config['route_control_profile'] != "" %}
    ...  - Route Profile: {{config['route_control_profile']}}
    ...  - L3Out for Route Profile: {{config['l3out_for_route_control']}}
    {% endif %}
  	...  - ND RA Prefix Policy Name: {{config['ndRAprefixPolicy']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bridge_domain']}}/subnet-[{{config['bd_subnet']}}]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		BD Subnet not configured		values=False
    Should Be Equal as Strings      ${return.payload[0].fvSubnet.attributes.ip}   {{config['bd_subnet']}}      Failure retreiving configuration		                          values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                       values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.scope}"  "{{config['subnet_scope']}}"                   Subnet Scope not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.preferred}"  "{{config['is_primary_address']}}"         Primary IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.virtual}"  "{{config['is_virtual_ip']}}"                Virtual IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.ctrl}"  "{{config['subnet_control']}}"                  Subnet Control not matching expected configuration                       values=False
    {% if config['route_control_profile'] != "" %}
    # Route Profile
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bridge_domain']}}/subnet-[{{config['bd_subnet']}}]/rsBDSubnetToProfile
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Route Profile)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Route Profile)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDSubnetToProfile.attributes.tnL3extOutName}"  "{{config['l3out_for_route_control']}}"                    L3Out for Route Profile not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDSubnetToProfile.attributes.tnRtctrlProfileName}"  "{{config['route_control_profile']}}"                 Route Profile not matching expected configuration                       values=False
    {% endif %}
    {% if config['ndRAprefixPolicy'] != "" %}
    # ND RA Prefix Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bridge_domain']}}/subnet-[{{config['bd_subnet']}}]/rsNdPfxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (ND RA Prefix Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (ND RA Prefix Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsNdPfxPol.attributes.tnNdPfxPolName}"  "{{config['ndRAprefixPolicy']}}"                    ND RA Prefix Policy not matching expected configuration                       values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'bd_subnet': {'default': 'None',
               'descr': 'BD IP Address in the form of IP/Mask',
               'mandatory': True,
               'source': 'workbook',
               'type': 'str'},
 'bridge_domain': {'default': 'None',
                   'descr': 'Parent Bridge Domain Name',
                   'length': [1, 64],
                   'mandatory': True,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'description': {'default': 'None',
                 'descr': 'Subnet Description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'is_primary_address': {'default': 'no',
                        'descr': 'Defines if Subnet is the primary subnet on this BD',
                        'enum': ['yes', 'no'],
                        'mandatory': False,
                        'source': 'workbook'},
 'is_virtual_ip': {'default': 'no',
                   'descr': 'Defines if Subnet is configured as Virtual IP on this BD',
                   'enum': ['yes', 'no'],
                   'mandatory': False,
                   'source': 'workbook'},
 'l3out_for_route_control': {'default': 'None',
                             'descr': 'L3OUT to which the Route-control Profile will be applied to',
                             'length': [1, 64],
                             'mandatory': False,
                             'regex': {'exact_match': False,
                                       'pattern': '[a-zA-Z0-9_.:-]+'},
                             'source': 'workbook',
                             'type': 'str'},
 'ndRAprefixPolicy': {'default': 'None',
                      'descr': 'ND RA Prefix Policy Name',
                      'length': [1, 64],
                      'mandatory': False,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'route_control_profile': {'default': 'None',
                           'descr': 'Route-Control Profile Name associated to this subnet',
                           'length': [1, 64],
                           'mandatory': False,
                           'regex': {'exact_match': False,
                                     'pattern': '[a-zA-Z0-9_.:-]+'},
                           'source': 'workbook',
                           'type': 'str'},
 'subnet_control': {'default': 'None',
                    'descr': 'Subnet control IGMP Querier and or No Default SVI Gateway',
                    'enum': ['querier',
                             'no-default-gateway',
                             'querier,no-default-gateway',
                             'nd',
                             'nd,no-default-gateway'],
                    'mandatory': False,
                    'source': 'workbook'},
 'subnet_scope': {'default': 'None',
                  'descr': 'Subnet scope',
                  'enum': ['private',
                           'public',
                           'shared',
                           'private,shared',
                           'public,shared'],
                  'mandatory': True,
                  'source': 'workbook'},
 'tenant': {'default': 'None',
            'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvTenant.robot
### Template Description:
Verifies tenant configuration including associated security domains.

Given the way the DAFE excel is build will a test case be generated per security domain.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
mon_policy | Monitoring Policy name | False |   | DAFE Excel Sheet
security_domain | Security Domain | False |   | DAFE Excel Sheet
name | Tenant Name | True |   | DAFE Excel Sheet
nameAlias | Tenant Name Alias | False | None | DAFE Excel Sheet
description | Description string | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'security_domain' not in config %}
  {% set x=config.__setitem__('security_domain', '') %}
{% endif %}
{% if 'Description' not in config %}
  {% set x=config.__setitem__('Description', '') %}
{% endif %}
{% if 'mon_policy' not in config %}
  {% set x=config.__setitem__('mon_policy', '') %}
{% endif %}
{% if config['security_domain'] != "" %}
Verify ACI Tenant Configuration - Tenant {{config['name']}}, Security Domain {{config['security_domain']}}
{% else %}
Verify ACI Tenant Configuration - Tenant {{config['name']}}
{% endif %}
    [Documentation]   Verifies that ACI tenant '{{config['name']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['name']}}
    {% if 'nameAlias' not in config %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if 'description' not in config %}
    ...  - Description: {{config['description']}}
    {% endif %}
    {% if config['security_domain'] != "" %}
    ...  - Security Domain: {{config['security_domain']}}
    {% endif %}
    {% if config['mon_policy'] != "" %}
    ...  - Monitoring Policy: {{config['mon_policy']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant
    # Retrieve Tenant
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['name']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Tenant parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.dn}     uni/tn-{{config['name']}}       Failure retreiving configuration                    values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.name}   {{config['name']}}              Failure retreiving configuration                    values=False
    {% if 'nameAlias' not in config %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvTenant.attributes.nameAlias}"  "{{config['nameAlias']}}"   Name alias not matching expected configuration     values=False
    {% endif %}
    {% if 'description' not in config %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvTenant.attributes.descr}"  "{{config['description']}}"   Description not matching expected configuration     values=False
    {% endif %}
    {% if config['security_domain'] != "" %}
    # Verify Security Domain association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['name']}}/domain-{{config['security_domain']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Security Domain associated with tenant		values=False
    {% endif %}
    {% if config['mon_policy'] != "" %}
    # Verify Monitoring Policy association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['name']}}/rsTenantMonPol
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsTenantMonPol.attributes.tnMonEPGPolName}"   "{{config['mon_policy']}}"              Monitoring policy not matching expected configuration                    values=False
    {% endif %}

```
### Template Data Validation Model:
```json
{'description': {'descr': 'Description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'mon_policy': {'descr': 'Monitoring Policy name',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'name': {'descr': 'Tenant Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'Tenant Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'security_domain': {'descr': 'Security Domain',
                     'length': [1, 64],
                     'mandatory': False,
                     'regex': {'exact_match': False,
                               'pattern': '[a-zA-Z0-9_.:-]+'},
                     'source': 'workbook',
                     'type': 'str'}}
```
## fvnsEncapBlk.robot
### Template Description:
Verifies VLAN Pool Encapsulation Block configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
start_vlan | Encap Block start VLAN Range | True |   | DAFE Excel Sheet
role | Encap Block Role | True |   | DAFE Excel Sheet
poolAllocMode | Allocation mode of the parent pool | True |   | DAFE Excel Sheet
alloc_mode | Encap Block Allocation Mode | True |   | DAFE Excel Sheet
vlan_pool | Parent VLAN pool name | True |   | DAFE Excel Sheet
stop_vlan | Encap Block stop VLAN Range | True |   | DAFE Excel Sheet


### Template Body:
```
Verify ACI VLAN Pool Encap Block Configuration - VLAN Pool {{config['vlan_pool']}}, Encapsulation Block 'VLAN {{config['start_vlan']}}-{{config['stop_vlan']}}
    [Documentation]   Verifies that VLAN Encapsulation Block 'VLAN {{config['start_vlan']}}-{{config['stop_vlan']}} are configured with the expected parameters:
    ...  - VLAN Pool Name: {{config['vlan_pool']}}
    ...  - VLAN Pool Allocation Mode: {{config['poolAllocMode']}}
	...  - Encapsulation Block Mode: {{config['alloc_mode']}}
    ...  - Encapsulation Block Role: {{config['role']}}
    ...  - Encapsulation Block Start: vlan-{{config['start_vlan']}}
    ...  - Encapsulation Block Stop: vlan-{{config['stop_vlan']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[{{config['vlan_pool']}}]-{{config['poolAllocMode']}}/from-[vlan-{{config['start_vlan']}}]-to-[vlan-{{config['stop_vlan']}}]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "xml"
    Should Be Equal as Integers     @{return}[0]    200		Failure executing API call		values=False
    ${xml_root} =  Parse XML  @{return}[1]
    Should Be Equal  ${xml_root.tag}  imdata    Failure retreiving configuration        values=False
    # Verify Configuration Parameters
	Element Attribute Should Be  ${xml_root}  totalCount  1
    Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  allocMode  {{config['alloc_mode']}}      xpath=fvnsEncapBlk      message=Block Allocation Mode not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  from   vlan-{{config['start_vlan']}}     xpath=fvnsEncapBlk      message=Start VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  to   vlan-{{config['stop_vlan']}}        xpath=fvnsEncapBlk      message=Stop VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  role   {{config['role']}}                xpath=fvnsEncapBlk      message=Block Role not matching expected configuration


```
### Template Data Validation Model:
```json
{'alloc_mode': {'descr': 'Encap Block Allocation Mode',
                'enum': ['static', 'dynamic', 'inherit'],
                'mandatory': True,
                'source': 'workbook'},
 'poolAllocMode': {'descr': 'Allocation mode of the parent pool',
                   'enum': ['static', 'dynamic'],
                   'mandatory': True,
                   'source': 'workbook'},
 'role': {'descr': 'Encap Block Role',
          'enum': ['external', 'internal'],
          'mandatory': True,
          'source': 'workbook'},
 'start_vlan': {'descr': 'Encap Block start VLAN Range',
                'mandatory': True,
                'range': [1, 4094],
                'source': 'workbook',
                'type': 'int'},
 'stop_vlan': {'descr': 'Encap Block stop VLAN Range',
               'mandatory': True,
               'range': [1, 4094],
               'source': 'workbook',
               'type': 'int'},
 'vlan_pool': {'descr': 'Parent VLAN pool name',
               'length': [1, 64],
               'mandatory': True,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'}}
```
## fvnsVlanInstP.robot
### Template Description:
Verifies VLAN Pool configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
alloc_mode | VLAN Pool Allocation Mode | True |   | DAFE Excel Sheet
name | VLAN Pool Name | True |   | DAFE Excel Sheet


### Template Body:
```
Verify ACI VLAN Pool Configuration - VLAN Pool {{config['name']}}
    [Documentation]   Verifies that VLAN Pool '{{config['name']}}' are configured with the expected parameters:
    ...  - VLAN Pool Name: {{config['name']}}
    ...  - Allocation Mode: {{config['alloc_mode']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[{{config['name']}}]-{{config['alloc_mode']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvnsVlanInstP.attributes.name}   {{config['name']}}                Failure retreiving configuration        values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvnsVlanInstP.attributes.allocMode}   {{config['alloc_mode']}}     Allocation mode not matching expected configuration                values=False        values=False


```
### Template Data Validation Model:
```json
{'alloc_mode': {'descr': 'VLAN Pool Allocation Mode',
                'enum': ['static', 'dynamic'],
                'mandatory': True,
                'source': 'workbook'},
 'name': {'descr': 'VLAN Pool Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## infraAccBndlGrp.robot
### Template Description:
Verifies Leaf/Spine Interface Policy Group configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
switch_type | Defines or Leaf or Spine Interface Policy-Group | True |   | DAFE Excel Sheet
name | Name of the Interface Policy-Group | True |   | DAFE Excel Sheet
interface_policy_group_type | Defines the type of Interface Policy-Group Access, Port-Channel, virtual Port-Channel | True |   | DAFE Excel Sheet
lacp_pol | Name of a LACP Interface Policy | False |   | DAFE Excel Sheet
description | Description string | False |   | DAFE Excel Sheet
link_pol | Name of a Link Interface Policy | False |   | DAFE Excel Sheet
aaep |  Name of an Access Attachable Entity Profile | False |   | DAFE Excel Sheet
stp_pol | Name of a Spanning-Tree Interface Policy | False |   | DAFE Excel Sheet
lldp_pol | Name of a LLDP Interface Policy | False |   | DAFE Excel Sheet
cdp_pol | Name of a CDP Interface Policy | False |   | DAFE Excel Sheet
l2_int_pol | NAme of a L2 Interface Policy | False |   | DAFE Excel Sheet
storm_pol | Name of a Storm Control Interface Policy | False |   | DAFE Excel Sheet
mcp_pol | Name of a MCP Interface Policy | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if config['switch_type'] == "leaf" %}
	{% if config['interface_policy_group_type'] == "vPC" %}
		{% set tag = 'infraAccBndlGrp' %}
		{% set uri_tag = 'accbundle' %}
		{% set bundle = 'lagT="node"' %}
	{% elif config['interface_policy_group_type'] == "PC" %}
		{% set tag = 'infraAccBndlGrp' %}
		{% set uri_tag = 'accbundle' %}
		{% set bundle = 'lagT="link"' %}
	{% elif config['interface_policy_group_type'] == "Access" %}
		{% set tag = 'infraAccPortGrp' %}
		{% set uri_tag = 'accportgrp' %}
		{% set bundle = '' %}
	{% endif %}
{% endif %}
{% if config['switch_type'] == "leaf" %}
Verify ACI Leaf Interface Policy Group Configuration - Policy Group Name {{config['name']}}
    [Documentation]   Verifies that Leaf Interface Policy Group '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Group Name:  {{config['name']}}
    ...  - Policy Group Type:  {{config['interface_policy_group_type']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - LLDP Policy: {{config['lldp_pol']}}
    ...  - STP Policy: {{config['stp_pol']}}
    ...  - L2 Interface Policy: {{config['l2_int_pol']}}
    ...  - CDP Policy: {{config['cdp_pol']}}
    ...  - MCP Policy: {{config['mcp_pol']}}
    ...  - AAEP: {{config['aaep']}}
    ...  - Storm Control Policy: {{config['storm_pol']}}
    ...  - Link Policy: {{config['link_pol']}}
	{% if config['interface_policy_group_type'] != "Access" %}
    ...  - Port Channel Policy: {{config['lacp_pol']}}
	{% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy-group
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/funcprof/{{uri_tag}}-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy Group does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].{{tag}}.attributes.name}		{{config['name']}}			Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure		Should Be Equal as Strings     "${return.payload[0].{{tag}}.attributes.descr}"	"{{config['description']}}"		Description not matching expected configuration                 values=False
    {% endif %}
	# Iterate through interface policies
	${lldp_found} =  Set Variable  False
	: FOR  ${if_policy}  IN  @{return.payload[0].{{tag}}.children}
	\  Set Test Variable  ${policy_found}	False
		# LLDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLldpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLldpIfPol.attributes.tnLldpIfPolName}"	"{{config['lldp_pol']}}"		LLDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# STP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStpIfPol.attributes.tnStpIfPolName}"	"{{config['stp_pol']}}"			STP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# L2 Interface policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsL2IfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsL2IfPol.attributes.tnL2IfPolName}"	"{{config['l2_int_pol']}}"			L2 Interface Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# CDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsCdpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsCdpIfPol.attributes.tnCdpIfPolName}"	"{{config['cdp_pol']}}"			CDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# MCP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsMcpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsMcpIfPol.attributes.tnMcpIfPolName}"	"{{config['mcp_pol']}}"			MCP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# AAEP
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsAttEntP.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsAttEntP.attributes.tDn}"	"uni/infra/attentp-{{config['aaep']}}"		AAEP not matching expected configuration					values=False
	\  ...  AND  continue for loop
		# Storm Control Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStormctrlIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName}"	"{{config['storm_pol']}}"		Storm Control Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# Link Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsHIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsHIfPol.attributes.tnFabricHIfPolName}"	"{{config['link_pol']}}"		Link Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
	{% if config['interface_policy_group_type'] != "Access" %}
		# LACP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLacpPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLacpPol.attributes.tnLacpLagPolName}"	"{{config['lacp_pol']}}"					Port Channel Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
	{% endif %}
{% elif config['switch_type'] == "spine" %}
Verify ACI Spine Interface Policy Group Configuration - Policy Group Name {{config['name']}}
    [Documentation]   Verifies that Spine Interface Policy Group '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Group Name:  {{config['name']}}
    ...  - Description: {{config['description']}}
    ...  - Link Policy: {{config['link_pol']}}
    ...  - CDP Policy: {{config['cdp_pol']}}
    ...  - AAEP: {{config['aaep']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy-group
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/funcprof/spaccportgrp-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy Group does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpAccPortGrp.attributes.name}		{{config['name']}}				Failure retreiving configuration    values=False
	Should Be Equal as Strings     "${return.payload[0].infraSpAccPortGrp.attributes.descr}"	"{{config['description']}}"		Description not matching expected configuration                 values=False
	# Iterate through interface policies
	: FOR  ${if_policy}  IN  @{return.payload[0].infraSpAccPortGrp.children}
	\  Set Test Variable  ${policy_found}	False
		# CDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist  ${if_policy.infraRsCdpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsCdpIfPol.attributes.tnCdpIfPolName}"	"{{config['cdp_pol']}}"			CDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# Link Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist  ${if_policy.infraRsHIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsHIfPol.attributes.tnFabricHIfPolName}"	"{{config['link_pol']}}"		Link Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# AAEP
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist  ${if_policy.infraRsAttEntP.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsAttEntP.attributes.tDn}"	"uni/infra/attentp-{{config['aaep']}}"		AAEP not matching expected configuration					values=False
	\  ...  AND  continue for loop
{% endif %}


```
### Template Data Validation Model:
```json
{'aaep': {'descr': ' Name of an Access Attachable Entity Profile',
          'length': [1, 64],
          'mandatory': False,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'cdp_pol': {'descr': 'Name of a CDP Interface Policy',
             'length': [1, 64],
             'mandatory': False,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'workbook',
             'type': 'str'},
 'description': {'descr': 'Description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'interface_policy_group_type': {'descr': 'Defines the type of Interface Policy-Group Access, Port-Channel, virtual Port-Channel',
                                 'enum': ['Access', 'vPC', 'PC'],
                                 'mandatory': True,
                                 'source': 'workbook'},
 'l2_int_pol': {'descr': 'NAme of a L2 Interface Policy',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'lacp_pol': {'descr': 'Name of a LACP Interface Policy',
              'length': [1, 64],
              'mandatory': False,
              'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
              'source': 'workbook',
              'type': 'str'},
 'link_pol': {'descr': 'Name of a Link Interface Policy',
              'length': [1, 64],
              'mandatory': False,
              'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
              'source': 'workbook',
              'type': 'str'},
 'lldp_pol': {'descr': 'Name of a LLDP Interface Policy',
              'length': [1, 64],
              'mandatory': False,
              'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
              'source': 'workbook',
              'type': 'str'},
 'mcp_pol': {'descr': 'Name of a MCP Interface Policy',
             'length': [1, 64],
             'mandatory': False,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'workbook',
             'type': 'str'},
 'name': {'descr': 'Name of the Interface Policy-Group',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'storm_pol': {'descr': 'Name of a Storm Control Interface Policy',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'stp_pol': {'descr': 'Name of a Spanning-Tree Interface Policy',
             'length': [1, 64],
             'mandatory': False,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'workbook',
             'type': 'str'},
 'switch_type': {'descr': 'Defines or Leaf or Spine Interface Policy-Group',
                 'enum': ['leaf', 'spine'],
                 'mandatory': True,
                 'source': 'workbook'}}
```
## infraAccPortP.robot
### Template Description:
Verifies Leaf/Spine Interface Profile configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
profile_type | Interface profile type | True |   | DAFE Excel Sheet
name | Interface profile name | True |   | DAFE Excel Sheet
nameAlias | Interface Profile Name Alias | False | None | DAFE Excel Sheet
description | Interface Profile description | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if config['profile_type'] == "leaf" %}
Verify ACI Leaf Interface Profile Configuration - Profile {{config['name']}}
    [Documentation]   Verifies that Leaf Interface Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraAccPortP.attributes.name}   {{config['name']}}      Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAccPortP.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAccPortP.attributes.nameAlias}"  "{{config['name_alias']}}"                    Name Alias not matching expected configuration                 values=False
    {% endif %}
{% elif config['profile_type'] == "spine" %}
Verify ACI Spine Interface Profile Configuration - Profile {{config['name']}}
    [Documentation]   Verifies that Spine Interface Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpAccPortP.attributes.name}   {{config['name']}}        Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSpAccPortP.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSpAccPortP.attributes.nameAlias}"  "{{config['name_alias']}}"                    Name Alias not matching expected configuration                 values=False
    {% endif %}
{% endif %}


```
### Template Data Validation Model:
```json
{'description': {'descr': 'Interface Profile description',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'descr': 'Interface profile name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'Interface Profile Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'profile_type': {'descr': 'Interface profile type',
                  'enum': ['leaf', 'spine'],
                  'mandatory': True,
                  'source': 'workbook'}}
```
## infraAttEntityP.robot
### Template Description:
Verifies Access Attachable Entity Profile configuration including enabling of infra VLAN.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
description | Description field | False |   | DAFE Excel Sheet
infra_vlan | Infrastrucuture VLAN Id | False |   | DAFE Excel Sheet
name | Name of the Access Attachable Entity Profile (AAEP)  | True |   | DAFE Excel Sheet
nameAlias | AAEP Name Alias | False | None | DAFE Excel Sheet
enable_infra_vlan | Boolean, checks if infra VLAN should be enabled on this AAEP. Used for template rendering only, it has no ACI MIT significance | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'enable_infra_vlan' not in config %}
  {% set x=config.__setitem__('enable_infra_vlan', '') %}
{% endif %}
{% if 'infra_vlan' not in config %}
  {% set x=config.__setitem__('infra_vlan', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
Verify ACI AAEP Configuration - AAEP {{config['name']}}
    [Documentation]   Verifies that AAEP '{{config['name']}}' are configured with the expected parameters:
	...  - AAEP Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
	...  - AAEP Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
	...  - Description: {{config['description']}}
    {% endif %}
    {% if config['enable_infra_vlan'] != "" %}
	...  - Enable Infrastructure VLAN: {{config['enable_infra_vlan']}}
    {% endif %}
    {% if config['enable_infra_vlan'] == "yes" %}
	...  - Infrastructure VLAN: {{config['infra_vlan']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsFuncToEpg
    ${return}  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraAttEntityP.attributes.name}   {{config['name']}}                            Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAttEntityP.attributes.nameAlias}"  "{{config['nameAlias']}}"               	Name alias not matching expected configuration                values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAttEntityP.attributes.descr}"  "{{config['description']}}"					Description not matching expected configuration               values=False
	{% endif %}
	{% if config['enable_infra_vlan'] == 'yes' %}
	# Check Infra VLAN
	Variable Should Exist  ${return.payload[0].infraAttEntityP.children}   Infrastructure VLAN not enabled, which are not matching expected configuration
	Should Be Equal as Strings  ${return.payload[0].infraAttEntityP.children[0].infraProvAcc.children[0].infraRsFuncToEpg.attributes.encap}  vlan-{{config['infra_vlan']}}	Infrastructure VLAN not matching expected configuration			values=False
	{% else %}
	Variable Should Not Exist  ${return.payload[0].infraAttEntityP.children}   Infrastructure VLAN enabled, which are not matching expected configuration
	{% endif %}


```
### Template Data Validation Model:
```json
{'description': {'descr': 'Description field',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'enable_infra_vlan': {'descr': 'Boolean, checks if infra VLAN should be enabled on this AAEP. Used for template rendering only, it has no ACI MIT significance',
                       'enum': ['yes', 'no'],
                       'mandatory': False,
                       'source': 'workbook'},
 'infra_vlan': {'descr': 'Infrastrucuture VLAN Id',
                'mandatory': False,
                'range': [1, 4094],
                'source': 'workbook',
                'type': 'int'},
 'name': {'descr': 'Name of the Access Attachable Entity Profile (AAEP) ',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'AAEP Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'}}
```
## infraAttEntityPRsDomP.robot
### Template Description:

Verifies Access Attachable Entity Profile domain association.

The template curretnyly supports the association with 
Physical , External Routed, External Bridged , VMWare VMM Domain


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
domain_type | Domain Type | True |   | DAFE Excel Sheet
aaep_name | Name of the Access Attachable Entity Profile (AAEP)  | True |   | DAFE Excel Sheet
domain_name | Name of the Domain  | True |   | DAFE Excel Sheet


### Template Body:
```
Verify ACI AAEP Domain Association Configuration - AAEP {{config['aaep_name']}}, Domain {{config['domain_name']}}
    [Documentation]   Verifies that AAEP '{{config['aaep_name']}}' domain association are configured with the expected parameters:
	...  - AAEP Name: {{config['aaep_name']}}
	...  - Domain Name: {{config['domain_name']}}
	...  - Domain Type: {{config['domain_type']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Define tDn
	{% if config['domain_type'] == 'physical' %}
	${tDn} =  Set Variable  uni/phys-{{config['domain_name']}}
	{% elif config['domain_type'] == 'external_l3' %}
	${tDn} =  Set Variable  uni/l3dom-{{config['domain_name']}}
	{% elif config['domain_type'] == 'external_l2' %}
	${tDn} =  Set Variable  uni/l2dom-{{config['domain_name']}}
	{% elif config['domain_type'] == 'vmm_vmware' %}
	${tDn} =  Set Variable  uni/vmmp-VMware/dom-{{config['domain_name']}}
	{% endif %}
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-{{config['aaep_name']}}/rsdomP-[${tDn}]
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Domain association not matching expected configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraRsDomP.attributes.tDn}   ${tDn}	tDn not matching expected configuration        values=False


```
### Template Data Validation Model:
```json
{'aaep_name': {'descr': 'Name of the Access Attachable Entity Profile (AAEP) ',
               'length': [1, 64],
               'mandatory': True,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'domain_name': {'descr': 'Name of the Domain ',
                 'length': [1, 64],
                 'mandatory': True,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'domain_type': {'descr': 'Domain Type',
                 'enum': ['physical',
                          'external_l3',
                          'external_l2',
                          'vmm_vmware'],
                 'mandatory': True,
                 'source': 'workbook'}}
```
## infraHPortS.robot
### Template Description:
Verifies Interface Selector configuration

> Parent Interface Profile must exist.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
from_port | Starting Port in the interface range | True | None | DAFE Excel Sheet
name | Interface Selector Name | True | None | DAFE Excel Sheet
to_port | Destination Port in the interface range | True | None | DAFE Excel Sheet
from_slot | Starting Slot in the interface range | True | None | DAFE Excel Sheet
description | Interface Selector description | False | None | DAFE Excel Sheet
interface_profile_type | Parent Inteface Profile Type | True | None | DAFE Excel Sheet
to_slot | Destination Slot in the interface range | True | None | DAFE Excel Sheet
port_block_description | Interface Policy-Group Name | False | None | DAFE Excel Sheet
interface_profile | Interface Profile Name | True | None | DAFE Excel Sheet
interface_polgroup_type | Type of the interface Policy-Group associated with the interface selector | True | None | DAFE Excel Sheet
interface_policy_group | Interface Policy-Group Name | True | None | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'port_block_description' not in config %}
  {% set x=config.__setitem__('port_block_description', '') %}
{% endif %}
{% if config['interface_polgroup_type'] == 'Access'%}
    {% set port_type = 'accportgrp' %}
{% elif config['interface_polgroup_type'] == 'vPC' or config['interface_polgroup_type'] == 'PC' %}
    {% set port_type = 'accbundle' %}
{% endif %}
{% if not config['fex_id'] or config['fex_id'] == "" %}
    {% set fex_id = '101' %}
{% endif %}
{% if config['interface_profile_type'] == "leaf" %}
Verify ACI Leaf Interface Selector Configuration - Interface Profile {{config['interface_profile']}}, Interface Selector {{config['name']}}
    [Documentation]   Verifies that ACI Leaf Interface Selector '{{config['name']}}' under '{{config['interface_profile']}}' are configured with the expected parameters
    ...  - Interface Profile Name:  {{config['interface_profile']}}
    ...  - Interface Selector Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Interface Selector Description: {{config['description']}}
    {% endif %}
    ...  - From Slot: {{config['from_slot']}}
    ...  - From Port: {{config['from_port']}}
    ...  - To Slot: {{config['to_slot']}}
    ...  - To Port: {{config['to_port']}}
    {% if config['port_block_description'] != "" %}
    ...  - Port Block Description: {{config['port_block_description']}}
    {% endif %}
    ...  - Associated Interface Policy Group: {{config['interface_policy_group']}}
    ...  - Associated Interface Policy Group Type: {{config['interface_polgroup_type']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   {{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraHPortS.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "{{config['to_port']}}"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "{{config['from_port']}}"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    {% if config['port_block_description'] != "" %}
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "{{config['port_block_description']}}"                                          Port Block Description not matching expected configuration                 values=False
    {% endif %}
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    {% if config['interface_policy_group'] != "" %}
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range/rsaccBaseGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/funcprof/{{port_type}}-{{config['interface_policy_group']}}        Interface Policy Group Association not matching expected configuration	    values=False
    {% endif %}
{% elif config['interface_profile_type'] == "fex" %}
Verify ACI FEX Interface Selector Configuration - Interface Profile {{config['interface_profile']}}, Interface Selector {{config['name']}}
    [Documentation]   Verifies that ACI FEX Interface Selector '{{config['name']}}' under '{{config['interface_profile']}}' are configured with the expected parameters
    ...  - Interface Profile Name:  {{config['interface_profile']}}
    ...  - Interface Selector Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Interface Selector Description: {{config['description']}}
    {% endif %}
    ...  - From Slot: {{config['from_slot']}}
    ...  - From Port: {{config['from_port']}}
    ...  - To Slot: {{config['to_slot']}}
    ...  - To Port: {{config['to_port']}}
    {% if config['port_block_description'] != "" %}
    ...  - Port Block Description: {{config['port_block_description']}}
    {% endif %}
    ...  - Associated FEX Profile: {{config['interface_policy_group']}}
    ...  - Associated FEX ID: {{fex_id}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   {{config['name']}}    Failure retreiving configuration    values=False
    {% if config['port_block_description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraHPortS.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "{{config['to_port']}}"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "{{config['from_port']}}"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    {% if config['port_block_description'] != "" %}
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "{{config['port_block_description']}}"                                          Port Block Description not matching expected configuration                 values=False
    {% endif %}
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    {% if config['interface_policy_group'] != "" %}
    # Verify FEX Profile associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range/rsaccBaseGrp
	${fex_pol}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${fex_pol.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${fex_pol.totalCount}    	1		Failure retreiving FEX Profile association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${fex_pol.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/fexprof-{{config['interface_policy_group']}}/fexbundle-{{config['interface_policy_group']}}      FEX Profile Association not matching expected configuration	    values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${fex_pol.payload[0].infraRsAccBaseGrp.attributes.fexId}    	{{fex_id}}         FEX ID not matching expected configuration	    values=False
    {% endif %}
{% elif config['interface_profile_type'] == "spine" %}
Verify ACI Spine Interface Selector Configuration - Interface Profile {{config['interface_profile']}}, Interface Selector {{config['name']}}
    [Documentation]   Verifies that ACI Spine Interface Selector '{{config['name']}}' under '{{config['interface_profile']}}' are configured with the expected parameters
    ...  - Interface Profile Name:  {{config['interface_profile']}}
    ...  - Interface Selector Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Interface Selector Description: {{config['description']}}
    {% endif %}
    ...  - From Slot: {{config['from_slot']}}
    ...  - From Port: {{config['from_port']}}
    ...  - To Slot: {{config['to_slot']}}
    ...  - To Port: {{config['to_port']}}
    {% if config['port_block_description'] != "" %}
    ...  - Port Block Description: {{config['port_block_description']}}
    {% endif %}
    ...  - Associated Interface Policy Group: {{config['interface_policy_group']}}
    ...  - Associated Interface Policy Group Type: {{config['interface_polgroup_type']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-{{config['interface_profile']}}/shports-{{config['name']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSHPortS.attributes.name}   {{config['name']}}   Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSHPortS.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraSHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "{{config['to_port']}}"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "{{config['from_port']}}"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    {% if config['port_block_description'] != "" %}
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "{{config['port_block_description']}}"                                          Port Block Description not matching expected configuration                 values=False
    {% endif %}
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    {% if config['interface_policy_group'] != "" %}
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-{{config['interface_profile']}}/shports-{{config['name']}}-typ-range/rsspAccGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsSpAccGrp.attributes.tDn}   uni/infra/funcprof/spaccportgrp-{{config['interface_policy_group']}}        Interface Policy Group Association not matching expected configuration	    values=False
    {% endif %}
{% endif %}


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'Interface Selector description',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'from_port': {'default': 'None',
               'descr': 'Starting Port in the interface range',
               'mandatory': True,
               'range': [1, 96],
               'source': 'workbook',
               'type': 'int'},
 'from_slot': {'default': 'None',
               'descr': 'Starting Slot in the interface range',
               'mandatory': True,
               'range': [1, 8],
               'source': 'workbook',
               'type': 'int'},
 'interface_polgroup_type': {'default': 'None',
                             'descr': 'Type of the interface Policy-Group associated with the interface selector',
                             'enum': ['PC', 'vPC', 'Access'],
                             'mandatory': True,
                             'source': 'workbook'},
 'interface_policy_group': {'default': 'None',
                            'descr': 'Interface Policy-Group Name',
                            'length': [1, 64],
                            'mandatory': True,
                            'regex': {'exact_match': False,
                                      'pattern': '[a-zA-Z0-9_.:-]+'},
                            'source': 'workbook',
                            'type': 'str'},
 'interface_profile': {'default': 'None',
                       'descr': 'Interface Profile Name',
                       'length': [1, 64],
                       'mandatory': True,
                       'regex': {'exact_match': False,
                                 'pattern': '[a-zA-Z0-9_.:-]+'},
                       'source': 'workbook',
                       'type': 'str'},
 'interface_profile_type': {'default': 'None',
                            'descr': 'Parent Inteface Profile Type',
                            'enum': ['spine', 'leaf'],
                            'mandatory': True,
                            'source': 'workbook'},
 'name': {'default': 'None',
          'descr': 'Interface Selector Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'port_block_description': {'default': 'None',
                            'descr': 'Interface Policy-Group Name',
                            'length': [0, 128],
                            'mandatory': False,
                            'regex': {'exact_match': False,
                                      'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?+]+'},
                            'source': 'workbook',
                            'type': 'str'},
 'to_port': {'default': 'None',
             'descr': 'Destination Port in the interface range',
             'mandatory': True,
             'range': [1, 96],
             'source': 'workbook',
             'type': 'int'},
 'to_slot': {'default': 'None',
             'descr': 'Destination Slot in the interface range',
             'mandatory': True,
             'range': [1, 8],
             'source': 'workbook',
             'type': 'int'}}
```
## infraNodeP.robot
### Template Description:
Verifies Leaf/Spine Switch Profile configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
to_node_id |   | True | None | DAFE Excel Sheet
switch_policy_group |   | False | None | DAFE Excel Sheet
name |   | True | None | DAFE Excel Sheet
switch_selector |   | True | None | DAFE Excel Sheet
from_node_id |   | True | None | DAFE Excel Sheet
switch_profile_type |   | True | None | DAFE Excel Sheet
description |   | False | None | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'switch_policy_group' not in config %}
  {% set x=config.__setitem__('switch_policy_group', '') %}
{% endif %}
{% if config['switch_profile_type'] == "leaf" %}
Verify ACI Leaf Switch Profile Configuration - Profile {{config['name']}}, Switch Selector {{config['switch_selector']}}, Node block {{config['from_node_id']}}-{{config['to_node_id']}}
    [Documentation]   Verifies that Leaf Switch Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Switch Selector: {{config['switch_selector']}}
    ...  - Node ID (from): {{config['from_node_id']}}
    ...  - Node ID (to): {{config['to_node_id']}}
    {% if config['switch_policy_group'] != "" %}
    ...  - Switch Policy Group: {{config['switch_policy_group']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].infraNodeP.attributes.name}   {{config['name']}}     Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].infraNodeP.attributes.descr}"   "{{config['description']}}"           Description not matching expected configuration              values=False
    {% endif %}
    # Retrieve switch selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-{{config['name']}}/leaves-{{config['switch_selector']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraNodeBlk
	${sw_selector}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.status}		200		                                                    Failure executing API call			                            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.totalCount}    	1		                                                Switch Selector does not exist	                                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${sw_selector.payload[0].infraLeafS.attributes.name}   {{config['switch_selector']}}   Failure retreiving switch selector configuration	            values=False
    ${from_node_found} =  Set Variable  "Node not found"
    ${to_node_found} =  Set Variable  "Node not found"
    : FOR  ${block}  IN  @{sw_selector.payload[0].infraLeafS.children}
    \  ${from_node_found} =     Set Variable If   "${block.infraNodeBlk.attributes.from_}" == "{{config['from_node_id']}}"      "Node found"
    \  ${to_node_found} =       Set Variable If   "${block.infraNodeBlk.attributes.to_}" == "{{config['to_node_id']}}"          "Node found"
	run keyword if  not ${from_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (from) not matching expected configuration
	run keyword if  not ${to_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (to) not matching expected configuration
{% elif config['switch_profile_type'] == "spine" %}
Verify ACI Spine Switch Profile Configuration - Profile {{config['name']}}, Switch Selector {{config['switch_selector']}}, Node block {{config['from_node_id']}}-{{config['to_node_id']}}
    [Documentation]   Verifies that Spine Switch Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Switch Selector: {{config['switch_selector']}}
    ...  - From Node ID: {{config['from_node_id']}}
    ...  - To Node ID: {{config['to_node_id']}}
    {% if config['switch_policy_group'] != "" %}
    ...  - Switch Policy Group: {{config['switch_policy_group']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpineP.attributes.name}   {{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].infraSpineP.attributes.descr}"   "{{config['description']}}"       Description not matching expected configuration                  values=False
    {% endif %}
    # Retrieve switch selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-{{config['name']}}/spines-{{config['switch_selector']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraNodeBlk
	${sw_selector}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.status}		200                                                         Failure executing API call			                            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.totalCount}    	1		                                                Switch Selector does not exist	                                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${sw_selector.payload[0].infraSpineS.attributes.name}   {{config['switch_selector']}}  Failure retreiving switch selector configuration	            values=False
    ${from_node_found} =  Set Variable  "Node not found"
    ${to_node_found} =  Set Variable  "Node not found"
    : FOR  ${block}  IN  @{sw_selector.payload[0].infraSpineS.children}
    \  ${from_node_found} =     Set Variable If   "${block.infraNodeBlk.attributes.from_}" == "{{config['from_node_id']}}"      "Node found"
    \  ${to_node_found} =       Set Variable If   "${block.infraNodeBlk.attributes.to_}" == "{{config['to_node_id']}}"          "Node found"
	run keyword if  not ${from_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (from) not matching expected configuration
	run keyword if  not ${to_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (to) not matching expected configuration
{% endif %}


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'from_node_id': {'default': 'None',
                  'mandatory': True,
                  'range': [101, 4000],
                  'source': 'workbook',
                  'type': 'int'},
 'name': {'default': 'None',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'switch_policy_group': {'default': 'None',
                         'length': [1, 64],
                         'mandatory': False,
                         'regex': {'exact_match': False,
                                   'pattern': '[a-zA-Z0-9_.:-]+'},
                         'source': 'workbook',
                         'type': 'str'},
 'switch_profile_type': {'default': 'None',
                         'enum': ['leaf', 'spine'],
                         'mandatory': True,
                         'source': 'workbook'},
 'switch_selector': {'default': 'None',
                     'length': [1, 64],
                     'mandatory': True,
                     'regex': {'exact_match': False,
                               'pattern': '[a-zA-Z0-9_.:-]+'},
                     'source': 'workbook',
                     'type': 'str'},
 'to_node_id': {'default': 'None',
                'mandatory': True,
                'range': [101, 4000],
                'source': 'workbook',
                'type': 'int'}}
```
## infraRSxxPortP.robot
### Template Description:
Verifies Leaf/Spine Interface Profile to Switch Profile assocation configuration

> The Switch Profile must exist.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
switch_profile | Switch Profile Name | True | None | DAFE Excel Sheet
interface_profile_type | Interface Profile Type | True | None | DAFE Excel Sheet
interface_profile | Interface Profile Name | True | None | DAFE Excel Sheet
switch_profile_type | Switch Profile Type | True | None | DAFE Excel Sheet


### Template Body:
```
{% if config['switch_profile_type'] == "leaf" and config['interface_profile_type'] == "leaf" %}
Verify ACI Leaf Interface Profile to Switch Profile Association Configuration - Switch Profile {{config['switch_profile']}}, Interface Profile {{config['interface_profile']}}
    [Documentation]   Verifies that ACI Leaf Interface Profile '{{config['interface_profile']}}' are associated with Switch Profile '{{config['switch_profile']}}'
    ...  - Switch Profile Name:  {{config['switch_profile']}}
    ...  - Interface Profile: {{config['interface_profile']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-{{config['switch_profile']}}
	${filter} =  Set Variable	rsp-subtree=full&rsp-subtree-class=infraRsAccPortP
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraNodeP.attributes.name}   {{config['switch_profile']}}       Failure retreiving configuration    values=False
	# Iterate through associated interface profiles
	Set Test Variable  ${node_block_found}   "Interface Profile not found"
    Variable Should Exist   @{return.payload[0].infraNodeP.children}       Interface Profile not associated with switch profile
    : FOR  ${if_profile}  IN  @{return.payload[0].infraNodeP.children}
	\  run keyword if  "${if_profile.infraRsAccPortP.attributes.tDn}" == "uni/infra/accportprof-{{config['interface_profile']}}"  run keywords
	\  ...  Set Test Variable  ${node_block_found}  "Interface Profile found"
    \  ...  AND  Exit For Loop
	run keyword if  not ${node_block_found} == "Interface Profile found"  run keyword
	...  Fail  Interface Profile not associated with switch profile
{% elif config['switch_profile_type'] == "spine" and config['interface_profile_type'] == "spine" %}
Verify ACI Spine Interface Profile to Switch Profile Association Configuration - Switch Profile {{config['switch_profile']}}, Interface Profile {{config['interface_profile']}}
    [Documentation]   Verifies that Spine Interface Profile '{{config['interface_profile']}}' are associated with Switch Profile '{{config['switch_profile']}}'
    ...  - Switch Profile Name:  {{config['switch_profile']}}
    ...  - Interface Profile: {{config['interface_profile']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-{{config['switch_profile']}}
	${filter} =  Set Variable	rsp-subtree=full&rsp-subtree-class=infraRsSpAccPortP
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpineP.attributes.name}   {{config['switch_profile']}}      Failure retreiving configuration    values=False
	# Iterate through associated interface profiles
	Set Test Variable  ${node_block_found}   "Interface Profile not found"
    Variable Should Exist   @{return.payload[0].infraSpineP.children}       Interface Profile not associated with switch profile
    : FOR  ${if_profile}  IN  @{return.payload[0].infraSpineP.children}
	\  run keyword if  "${if_profile.infraRsSpAccPortP.attributes.tDn}" == "uni/infra/spaccportprof-{{config['interface_profile']}}"  run keywords
	\  ...  Set Test Variable  ${node_block_found}  "Interface Profile found"
    \  ...  AND  Exit For Loop
	run keyword if  not ${node_block_found} == "Interface Profile found"  run keyword
	...  Fail  Interface Profile not associated with switch profile
{% endif %}


```
### Template Data Validation Model:
```json
{'interface_profile': {'default': 'None',
                       'descr': 'Interface Profile Name',
                       'length': [1, 64],
                       'mandatory': True,
                       'regex': {'exact_match': False,
                                 'pattern': '[a-zA-Z0-9_.:-]+'},
                       'source': 'workbook',
                       'type': 'str'},
 'interface_profile_type': {'default': 'None',
                            'descr': 'Interface Profile Type',
                            'enum': ['leaf', 'spine'],
                            'mandatory': True,
                            'source': 'workbook'},
 'switch_profile': {'default': 'None',
                    'descr': 'Switch Profile Name',
                    'length': [1, 64],
                    'mandatory': True,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'workbook',
                    'type': 'str'},
 'switch_profile_type': {'default': 'None',
                         'descr': 'Switch Profile Type',
                         'enum': ['leaf', 'spine'],
                         'mandatory': True,
                         'source': 'workbook'}}
```
## infra_vlan_apic.robot
### Template Description:
Verifies APIC Fabric Infrastructure VLAN configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
apic_hostname | APIC Hostname | True |   | DAFE Excel Sheet
apic_id | APIC Fabric ID | True |   | wordbook
infra_vlan | Fabric Infrastructure VLAN ID | True |   | wordbook
pod_id | APIC POD ID | True |   | wordbook


### Template Body:
```
{% set x=config.__setitem__("infra_vlan", dafe_data.fabric_initial_config.row(parameters='VLAN ID infra network').value) %}
Verify ACI Fabric Infrastructure VLAN Configuration - APIC{{config['apic_id']}}
    [Documentation]   Verifies that ACI Fabric Infrastructure VLAN Configuration on APIC{{config['apic_id']}}
    ...  - APIC Hostname: {{config['apic_hostname']}}
    ...  - Fabric ID: {{config['apic_id']}}
    ...  - POD ID: {{config['pod_id']}}
    ...  - Infrastructure VLAN ID: {{config['infra_vlan']}}
    [Tags]      aci-conf  aci-fabric-infra-vlan
    ${return}=  via ACI REST API retrieve "/api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['apic_id']}}/sys/inst-bond0.json?query-target=subtree&target-subtree-class=l3EncRtdIf" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200                                                                  Failure executing API call		                                    values=False
    should be equal as strings      ${return.totalCount}  1                                                                 APIC does not exist within fabric		                            values=False
    should be equal as strings      ${return.payload[0].l3EncRtdIf.attributes.encap}  vlan-{{config['infra_vlan']}}         Fabric Infrastructure VLAN matching expected configuration          values=False



```
### Template Data Validation Model:
```json
{'apic_hostname': {'descr': 'APIC Hostname',
                   'length': [1, 64],
                   'mandatory': True,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'apic_id': {'descr': 'APIC Fabric ID',
             'mandatory': True,
             'range': [1, 100],
             'source': 'wordbook',
             'type': 'int'},
 'infra_vlan': {'descr': 'Fabric Infrastructure VLAN ID',
                'mandatory': True,
                'range': [0, 4095],
                'source': 'wordbook',
                'type': 'int'},
 'pod_id': {'descr': 'APIC POD ID',
            'mandatory': True,
            'source': 'wordbook',
            'type': 'int'}}
```
## infra_vlan_node.robot
### Template Description:
Verifies APIC Fabric Infrastructure VLAN configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
node_id | Node Fabric ID | True |   | wordbook
infra_vlan | Fabric Infrastructure VLAN ID | True |   | wordbook
name | Node Hostname | True |   | DAFE Excel Sheet
pod_id | APIC POD ID | True |   | wordbook


### Template Body:
```
{% set x=config.__setitem__("infra_vlan", dafe_data.fabric_initial_config.row(parameters='VLAN ID infra network').value) %}
Verify ACI Fabric Infrastructure VLAN Configuration - Node {{config['node_id']}}
    [Documentation]   Verifies that ACI Fabric Infrastructure VLAN Configuration on Node {{config['node_id']}}
    ...  - Node Hostname: {{config['name']}}
    ...  - Fabric ID: {{config['node_id']}}
    ...  - POD ID: {{config['pod_id']}}
    ...  - Infrastructure VLAN ID: {{config['infra_vlan']}}
    [Tags]      aci-conf  aci-fabric-infra-vlan
    ${return}=  via ACI REST API retrieve "/api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}/sys/lldp/inst" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200                                                                  Failure executing API call		                                    values=False
    should be equal as strings      ${return.totalCount}  1                                                                 Node does not exist within fabric		                            values=False
    should be equal as Integers     ${return.payload[0].lldpInst.attributes.infraVlan}  {{config['infra_vlan']}}            Fabric Infrastructure VLAN matching expected configuration          values=False



```
### Template Data Validation Model:
```json
{'infra_vlan': {'descr': 'Fabric Infrastructure VLAN ID',
                'mandatory': True,
                'range': [0, 4095],
                'source': 'wordbook',
                'type': 'int'},
 'name': {'descr': 'Node Hostname',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'node_id': {'descr': 'Node Fabric ID',
             'mandatory': True,
             'range': [101, 4000],
             'source': 'wordbook',
             'type': 'int'},
 'pod_id': {'descr': 'APIC POD ID',
            'mandatory': True,
            'source': 'wordbook',
            'type': 'int'}}
```
## instP.robot
### Template Description:
Verifies L3Out External EPG configuration

> The Tenant, L3Out, and Node Profile must pre-exist.
> The External EPG subnet are not verified as part of this template

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
name | External EPG Name | True |   | DAFE Excel Sheet
prefered_group_member | Prefered Group Member | False | exclude | DAFE Excel Sheet
name_alias | L3 Out name alias | False | None | DAFE Excel Sheet
description | L3 Out Description | False | None | DAFE Excel Sheet
l3out | L3Out Name | True |   | DAFE Excel Sheet
qos_class | external EPG QoS Class | False | None | DAFE Excel Sheet
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet
target_descp | external EPG Target DSCP | False | unspecified | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'prefered_group_member' not in config or config['prefered_group_member'] == "" %}
  {% set x=config.__setitem__('prefered_group_member', 'exclude') %}
{% endif %}
{% if 'qos_class' not in config or config['qos_class'] == "" %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
{% if 'target_dscp' not in config or config['target_dscp'] == "" %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
Verify ACI L3Out External EPG Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['name']}}
    [Documentation]   Verifies that ACI L3Out External EPG '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3_out']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3_out']}}
    ...  - External EPG: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Prefered Group Member: {{config['prefered_group_member']}}
    ...  - QoS Class: {{config['qos_class']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out External EPG does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.nameAlias}"  "{{config['name_alias']}}"                  Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.descr}"  "{{config['description']}}"                     Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.prefGrMemb}"  "{{config['prefered_group_member']}}"      Preferred Group Member not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.prio}"  "{{config['qos_class']}}"                        QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.targetDscp}"  "{{config['target_dscp']}}"                Target DSCP not matching expected configuration                 values=False


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'L3 Out Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'l3out': {'descr': 'L3Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'name': {'descr': 'External EPG Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'name_alias': {'default': 'None',
                'descr': 'L3 Out name alias',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'prefered_group_member': {'default': 'exclude',
                           'descr': 'Prefered Group Member',
                           'enum': ['include', 'exclude'],
                           'mandatory': False,
                           'source': 'workbook'},
 'qos_class': {'default': 'None',
               'descr': 'external EPG QoS Class',
               'enum': ['unspecified', 'level1', 'level2', 'level3'],
               'mandatory': False,
               'source': 'workbook'},
 'target_descp': {'default': 'unspecified',
                  'descr': 'external EPG Target DSCP',
                  'enum': ['unspecified',
                           'CS0',
                           'CS1',
                           'AF11',
                           'AF12',
                           'AF13',
                           'CS2',
                           'AF21',
                           'AF22',
                           'AF23',
                           'CS3',
                           'AF31',
                           'AF32',
                           'AF33',
                           'CS4',
                           'AF41',
                           'AF42',
                           'AF43',
                           'VA',
                           'CS5',
                           'EF',
                           'CS6',
                           'CS7'],
                  'mandatory': False,
                  'source': 'workbook'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## l2IfPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
reflective_relay | Configure the interface for reflective relay 802.1Qbg | False | disabled | wordbook
description | CDP Interface Policy Description | False | None | DAFE Excel Sheet
vlan_scope | Define Interface Vlan Scope | True | None | DAFE Excel Sheet
qinq | Configure the interface for QinQ Tunneling | False | disabled | wordbook
name | Layer 2 Interface Policy Name | True | None | DAFE Excel Sheet


### Template Body:
```
{% if 'qinq' not in config %}
  {% set x=config.__setitem__('qinq', 'disabled') %}
{% endif %}
{% if 'reflective_relay' not in config %}
  {% set x=config.__setitem__('reflective_relay', 'disabled') %}
{% endif %}
Verify ACI L2 Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that L2 Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
	...  - VLAN Scope: {{config['vlan_scope']}}
	...  - QinQ: {{config['qinq']}}
	...  - Reflective Relay: {{config['reflective_relay']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/l2IfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.name}			{{config['name']}}    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vlanScope}	{{config['vlan_scope']}}   VLAN Scope not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.qinq}		{{config['qinq']}}   	   QinQ not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vepa}		{{config['reflective_relay']}}   Reflective Relay not matching expected configuration                   values=False


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'CDP Interface Policy Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'default': 'None',
          'descr': 'Layer 2 Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'qinq': {'default': 'disabled',
          'descr': 'Configure the interface for QinQ Tunneling',
          'enum': ['disabled', 'edgePort', 'corePort'],
          'mandatory': False,
          'source': 'wordbook'},
 'reflective_relay': {'default': 'disabled',
                      'descr': 'Configure the interface for reflective relay 802.1Qbg',
                      'enum': ['disabled', 'enabled'],
                      'mandatory': False,
                      'source': 'wordbook'},
 'vlan_scope': {'default': 'None',
                'descr': 'Define Interface Vlan Scope',
                'enum': ['global', 'portlocal'],
                'mandatory': True,
                'source': 'workbook'}}
```
## l3extNodeIntProf.robot
### Template Description:
Verifies L3Out Interface Profile configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
description | L3Out Interface Profile Description | False |   | DAFE Excel Sheet
trunk_mode | Interface mode (trunk, access, etc.) | True |   | DAFE Excel Sheet
ospf_interface_policy | OSPF Interface Policy | False | None | DAFE Excel Sheet
name_alias | L3Out Interface Profile name alias | False |   | DAFE Excel Sheet
ip_addr_side_b | Side B IP Address in the form of IP/Mask | False | None | DAFE Excel Sheet
port_id | Interface ID (used if interface is access) | False | None | DAFE Excel Sheet
pod_id | Switch assigned POD ID | True | None | DAFE Excel Sheet
tenant | Parent tenant name | True |   | DAFE Excel Sheet
ip_addr_side_a | Side A IP Address in the form of IP/Mask | True | None | DAFE Excel Sheet
name | L3Out Interface Profile Name | True |   | DAFE Excel Sheet
vlan_encap_id | Encapsulation VLAN ID | True | None | DAFE Excel Sheet
right_node_id | Right Node ID | False | None | DAFE Excel Sheet
left_node_id | Left Node ID | True | None | DAFE Excel Sheet
mtu | Interface MTU | False | inherit | DAFE Excel Sheet
l3out | Parent L3 Out Name | True |   | DAFE Excel Sheet
autostate | SVI Autostate | True | disabled | DAFE Excel Sheet
path_type | Interface Path Type | True |   | DAFE Excel Sheet
l3out_node_profile | L3Out Node Profile Name | True |   | DAFE Excel Sheet
interface_type | Interface Type | True |   | DAFE Excel Sheet
int_pol_group | Interface Policy Group (used if interface are vPC or PC) | False | None | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'right_node_id' not in config %}
  {% set x=config.__setitem__('right_node_id', '') %}
{% endif %}
{% if 'int_pol_group' not in config %}
  {% set x=config.__setitem__('int_pol_group', '') %}
{% endif %}
{% if 'port_id' not in config %}
  {% set x=config.__setitem__('port_id', '') %}
{% endif %}
{% if 'ip_addr_side_b' not in config %}
  {% set x=config.__setitem__('ip_addr_side_b', '') %}
{% endif %}
{% if 'ospf_interface_policy' not in config %}
  {% set x=config.__setitem__('ospf_interface_policy', '') %}
{% endif %}
{% if 'mtu' not in config or config['mtu'] == "" %}
  {% set x=config.__setitem__('mtu', 'inherit') %}
{% endif %}
{% if 'autostate' not in config %}
  {% set x=config.__setitem__('autostate', 'disabled') %}
{% elif config['autostate'] not in ['enabled', 'disabled'] %}
  {% set x=config.__setitem__('autostate', 'disabled') %}
{% endif %}
{% if config['path_type'] == 'vPC' %}
  {% set path = "topology/pod-" + config['pod_id'] + "/protpaths-" + config['left_node_id'] + "-" + config['right_node_id'] + "/pathep-[" + config['int_pol_group'] + "]" %}
{% elif config['path_type'] == 'PC' %}
  {% set path = "topology/pod-" + config['pod_id'] + "/paths-" + config['left_node_id'] + "/pathep-[" + config['int_pol_group'] + "]" %}
{% else %}
  {% set path = "topology/pod-" + config['pod_id'] + "/paths-" + config['left_node_id'] + "/pathep-[eth" + config['port_id'] + "]" %}
{% endif %}
{% if config['interface_type'] == 'svi' %}
  {% set iftype = "ext-svi" %}
  {% set encap = "vlan-" + config['vlan_encap_id'] %}
{% elif config['interface_type'] == 'routed_sub' %}
  {% set iftype = "sub-interface" %}
  {% set encap = "vlan-" + config['vlan_encap_id'] %}
{% else %}
  {% set iftype = "l3-port" %}
  {% set encap = "unknown" %}
{% endif %}
Verify ACI L3Out Interface Profile Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['l3out_node_profile']}}, Interface Profile {{config['name']}}
    [Documentation]   Verifies that ACI L3Out Interface Profile '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}', Node Profile '{{config['l3out_node_profile']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - Interface Profile Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Interface Type: {{config['interface_type']}}
    ...  - Interface Path Type: {{config['path_type']}}
    {% if config['path_type'] == 'vPC' %}
    ...  - POD: {{config['pod_id']}}
    ...  - Node ID (side A): {{config['left_node_id']}}
    ...  - Node ID (side B: {{config['right_node_id']}}
    ...  - Interface Policy Group: {{config['int_pol_group']}}
    {% elif config['path_type'] == 'PC' %}
    ...  - POD: {{config['pod_id']}}
    ...  - Node ID: {{config['left_node_id']}}
    ...  - Interface Policy Group: {{config['int_pol_group']}}
    {% else %}
    ...  - POD: {{config['pod_id']}}
    ...  - Node ID: {{config['left_node_id']}}
    ...  - Interface ID: eth{{config['port_id']}}
    {% endif %}
    ...  - Interface Type: {{config['interface_type']}}
    {% if config['interface_type'] == 'svi' %}
    ...  - Interface Mode: {{config['trunk_mode']}}
    ...  - Encapsulation: vlan-{{config['vlan_encap_id']}}
    ...  - IP (side A): {{config['ip_addr_side_a']}}
    ...  - IP (side B): {{config['ip_addr_side_b']}}
    ...  - MTU: {{config['mtu']}}
    {% elif config['interface_type'] == 'routed_sub' %}
    ...  - Interface Mode: {{config['trunk_mode']}}
    ...  - Encapsulation: vlan-{{config['vlan_encap_id']}}
    ...  - IP: {{config['ip_addr_side_a']}}
    ...  - MTU: {{config['mtu']}}
    {% else %}
    ...  - Interface Mode: {{config['trunk_mode']}}
    ...  - Encapsulation: unknown
    ...  - IP: {{config['ip_addr_side_a']}}
    ...  - MTU: {{config['mtu']}}
    {% endif %}
    {% if config['ospf_interface_policy'] != "" %}
    ...  - OSPF Interface Policy: {{config['ospf_interface_policy']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/lifp-{{config['name']}}
    ${filter} =  Set Variable  rsp-subtree=full&rsp-subtree-class=l3extRsPathL3OutAtt
    ${return} =  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Interface Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.nameAlias}"  "{{config['name_alias']}}"                  Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.descr}"  "{{config['description']}}"                     Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.tDn}"  "{{path}}"                        Interface Policy Group/Interface ID, Node(s), or POD not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.ifInstT}"  "{{iftype}}"                  Interface Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.encap}"  "{{encap}}"                     Encapsulation not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mode}"  "{{config['trunk_mode']}}"       Interface Mode not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mtu}"  "{{config['mtu']}}"               MTU not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.autostate}"  "{{config['autostate']}}"   Autostate not matching expected configuration                 values=False
    {% if config['path_type'] == 'vPC' %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.addr}"  "0.0.0.0"                        'Global' IP Address not matching expected configuration                 values=False
    : FOR  ${member}  IN  @{return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.children}
    \  run keyword if  "${member.l3extMember.attributes.side}" == "A"
    \  ...  Run keyword And Continue on Failure  Should Be Equal as Strings  "${member.l3extMember.attributes.addr}"  "{{config['ip_addr_side_a']}}"    Side A IP Address not matching expected configuration                 values=False
    \  run keyword if  "${member.l3extMember.attributes.side}" == "B"
    \  ...  Run keyword And Continue on Failure  Should Be Equal as Strings  "${member.l3extMember.attributes.addr}"  "{{config['ip_addr_side_b']}}"    Side B IP Address not matching expected configuration                 values=False
    {% else %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.addr}"  "{{config['ip_addr_side_a']}}"   IP Address not matching expected configuration                 values=False
    {% endif %}
    {% if config['ospf_interface_policy'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/lifp-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retrieving associated OSPF Interface Profile		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfIfP.attributes.name}"  "{{config['ospf_interface_policy']}}"      Router ID not matching expected configuration                 values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'autostate': {'default': 'disabled',
               'descr': 'SVI Autostate',
               'enum': ['enabled', 'disabled'],
               'mandatory': True,
               'source': 'workbook'},
 'description': {'descr': 'L3Out Interface Profile Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'int_pol_group': {'default': 'None',
                   'descr': 'Interface Policy Group (used if interface are vPC or PC)',
                   'length': [1, 64],
                   'mandatory': False,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'interface_type': {'descr': 'Interface Type',
                    'enum': ['routed', 'routed_sub', 'svi'],
                    'mandatory': True,
                    'source': 'workbook'},
 'ip_addr_side_a': {'default': 'None',
                    'descr': 'Side A IP Address in the form of IP/Mask',
                    'mandatory': True,
                    'source': 'workbook',
                    'type': 'str'},
 'ip_addr_side_b': {'default': 'None',
                    'descr': 'Side B IP Address in the form of IP/Mask',
                    'mandatory': False,
                    'source': 'workbook',
                    'type': 'str'},
 'l3out': {'descr': 'Parent L3 Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'l3out_node_profile': {'descr': 'L3Out Node Profile Name',
                        'length': [1, 64],
                        'mandatory': True,
                        'regex': {'exact_match': False,
                                  'pattern': '[a-zA-Z0-9_.:-]+'},
                        'source': 'workbook',
                        'type': 'str'},
 'left_node_id': {'default': 'None',
                  'descr': 'Left Node ID',
                  'mandatory': True,
                  'range': [101, 4000],
                  'source': 'workbook',
                  'type': 'int'},
 'mtu': {'default': 'inherit',
         'descr': 'Interface MTU',
         'length': [1, 64],
         'mandatory': False,
         'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9]+'},
         'source': 'workbook',
         'type': 'str'},
 'name': {'descr': 'L3Out Interface Profile Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'name_alias': {'descr': 'L3Out Interface Profile name alias',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'ospf_interface_policy': {'default': 'None',
                           'descr': 'OSPF Interface Policy',
                           'length': [1, 64],
                           'mandatory': False,
                           'regex': {'exact_match': False,
                                     'pattern': '[a-zA-Z0-9_.:-]+'},
                           'source': 'workbook',
                           'type': 'str'},
 'path_type': {'descr': 'Interface Path Type',
               'enum': ['vPC', 'PC', 'Access'],
               'mandatory': True,
               'source': 'workbook'},
 'pod_id': {'default': 'None',
            'descr': 'Switch assigned POD ID',
            'mandatory': True,
            'range': [1, 10],
            'source': 'workbook',
            'type': 'int'},
 'port_id': {'default': 'None',
             'descr': 'Interface ID (used if interface is access)',
             'length': [1, 64],
             'mandatory': False,
             'source': 'workbook',
             'type': 'str'},
 'right_node_id': {'default': 'None',
                   'descr': 'Right Node ID',
                   'mandatory': False,
                   'range': [101, 4000],
                   'source': 'workbook',
                   'type': 'int'},
 'tenant': {'descr': 'Parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'trunk_mode': {'descr': 'Interface mode (trunk, access, etc.)',
                'enum': ['regular', 'untagged', 'native'],
                'mandatory': True,
                'source': 'workbook'},
 'vlan_encap_id': {'default': 'None',
                   'descr': 'Encapsulation VLAN ID',
                   'mandatory': True,
                   'range': [0, 4000],
                   'source': 'workbook',
                   'type': 'int'}}
```
## l3extNodeProf.robot
### Template Description:
Verifies L3Out Node Profile configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
router_id | Node Router Id | True |   | DAFE Excel Sheet
enable_mpod | Boolean Define if Node Profile is used for M-POD (fabricExtControl Peering) | False | no | DAFE Excel Sheet
enable_golf | Boolean Define if Node Profile is used for Golf (fabricExtControl Peering)  | False | no | DAFE Excel Sheet
name | L3Out Node Profile Name | True |   | DAFE Excel Sheet
name_alias | L3Out Node Profile name alias | False |   | DAFE Excel Sheet
l3out | Parent L3 Out Name | True |   | DAFE Excel Sheet
node_id | Node Id selected by this profile | True |   | DAFE Excel Sheet
router_id_as_loopback | Define the Router ID as Loopback IP | True |   | DAFE Excel Sheet
target_dscp |  | False | unspecified | DAFE Excel Sheet
pod_id | Node POD id | True |   | DAFE Excel Sheet
tenant | Parent tenant name | True |   | DAFE Excel Sheet
description | L3Out Node Profile Description | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'enable_golf' not in config %}
  {% set x=config.__setitem__('enable_golf', 'no') %}
{% elif config['enable_golf'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_golf', 'no') %}
{% endif %}
{% if 'enable_mpod' not in config %}
  {% set x=config.__setitem__('enable_mpod', 'no') %}
{% elif config['enable_mpod'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_mpod', 'no') %}
{% endif %}
{% if 'target_dscp' not in config %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% elif config['target_dscp'] not in ['unspecified', 'CS0', 'CS1', 'AF11', 'AF12', 'AF13', 'CS2', 'AF21', 'AF22', 'AF23', 'CS3', 'AF31', 'AF32', 'AF33', 'CS4', 'AF41', 'AF42', 'AF43', 'VA', 'CS5', 'EF', 'CS6', 'CS7'] %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
Verify ACI L3Out Node Profile Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['name']}}, Node pod-{{config['pod_id']}}/node-{{config['node_id']}}
    [Documentation]   Verifies that ACI L3Out Node Profile '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Node: pod-{{config['pod_id']}}/node-{{config['node_id']}}
    ...  - Router ID: {{config['router_id']}}
    ...  - Use Router ID as Loopback: {{config['router_id_as_loopback']}}
    ...  - Multi-POD Enable: {{config['enable_mpod']}}
    ...  - Golf Enable: {{config['enable_golf']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.nameAlias}"  "{{config['name_alias']}}"                    Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.targetDscp}"  "{{config['target_dscp']}}"                  Target DSCP not matching expected configuration                 values=False
    # Node Association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['name']}}/rsnodeL3OutAtt-[topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Node not associated with Node Profile		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrId}"  "{{config['router_id']}}"                         Router ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrIdLoopBack}"  "{{config['router_id_as_loopback']}}"     Use Router ID as Loopback not matching expected configuration                 values=False
    {% if config['tenant'] == "infra" and (config['enable_golf'] == "yes" or config['enable_mpod'] == "yes") %}
    # Golf or Multi-POD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/instP-l3extInstPName{{config['l3out']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Multi-POD / GOLF External EPG not defined		values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'description': {'descr': 'L3Out Node Profile Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'enable_golf': {'default': 'no',
                 'descr': 'Boolean Define if Node Profile is used for Golf (fabricExtControl Peering) ',
                 'enum': ['yes', 'no'],
                 'mandatory': False,
                 'source': 'workbook'},
 'enable_mpod': {'default': 'no',
                 'descr': 'Boolean Define if Node Profile is used for M-POD (fabricExtControl Peering)',
                 'enum': ['yes', 'no'],
                 'mandatory': False,
                 'source': 'workbook'},
 'l3out': {'descr': 'Parent L3 Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'name': {'descr': 'L3Out Node Profile Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'name_alias': {'descr': 'L3Out Node Profile name alias',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'node_id': {'descr': 'Node Id selected by this profile',
             'mandatory': True,
             'range': [101, 4000],
             'source': 'workbook',
             'type': 'int'},
 'pod_id': {'descr': 'Node POD id',
            'mandatory': True,
            'range': [1, 10],
            'source': 'workbook',
            'type': 'int'},
 'router_id': {'descr': 'Node Router Id',
               'mandatory': True,
               'source': 'workbook',
               'type': 'str'},
 'router_id_as_loopback': {'descr': 'Define the Router ID as Loopback IP',
                           'enum': ['yes', 'no'],
                           'mandatory': True,
                           'source': 'workbook'},
 'target_dscp': {'default': 'unspecified',
                 'descr': '',
                 'enum': ['unspecified',
                          'CS0',
                          'CS1',
                          'AF11',
                          'AF12',
                          'AF13',
                          'CS2',
                          'AF21',
                          'AF22',
                          'AF23',
                          'CS3',
                          'AF31',
                          'AF32',
                          'AF33',
                          'CS4',
                          'AF41',
                          'AF42',
                          'AF43',
                          'VA',
                          'CS5',
                          'EF',
                          'CS6',
                          'CS7'],
                 'mandatory': False,
                 'source': 'workbook'},
 'tenant': {'descr': 'Parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## l3extOut.robot
### Template Description:
Verifies external routed network (or L3OUT) configuration

The L3out can be associated to a consumer_label or a provider_label
Consumer Label and Provider Label can't be configured on the same L3Out, this is verified by this template

> The Tenant must pre-exist.
> OSPF Control knobs are not verified by this template

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
enable_ospf | Boolean check if OSPF should be enabled on L3OUT | False | no | DAFE Excel Sheet
name | L3 Out Name | True |   | DAFE Excel Sheet
l3out_domain | Associated Domain Name | True |   | DAFE Excel Sheet
enable_bgp | Boolean check if BGP should be enabled on L3OUT | False | no | DAFE Excel Sheet
name_alias | L3 Out name alias | False |   | DAFE Excel Sheet
description | L3 Out Description | False |   | DAFE Excel Sheet
area_type | OSPF Area Type, mandatory if OSPF is enabled | False | nssa | DAFE Excel Sheet
ospf_area_id | OSPF Area ID in simple Integer notation, mandatory if OSPF is enabled | False |   | DAFE Excel Sheet
vrf | Associated VRF Name | True |   | DAFE Excel Sheet
provider_label | Golf Provider Label | False |   | DAFE Excel Sheet
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet
consumer_label | Golf Consumer Label | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'enable_bgp' not in config %}
  {% set x=config.__setitem__('enable_bgp', 'no') %}
{% elif config['enable_bgp'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_bgp', 'no') %}
{% endif %}
{% if 'enable_ospf' not in config %}
  {% set x=config.__setitem__('enable_ospf', 'no') %}
{% elif config['enable_ospf'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_ospf', 'no') %}
{% endif %}
{% if 'ospf_area_id' not in config %}
  {% set x=config.__setitem__('ospf_area_id', '') %}
{% endif %}
{% if 'ospf_area_type' not in config %}
  {% set x=config.__setitem__('ospf_area_type', 'nssa') %}
{% elif config['ospf_area_type'] not in ['nssa', 'regular', 'stub'] %}
  {% set x=config.__setitem__('ospf_area_type', 'nssa') %}
{% endif %}
{% if 'consumer_label' not in config %}
  {% set x=config.__setitem__('consumer_label', '') %}
{% endif %}
{% if 'provider_label' not in config %}
  {% set x=config.__setitem__('provider_label', '') %}
{% endif %}
Verify ACI L3Out Configuration - Tenant {{config['tenant']}}, L3Out {{config['name']}}
    [Documentation]   Verifies that ACI L3Out '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - VRF Association: {{config['vrf']}}
    ...  - OSPF Enabled: {{config['enable_ospf']}}
    {% if config['enable_ospf'] == "yes" %}
    ...  - OSPF Area: {{config['ospf_area_id']}}
    ...  - OSPF Area Type: {{config['ospf_area_type']}}
    {% endif %}
    ...  - BGP Enabled: {{config['enable_bgp']}}
    ...  - Consumer Label: {{config['consumer_label']}}
    ...  - Provider Label: {{config['provider_label']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.nameAlias}"  "{{config['name_alias']}}"                   Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.descr}"  "{{config['description']}}"                      Description not matching expected configuration                 values=False
    {% endif %}
    # VRF association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/rsectx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving VRF configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsEctx.attributes.tnFvCtxName}"  "{{config['vrf']}}"                     VRF Association not matching expected configuration                 values=False
    # Domain
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/rsl3DomAtt
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving Domain configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsL3DomAtt.attributes.tDn}"  "uni/l3dom-{{config['l3out_domain']}}"      Domain Association not matching expected configuration                 values=False
    {% if config['enable_ospf'] == "yes" %}
    # OSPF
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/ospfExtP
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		OSPF not enabled 		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfExtP.attributes.areaId}"  "0.0.0.{{config['ospf_area_id']}}"              OSPF Area ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfExtP.attributes.areaType}"  "{{config['ospf_area_type']}}"                     OSPF Area Type not matching expected configuration                 values=False
    {% endif %}
    {% if config['enable_bgp'] == "yes" %}
    # BGP
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/bgpExtP
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		BGP not enabled 		values=False
    {% endif %}
    {% if config['consumer_label'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}//conslbl-{{config['consumer_label']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Consumer Label not matching expected configuration		values=False
    {% endif %}
    {% if config['provider_label'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}//provlbl-{{config['provider_label']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Consumer Label not matching expected configuration		values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'area_type': {'default': 'nssa',
               'descr': 'OSPF Area Type, mandatory if OSPF is enabled',
               'enum': ['regular', 'stub', 'nssa'],
               'mandatory': False,
               'source': 'workbook'},
 'consumer_label': {'descr': 'Golf Consumer Label',
                    'length': [1, 64],
                    'mandatory': False,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'workbook',
                    'type': 'str'},
 'description': {'descr': 'L3 Out Description',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'enable_bgp': {'default': 'no',
                'descr': 'Boolean check if BGP should be enabled on L3OUT',
                'enum': ['yes', 'no'],
                'mandatory': False,
                'source': 'workbook'},
 'enable_ospf': {'default': 'no',
                 'descr': 'Boolean check if OSPF should be enabled on L3OUT',
                 'enum': ['yes', 'no'],
                 'mandatory': False,
                 'source': 'workbook'},
 'l3out_domain': {'descr': 'Associated Domain Name',
                  'length': [1, 64],
                  'mandatory': True,
                  'regex': {'exact_match': False,
                            'pattern': '[a-zA-Z0-9_.:-]+'},
                  'source': 'workbook',
                  'type': 'str'},
 'name': {'descr': 'L3 Out Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'name_alias': {'descr': 'L3 Out name alias',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'ospf_area_id': {'descr': 'OSPF Area ID in simple Integer notation, mandatory if OSPF is enabled',
                  'mandatory': False,
                  'range': [0, 1000],
                  'source': 'workbook',
                  'type': 'int'},
 'provider_label': {'descr': 'Golf Provider Label',
                    'length': [1, 64],
                    'mandatory': False,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'workbook',
                    'type': 'str'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'vrf': {'descr': 'Associated VRF Name',
         'length': [1, 64],
         'mandatory': True,
         'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
         'source': 'workbook',
         'type': 'str'}}
```
## l3extSubnet.robot
### Template Description:
Verifies L3Out External EPG Subnet configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
l3out | L3Out Name | True |   | DAFE Excel Sheet
route_control_profile | Route Control Profile Name | False | None | DAFE Excel Sheet
shared_security | Shared security import | False | no | wordbook
export_route_control | Export route control | False | no | wordbook
external_subnet | Subnet in the form of IP/Mask | True | None | DAFE Excel Sheet
route_control_profile_direction | Route Control Profile Direction | False | import | wordbook
shared_route_control | Shared route control | False | no | wordbook
external_epg | External EPG Name | True |   | DAFE Excel Sheet
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet
aggregate_shared_routes | Aggregate shared routes | False | no | wordbook


### Template Body:
```
{% if config['aggregate_shared_routes'] == "yes" and config['aggregate_shared_routes'] == "yes" %}
    {% set aggregate = 'shared-rtctrl' %}
{% else %}
    {% set aggregate = '' %}
{% endif %}
{% set scope = [] %}
{% if config['external_subnet_for_external_epg'] == "yes" %}{% set scope = scope + [("import-security")] %}{% endif %}
{% if config['export_route_control'] == "yes" %}{% set scope = scope + [("export-rtctrl")] %}{% endif %}
{% if config['shared_route_control'] == "yes" %}{% set scope = scope+ [("shared-rtctrl")] %}{% endif %}
{% if config['shared_security'] == "yes" %}{% set scope = scope + [("shared-security")] %}{% endif %}
{% if config['route_control_profile'] != "" %}
Verify ACI L3Out External EPG Subnet Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['external_epg']}}, Subnet {{config['external_subnet']}}, Route Control Profile '{{config['route_control_profile']}}'
{% else %}
Verify ACI L3Out External EPG Subnet Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['external_epg']}}, Subnet {{config['external_subnet']}}
{% endif %}
    [Documentation]   Verifies that ACI L3Out External EPG Subnet '{{config['subnet']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3_out']}}', External EPG '{{config['external_epg']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3_out']}}
    ...  - External EPG: {{config['external_epg']}}
    ...  - Subnet: {{config['external_subnet']}}
    ...  - External Subnet for External EPG: {{config['external_subnet_for_external_epg']}}
    ...  - Export Route Control: {{config['export_route_control']}}
    ...  - Shared Route Control: {{config['shared_route_control']}}
    ...  - Shared Security Import: {{config['shared_security']}}
    ...  - Aggregated Shared Route: {{config['aggregate_shared_routes']}}
    ...  - Route Control Profile: {{config['route_control_profile']}}
    ...  - Route Control Profile Direction: {{config['route_control_profile_direction']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['external_epg']}}/extsubnet-[{{config['external_subnet']}}]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Subnet not associated with External EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extSubnet.attributes.aggregate}"  "{{aggregate}}"                     Aggregate not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extSubnet.attributes.scope}"      "{{scope|join(',')}}"               Scope not matching expected configuration                 values=False
    {% if config['route_control_profile'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['external_epg']}}/extsubnet-[{{config['external_subnet']}}]/rssubnetToProfile-[{{config['route_control_profile']}}]-{{config['route_control_profile_direction']|default('import',True)}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}   1		Route Profile or Route Profile Direction not matching expected configuration		values=False
    {% endif %}

```
### Template Data Validation Model:
```json
{'aggregate_shared_routes': {'default': 'no',
                             'descr': 'Aggregate shared routes',
                             'enum': ['yes', 'no'],
                             'mandatory': False,
                             'source': 'wordbook'},
 'export_route_control': {'default': 'no',
                          'descr': 'Export route control',
                          'enum': ['yes', 'no'],
                          'mandatory': False,
                          'source': 'wordbook'},
 'external_epg': {'descr': 'External EPG Name',
                  'length': [1, 64],
                  'mandatory': True,
                  'regex': {'exact_match': False,
                            'pattern': '[a-zA-Z0-9_.:-]+'},
                  'source': 'workbook',
                  'type': 'str'},
 'external_subnet': {'default': 'None',
                     'descr': 'Subnet in the form of IP/Mask',
                     'mandatory': True,
                     'source': 'workbook',
                     'type': 'str'},
 'l3out': {'descr': 'L3Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'route_control_profile': {'default': 'None',
                           'descr': 'Route Control Profile Name',
                           'length': [1, 64],
                           'mandatory': False,
                           'regex': {'exact_match': False,
                                     'pattern': '[a-zA-Z0-9_.:-]+'},
                           'source': 'workbook',
                           'type': 'str'},
 'route_control_profile_direction': {'default': 'import',
                                     'descr': 'Route Control Profile Direction',
                                     'enum': ['import', 'export'],
                                     'mandatory': False,
                                     'source': 'wordbook'},
 'shared_route_control': {'default': 'no',
                          'descr': 'Shared route control',
                          'enum': ['yes', 'no'],
                          'mandatory': False,
                          'source': 'wordbook'},
 'shared_security': {'default': 'no',
                     'descr': 'Shared security import',
                     'enum': ['yes', 'no'],
                     'mandatory': False,
                     'source': 'wordbook'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## lacpLagPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
hash_key | Symmetrical Hash Key | False | None | wordbook
name | PortChannel Interface Policy Name | True | None | DAFE Excel Sheet
load_defer | Boolean used to enabled or disabled Load defer | True | None | wordbook
symmetrical_hash | Boolean used to enabled or disabled Symmetrical Hash | True | None | wordbook
fast_select_hot_stdby | Boolean used to enabled or disabled Fast selection Hot Standby | True | None | wordbook
pc_mode | Aggregation mode | True | None | wordbook
min_links | Agg Minimum Links | True | 1 | wordbook
gracefull_converge | Boolean used to enabled or disabled Graceful Convergence | True | None | wordbook
max_links | Agg Maximum Links | True | 16 | wordbook
description | PortChannel Interface Policy Description | False | None | DAFE Excel Sheet


### Template Body:
```
{% set ctrl = [] %}
{% if config['fast_select_hot_stdby'] == "yes" %}{% set ctrl = ctrl + [("fast-sel-hot-stdby")] %}{% endif %}
{% if config['gracefull_converge'] == "yes" %}{% set ctrl = ctrl + [("graceful-conv")] %}{% endif %}
{% if config['load_defer'] == "yes" %}{% set ctrl = ctrl + [("load-defer")] %}{% endif %}
{% if config['suspend_individual'] == "yes" %}{% set ctrl = ctrl + [("susp-individual")] %}{% endif %}
{% if config['symmetrical_hash'] == "yes" %}{% set ctrl = ctrl + [("symmetric-hash")] %}{% endif %}
Verify ACI Port Channel Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that Port Channel Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - Port-Channel Mode (LACP): {{config['pc_mode']}}
	...  - Fast Select Hot Standby: {{config['fast_select_hot_stdby']}}
	...  - Graceful Converge: {{config['gracefull_converge']}}
	...  - Load Defer: {{config['load_defer']}}
	...  - Suspend Individual: {{config['suspend_individual']}}
	...  - Symmetric Hash: {{config['symmetrical_hash']}}
	...  - Hash Key: {{config['hash_key']}}
	...  - Min Links: {{config['min_links']}}
	...  - Max Links: {{config['max_links']}}
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		{{config['name']}}       Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].lacpLagPol.attributes.descr}"   "{{config['description']}}"          Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		{{config['pc_mode']}}                 Port Channel Mode (LACP) not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	{{config['min_links']}}               Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	{{config['max_links']}}               Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		{{ctrl|join(',')}}    				  Control Kobs not matching expected configuration                   values=False
	{% if config['symmetrical_hash'] == "yes" and config['hash_key'] %}
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-{{config['name']}}/loadbalanceP
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
	Should Be Equal as Integers     ${return.totalCount}	1		Failure Retrieving Port Channel Hash configuration     values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2LoadBalancePol.attributes.hashFields}		{{config['hash_key']}}                 Port Channel Hash Key not matching expected configuration                 values=False
	{% endif %}


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'PortChannel Interface Policy Description',
                 'length': [1, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'fast_select_hot_stdby': {'default': 'None',
                           'descr': 'Boolean used to enabled or disabled Fast selection Hot Standby',
                           'enum': ['yes', 'no'],
                           'mandatory': True,
                           'source': 'wordbook'},
 'gracefull_converge': {'default': 'None',
                        'descr': 'Boolean used to enabled or disabled Graceful Convergence',
                        'enum': ['yes', 'no'],
                        'mandatory': True,
                        'source': 'wordbook'},
 'hash_key': {'default': 'None',
              'descr': 'Symmetrical Hash Key',
              'enum': ['src-ip', 'dst-ip', 'l4-src-port', 'l4-dst-port'],
              'mandatory': False,
              'source': 'wordbook'},
 'load_defer': {'default': 'None',
                'descr': 'Boolean used to enabled or disabled Load defer',
                'enum': ['yes', 'no'],
                'mandatory': True,
                'source': 'wordbook'},
 'max_links': {'default': '16',
               'descr': 'Agg Maximum Links',
               'mandatory': True,
               'range': [1, 16],
               'source': 'wordbook',
               'type': 'int'},
 'min_links': {'default': '1',
               'descr': 'Agg Minimum Links',
               'mandatory': True,
               'range': [1, 16],
               'source': 'wordbook',
               'type': 'int'},
 'name': {'default': 'None',
          'descr': 'PortChannel Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'pc_mode': {'default': 'None',
             'descr': 'Aggregation mode',
             'enum': ['active',
                      'passive',
                      'mac-pin',
                      'mac-pin-nicload',
                      'off'],
             'mandatory': True,
             'source': 'wordbook'},
 'symmetrical_hash': {'default': 'None',
                      'descr': 'Boolean used to enabled or disabled Symmetrical Hash',
                      'enum': ['yes', 'no'],
                      'mandatory': True,
                      'source': 'wordbook'}}
```
## lldpIfPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
lldp_transmit | LLDP Interface transmit state | True | None | wordbook
name | LLDP Interface Policy Name | True | None | DAFE Excel Sheet
lldp_receive | LLDP Interface receive state | True | None | wordbook
description | LLDP Interface Policy Description | False | None | DAFE Excel Sheet


### Template Body:
```
Verify ACI LLDP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that LLDP Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - Admin State (RX): {{config['lldp_receive']}}
	...  - Admin State (TX): {{config['lldp_transmit']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lldpIfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.name}		{{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].lldpIfPol.attributes.descr}"   "{{config['description']}}"           Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminRxSt}     {{config['lldp_receive']}}     Admin RX State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminTxSt}     {{config['lldp_transmit']}}     Admin TX State not matching expected configuration                 values=False
	


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'LLDP Interface Policy Description',
                 'length': [1, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'lldp_receive': {'default': 'None',
                  'descr': 'LLDP Interface receive state',
                  'enum': ['enabled', 'disabled'],
                  'mandatory': True,
                  'source': 'wordbook'},
 'lldp_transmit': {'default': 'None',
                   'descr': 'LLDP Interface transmit state',
                   'enum': ['enabled', 'disabled'],
                   'mandatory': True,
                   'source': 'wordbook'},
 'name': {'default': 'None',
          'descr': 'LLDP Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## mcpIfPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
description | MCP Interface Policy Description | False | None | DAFE Excel Sheet
name | MCP Interface Policy Name | True | None | DAFE Excel Sheet
mcp_state | Enable or disable MCP on an interface | True | None | wordbook


### Template Body:
```
Verify ACI MCP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that LLDP Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}	
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - MCP State: {{config['mcp_state']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/mcpIfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.name}		{{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].mcpIfPol.attributes.descr}"   "{{config['description']}}"          Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.adminSt}     {{config['mcp_state']}}     		Admin State not matching expected configuration                 values=False


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'MCP Interface Policy Description',
                 'length': [1, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'mcp_state': {'default': 'None',
               'descr': 'Enable or disable MCP on an interface',
               'enum': ['enabled', 'disabled'],
               'mandatory': True,
               'source': 'wordbook'},
 'name': {'default': 'None',
          'descr': 'MCP Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## node_provisioning_apic.robot
### Template Description:
Verifies APIC Node Provisioning.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
apic_hostname | APIC Hostname | True |   | DAFE Excel Sheet
inband_ipv4 | Inband Management IP Address (IPv4) in the form of IP/Mask | False | None | DAFE Excel Sheet
inband_ipv6 | Inband Management IP Address (IPv6) in the form of IP/Mask | False | None | DAFE Excel Sheet
oob_ipv4_gw | Out-of-Band Management Gateway (IPv4) in the form of IP | False | None | DAFE Excel Sheet
pod_id | Node POD ID | True |   | DAFE Excel Sheet
node_id | Node ID | True |   | DAFE Excel Sheet
oob_ipv6_gw | Out-of-Band Management Gateway (IPv6) in the form of IP | False | None | DAFE Excel Sheet
inband_ipv6_gw | Inband Management Gateway (IPv6) in the form of IP | False | None | DAFE Excel Sheet
oob_ipv6 | Out-of-Band Management IP Address (IPv6) in the form of IP/Mask | False | None | DAFE Excel Sheet
inband_ipv4_gw | Inband Management Gateway (IPv4) in the form of IP | False | None | DAFE Excel Sheet
oob_ipv4 | Out-of-Band Management IP Address (IPv4) in the form of IP/Mask | False | None | DAFE Excel Sheet


### Template Body:
```
{% if 'oob_ipv4' not in config %}
  {% set x=config.__setitem__('oob_ipv4', '') %}
{% endif %}
{% if 'oob_ipv4_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv4_gw', '') %}
{% endif %}
{% if 'oob_ipv6' not in config %}
  {% set x=config.__setitem__('oob_ipv6', '') %}
{% endif %}
{% if 'oob_ipv6_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv6_gw', '') %}
{% endif %}
{% if 'inband_ipv4' not in config %}
  {% set x=config.__setitem__('inband_ipv4', '') %}
{% endif %}
{% if 'inband_ipv4_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv4_gw', '') %}
{% endif %}
{% if 'inband_ipv6' not in config %}
  {% set x=config.__setitem__('inband_ipv6', '') %}
{% endif %}
{% if 'inband_ipv6_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv6_gw', '') %}
{% endif %}
Verify ACI APIC Provisioning Configuration - APIC {{config['apic_id']}}
    [Documentation]  Verifies that APIC {{config['apic_id']}} are provisioned with the expected parameters
    ...  - Hostname: {{config['apic_hostname']}}
    ...  - POD ID: {{config['pod_id']}}
    ...  - Node ID: {{config['apic_id']}}
    ...  - Role: controller
    ...  - OOB Address (IPv4): {{config['oob_ipv4']}}
    ...  - OOB Gateway (IPv4): {{config['oob_ipv4_gw']}}
    ...  - OOB Address (IPv6): {{config['oob_ipv6']}}
    ...  - OOB Gateway (IPv6): {{config['oob_ipv6_gw']}}
    ...  - Inband Address (IPv4): {{config['inband_ipv4']}}
    ...  - Inband Gateway (IPv4): {{config['inband_ipv4_gw']}}
    ...  - Inband Address (IPv6): {{config['inband_ipv6']}}
    ...  - Inband Gateway (IPv6): {{config['inband_ipv6_gw']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['apic_id']}}/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  {{config['apic_hostname']}}                 Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  {{config['pod_id']}}                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  {{config['apic_id']}}                         Node ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  controller                                  Node Role not matching expected configuration              values=False
    {% if config['oob_ipv4'] != "" %}
    {% set address = config['oob_ipv4'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr}  {{address[0]}}                       OOB Management Address (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddrMask}  {{address[1]}}                   OOB Management Address Mask (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtGateway}  {{config['oob_ipv4_gw']}}         OOB Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['oob_ipv6'] != "" %}
    {% set address = config['oob_ipv6'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr6}  {{address[0]}}                      OOB Management Address (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr6Mask}  {{address[1]}}                  OOB Management Address Mask (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtGateway6}  {{config['oob_ipv6_gw']}}        OOB Management Gateway (IPv6) not matching expected configuration              values=False
    {% endif %}
    {% if config['inband_ipv4'] != "" %}
    {% set address = config['inband_ipv4'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddr}  {{address[0]}}                       Inband Management Address (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddrMask}  {{address[1]}}                   Inband Management Address Mask (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtGateway}  {{config['inband_ipv4_gw']}}      Inband Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['inband_ipv6'] != "" %}
    {% set address = config['inband_ipv6'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddr6}  {{address[0]}}                      Inband Management Address (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddr6Mask}  {{address[1]}}                  Inband Management Address Mask (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtGateway6}  {{config['inband_ipv6_gw']}}     Inband Management Gateway (IPv6) not matching expected configuration              values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'apic_hostname': {'descr': 'APIC Hostname',
                   'length': [1, 64],
                   'mandatory': True,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'},
 'inband_ipv4': {'default': 'None',
                 'descr': 'Inband Management IP Address (IPv4) in the form of IP/Mask',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'inband_ipv4_gw': {'default': 'None',
                    'descr': 'Inband Management Gateway (IPv4) in the form of IP',
                    'mandatory': False,
                    'source': 'workbook',
                    'type': 'str'},
 'inband_ipv6': {'default': 'None',
                 'descr': 'Inband Management IP Address (IPv6) in the form of IP/Mask',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'inband_ipv6_gw': {'default': 'None',
                    'descr': 'Inband Management Gateway (IPv6) in the form of IP',
                    'mandatory': False,
                    'source': 'workbook',
                    'type': 'str'},
 'node_id': {'descr': 'Node ID',
             'mandatory': True,
             'range': [1, 100],
             'source': 'workbook',
             'type': 'int'},
 'oob_ipv4': {'default': 'None',
              'descr': 'Out-of-Band Management IP Address (IPv4) in the form of IP/Mask',
              'mandatory': False,
              'source': 'workbook',
              'type': 'str'},
 'oob_ipv4_gw': {'default': 'None',
                 'descr': 'Out-of-Band Management Gateway (IPv4) in the form of IP',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'oob_ipv6': {'default': 'None',
              'descr': 'Out-of-Band Management IP Address (IPv6) in the form of IP/Mask',
              'mandatory': False,
              'source': 'workbook',
              'type': 'str'},
 'oob_ipv6_gw': {'default': 'None',
                 'descr': 'Out-of-Band Management Gateway (IPv6) in the form of IP',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'pod_id': {'descr': 'Node POD ID',
            'mandatory': True,
            'range': [1, 10],
            'source': 'workbook',
            'type': 'int'}}
```
## node_provisioning_node.robot
### Template Description:
Verifies Spine/Leaf Node Provisioning.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
oob_gw | Alternative variable for Out-of-Band Management Gateway (IPv4) in the form of IP | False | None | DAFE Excel Sheet
oob_ip | Alternative variable for Out-of-Band Management IP Address (IPv4) in the form of IP/Mask. | False | None | DAFE Excel Sheet
inband_gw | Alternative variable for Inband Management Gateway (IPv4) in the form of IP | False | None | DAFE Excel Sheet
node_id | Node ID | True |   | DAFE Excel Sheet
oob_ipv6_gw | Out-of-Band Management Gateway (IPv6) in the form of IP | False | None | DAFE Excel Sheet
oob_ipv6 | Out-of-Band Management IP Address (IPv6) in the form of IP/Mask | False | None | DAFE Excel Sheet
inband_ipv4_gw | Inband Management Gateway (IPv4) in the form of IP | False | None | DAFE Excel Sheet
oob_ipv4 | Out-of-Band Management IP Address (IPv4) in the form of IP/Mask | False | None | DAFE Excel Sheet
inband_ip | Alternative variable for Inband Management IP Address (IPv4) in the form of IP/Mask | False | None | DAFE Excel Sheet
name | Node Hostname | True |   | DAFE Excel Sheet
inband_ipv4 | Inband Management IP Address (IPv4) in the form of IP/Mask | False | None | DAFE Excel Sheet
inband_ipv6 | Inband Management IP Address (IPv6) in the form of IP/Mask | False | None | DAFE Excel Sheet
oob_ipv4_gw | Out-of-Band Management Gateway (IPv4) in the form of IP | False | None | DAFE Excel Sheet
pod_id | Node POD ID | True |   | DAFE Excel Sheet
role | Node Role | True |   | DAFE Excel Sheet
inband_ipv6_gw | Inband Management Gateway (IPv6) in the form of IP | False | None | DAFE Excel Sheet
serial_number | Node Serial Number | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'oob_ip' not in config %}
  {% set x=config.__setitem__('oob_ip', '') %}
{% endif %}
{% if 'oob_gw' not in config %}
  {% set x=config.__setitem__('oob_gw', '') %}
{% endif %}
{% if 'inband_ip' not in config %}
  {% set x=config.__setitem__('inband_ip', '') %}
{% endif %}
{% if 'inband_gw' not in config %}
  {% set x=config.__setitem__('inband_gw', '') %}
{% endif %}
{% if 'oob_ipv4' not in config %}
  {% set x=config.__setitem__('oob_ipv4', config['oob_ip']) %}
{% endif %}
{% if 'oob_ipv4_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv4_gw', config['oob_gw']) %}
{% endif %}
{% if 'oob_ipv6' not in config %}
  {% set x=config.__setitem__('oob_ipv6', '') %}
{% endif %}
{% if 'oob_ipv6_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv6_gw', '') %}
{% endif %}
{% if 'inband_ipv4' not in config %}
  {% set x=config.__setitem__('inband_ipv4', config['inband_ip']) %}
{% endif %}
{% if 'inband_ipv4_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv4_gw', config['inband_gw']) %}
{% endif %}
{% if 'inband_ipv6' not in config %}
  {% set x=config.__setitem__('inband_ipv6', '') %}
{% endif %}
{% if 'inband_ipv6_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv6_gw', '') %}
{% endif %}
Verify ACI Node Provisioning Configuration - Node {{config['node_id']}}
    [Documentation]  Verifies that Node {{config['node_id']}} are provisioned with the expected parameters
    ...  - Hostname: {{config['name']}}
    ...  - POD ID: {{config['pod_id']}}
    ...  - Node ID: {{config['node_id']}}
    ...  - Serial Number: {{config['serial_number']}}
    ...  - Role: {{config['role']}}
    ...  - OOB Address (IPv4): {{config['oob_ipv4']}}
    ...  - OOB Gateway (IPv4): {{config['oob_ipv4_gw']}}
    ...  - OOB Address (IPv6): {{config['oob_ipv6']}}
    ...  - OOB Gateway (IPv6): {{config['oob_ipv6_gw']}}
    ...  - Inband Address (IPv4): {{config['inband_ipv4']}}
    ...  - Inband Gateway (IPv4): {{config['inband_ipv4_gw']}}
    ...  - Inband Address (IPv6): {{config['inband_ipv6']}}
    ...  - Inband Gateway (IPv6): {{config['inband_ipv6_gw']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  {{config['name']}}                          Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  {{config['pod_id']}}                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  {{config['node_id']}}                         Node ID not matching expected configuration              values=False
    {% if config['serial_number'] != "" %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.serial}  {{config['serial_number']}}               Serial Number not matching expected configuration              values=False
    {% endif %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  {{config['role']}}                          Node Role not matching expected configuration              values=False
    {% if config['oob_ipv4'] != "" or config['oob_ipv6'] != "" %}
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}]
    ${oob}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${oob.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${oob.totalCount}	1		Out-of-Band Management not configured   values=False
    {% if config['oob_ipv4'] != "" %}
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.addr}  {{config['oob_ipv4']}}                   OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.gw}  {{config['oob_ipv4_gw']}}             OOB Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['oob_ipv6'] != "" %}
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.v6Addr}  {{config['oob_ipv6']}}                 OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.v6Gw}  {{config['oob_ipv6_gw']}}           OOB Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% endif %}
    {% if config['inband_ipv4'] != "" or config['inband_ipv6'] != "" %}
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/inb-default/rsinBStNode-[topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}]
    ${inb}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${inb.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${inb.totalCount} 	1		Inband Management not configured   values=False
    {% if config['inband_ipv4'] != "" %}
    run keyword if  ${inb.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.addr}  {{config['inband_ipv4']}}                Inband Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.gw}  {{config['inband_ipv4_gw']}}          Inband Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['inband_ipv6'] != "" %}
    run keyword if  ${inb.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.v6Addr}  {{config['inband_ipv6']}}              Inband Management Address (IPv6) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.v6Gw}  {{config['inband_ipv6_gw']}}        Inband Management Gateway (IPv6) not matching expected configuration              values=False
    {% endif %}
    {% endif %}


```
### Template Data Validation Model:
```json
{'inband_gw': {'default': 'None',
               'descr': 'Alternative variable for Inband Management Gateway (IPv4) in the form of IP',
               'mandatory': False,
               'source': 'workbook',
               'type': 'str'},
 'inband_ip': {'default': 'None',
               'descr': 'Alternative variable for Inband Management IP Address (IPv4) in the form of IP/Mask',
               'mandatory': False,
               'source': 'workbook',
               'type': 'str'},
 'inband_ipv4': {'default': 'None',
                 'descr': 'Inband Management IP Address (IPv4) in the form of IP/Mask',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'inband_ipv4_gw': {'default': 'None',
                    'descr': 'Inband Management Gateway (IPv4) in the form of IP',
                    'mandatory': False,
                    'source': 'workbook',
                    'type': 'str'},
 'inband_ipv6': {'default': 'None',
                 'descr': 'Inband Management IP Address (IPv6) in the form of IP/Mask',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'inband_ipv6_gw': {'default': 'None',
                    'descr': 'Inband Management Gateway (IPv6) in the form of IP',
                    'mandatory': False,
                    'source': 'workbook',
                    'type': 'str'},
 'name': {'descr': 'Node Hostname',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'node_id': {'descr': 'Node ID',
             'mandatory': True,
             'range': [101, 4000],
             'source': 'workbook',
             'type': 'int'},
 'oob_gw': {'default': 'None',
            'descr': 'Alternative variable for Out-of-Band Management Gateway (IPv4) in the form of IP',
            'mandatory': False,
            'source': 'workbook',
            'type': 'str'},
 'oob_ip': {'default': 'None',
            'descr': 'Alternative variable for Out-of-Band Management IP Address (IPv4) in the form of IP/Mask.',
            'mandatory': False,
            'source': 'workbook',
            'type': 'str'},
 'oob_ipv4': {'default': 'None',
              'descr': 'Out-of-Band Management IP Address (IPv4) in the form of IP/Mask',
              'mandatory': False,
              'source': 'workbook',
              'type': 'str'},
 'oob_ipv4_gw': {'default': 'None',
                 'descr': 'Out-of-Band Management Gateway (IPv4) in the form of IP',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'oob_ipv6': {'default': 'None',
              'descr': 'Out-of-Band Management IP Address (IPv6) in the form of IP/Mask',
              'mandatory': False,
              'source': 'workbook',
              'type': 'str'},
 'oob_ipv6_gw': {'default': 'None',
                 'descr': 'Out-of-Band Management Gateway (IPv6) in the form of IP',
                 'mandatory': False,
                 'source': 'workbook',
                 'type': 'str'},
 'pod_id': {'descr': 'Node POD ID',
            'mandatory': True,
            'range': [1, 10],
            'source': 'workbook',
            'type': 'int'},
 'role': {'descr': 'Node Role',
          'enum': ['leaf', 'spine'],
          'mandatory': True,
          'source': 'workbook'},
 'serial_number': {'descr': 'Node Serial Number',
                   'length': [1, 64],
                   'mandatory': False,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'workbook',
                   'type': 'str'}}
```
## stormctrlIfPol.robot
### Template Description:
Verifies Fabric Access Interface Policy configuration.

The following type of interface policies are verifed by this template
* LLDP
* Port Channel
* Spanning Tree
* Link Level
* CDP
* L2 Interface


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
### Template Body:
```
Verify ACI LLDP Interface Policy Configuration - Policy Name lldp_enabled
    [Documentation]   Verifies that LLDP Interface Policy 'lldp_enabled' are configured with the expected parameters
    ...  - Interface Policy Name: lldp_enabled
	...  - Admin State (RX): enabled
	...  - Admin State (TX): enabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lldpIfP-lldp_enabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.name}		lldp_enabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminRxSt}     enabled     Admin RX State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminTxSt}     enabled     Admin TX State not matching expected configuration                 values=False

Verify ACI LLDP Interface Policy Configuration - Policy Name lldp_disabled
    [Documentation]   Verifies that LLDP Interface Policy 'lldp_disabled' are configured with the expected parameters
    ...  - Interface Policy Name: lldp_disabled
	...  - Admin State (RX): disabled
	...  - Admin State (TX): disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lldpIfP-lldp_disabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.name}		lldp_disabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminRxSt}     disabled     Admin RX State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminTxSt}     disabled     Admin TX State not matching expected configuration                 values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name static_on
    [Documentation]   Verifies that Port Channel Interface Policy 'static_on' are configured with the expected parameters
    ...  - Interface Policy Name: static_on
	...  - LACP Mode: off
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-static_on
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		static_on       Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		off                                                 LACP Mode not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1                                                   Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16                                                  Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,susp-individual    Control not matching expected configuration                   values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name mac_pinning
    [Documentation]   Verifies that Port Channel Interface Policy 'mac_pinning' are configured with the expected parameters
    ...  - Interface Policy Name: mac_pinning
	...  - LACP Mode: mac-pin
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-mac_pinning
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		mac_pinning     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		mac-pin                                             LACP Mode not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1                                                   Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16                                                  Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,susp-individual    Control not matching expected configuration                   values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name lacp_passive
    [Documentation]   Verifies that Port Channel Interface Policy 'lacp_passive' are configured with the expected parameters
    ...  - Interface Policy Name: lacp_passive
	...  - LACP Mode: passive
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-lacp_passive
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		lacp_passive    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		passive                                             LACP Mode not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1                                                   Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16                                                  Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,susp-individual    Control not matching expected configuration                   values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name lacp_active
    [Documentation]   Verifies that Port Channel Interface Policy 'lacp_active' are configured with the expected parameters
    ...  - Interface Policy Name: lacp_active
	...  - LACP Mode: active
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-lacp_active
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		lacp_active     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		active                                              LACP Mode not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1                                                   Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16                                                  Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,susp-individual    Control not matching expected configuration                   values=False

Verify ACI STP Interface Policy Configuration - Policy Name bpdu_guard
    [Documentation]   Verifies that STP Channel Interface Policy 'bpdu_guard' are configured with the expected parameters
    ...  - Interface Policy Name: bpdu_guard
	...  - Control: bpdu-guard
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-bpdu_guard
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		bpdu_guard      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.ctrl}		bpdu-guard      Control not matching expected configuration                   values=False

Verify ACI STP Interface Policy Configuration - Policy Name bpdu_filter
    [Documentation]   Verifies that STP Channel Interface Policy 'bpdu_filter' are configured with the expected parameters
    ...  - Interface Policy Name: bpdu_filter
	...  - Control: bpdu-filter
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-bpdu_filter
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		bpdu_filter     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.ctrl}		bpdu-filter     Control not matching expected configuration                   values=False

Verify ACI STP Interface Policy Configuration - Policy Name bpdu_filter_guard_enabled
    [Documentation]   Verifies that STP Channel Interface Policy 'bpdu_filter_guard_enabled' are configured with the expected parameters
    ...  - Interface Policy Name: bpdu_filter_guard_enabled
	...  - Control: bpdu-filter,bpdu-guard
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-bpdu_filter_guard_enabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		bpdu_filter_guard_enabled       Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.ctrl}		bpdu-filter,bpdu-guard      Control not matching expected configuration                   values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 40gig_auto
    [Documentation]   Verifies that Link Level Channel Interface Policy '40gig_auto' are configured with the expected parameters
    ...  - Interface Policy Name: 40gig_auto
	...  - Speed: 40G
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-40gig_auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	40gig_auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			40G         Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         LinkDebounce not matching expected configuration            values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 10gig_auto
    [Documentation]   Verifies that Link Level Channel Interface Policy '10gig_auto' are configured with the expected parameters
    ...  - Interface Policy Name: 10gig_auto
	...  - Speed: 10G
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-10gig_auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	10gig_auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			10G         Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         LinkDebounce not matching expected configuration            values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 10gig_off
    [Documentation]   Verifies that Link Level Channel Interface Policy '10gig_off' are configured with the expected parameters
    ...  - Interface Policy Name: 10gig_off
	...  - Speed: 10G
	...  - Auto Negotiation: off
	...  - Link Debounce Interval: 100
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-10gig_off
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	10gig_off      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			10G         Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		off          AutoNeg not matching expected configuration                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         LinkDebounce not matching expected configuration            values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 1gig_auto
    [Documentation]   Verifies that Link Level Channel Interface Policy '1gig_auto' are configured with the expected parameters
    ...  - Interface Policy Name: 1gig_auto
	...  - Speed: 1G
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-1gig_auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	1gig_auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			1G         Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on         AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100        LinkDebounce not matching expected configuration            values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name auto
    [Documentation]   Verifies that Link Level Channel Interface Policy 'auto' are configured with the expected parameters
    ...  - Interface Policy Name: auto
	...  - Speed: inherit
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			inherit     Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         LinkDebounce not matching expected configuration            values=False

Verify ACI CDP Interface Policy Configuration - Policy Name cdp_enabled
    [Documentation]   Verifies that CDP Interface Policy 'cdp_enabled' are configured with the expected parameters
    ...  - Interface Policy Name: cdp_enabled
	...  - Admin State: enabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/cdpIfP-cdp_enabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.name}		cdp_enabled     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.adminSt}	enabled     Admin State not matching expected configuration                   values=False

Verify ACI CDP Interface Policy Configuration - Policy Name cdp_disabled
    [Documentation]   Verifies that CDP Interface Policy 'cdp_disabled' are configured with the expected parameters
    ...  - Interface Policy Name: cdp_disabled
	...  - Admin State: disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/cdpIfP-cdp_disabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.name}		cdp_disabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.adminSt}	disabled    Admin State not matching expected configuration                   values=False

Verify ACI L2 Interface Policy Configuration - Policy Name portlocal_vlan_scope
    [Documentation]   Verifies that L2 Interface Policy 'portlocal_vlan_scope' are configured with the expected parameters
    ...  - Interface Policy Name: portlocal_vlan_scope
	...  - VLAN Scope: portlocal
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/l2IfP-portlocal_vlan_scope
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.name}			portlocal_vlan_scope    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vlanScope}	portlocal   VLAN Scope not matching expected configuration                   values=False

Verify ACI L2 Interface Policy Configuration - Policy Name global_vlan_scope
    [Documentation]   Verifies that L2 Interface Policy 'global_vlan_scope' are configured with the expected parameters
    ...  - Interface Policy Name: global_vlan_scope
	...  - VLAN Scope: global
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/l2IfP-global_vlan_scope
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.name}			global_vlan_scope   Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vlanScope}	global      VLAN Scope not matching expected configuration                   values=False


```
### Template Data Validation Model:
No Validation model defined
## stpIfPol.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
stp_control | STP BPDU Control feature | False | None | wordbook
name | STP Interface Policy Name | True | None | DAFE Excel Sheet
description | STP Interface Policy Description | False | None | DAFE Excel Sheet


### Template Body:
```
Verify ACI STP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that STP Channel Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - STP Control: {{config['stp_control']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		{{config['name']}}      Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].stpIfPol.attributes.descr}"   "{{config['description']}}"          Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].stpIfPol.attributes.ctrl}"		"{{config['stp_control']}}"      	STP Control not matching expected configuration                   values=False


```
### Template Data Validation Model:
```json
{'description': {'default': 'None',
                 'descr': 'STP Interface Policy Description',
                 'length': [1, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'default': 'None',
          'descr': 'STP Interface Policy Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'stp_control': {'default': 'None',
                 'descr': 'STP BPDU Control feature',
                 'enum': ['bpdu-filter',
                          'bpdu-guard',
                          'bpdu-filter,bpdu-guard'],
                 'mandatory': False,
                 'source': 'wordbook'}}
```
## tep_pool_setup.robot
### Template Description:
Verifies ACI TEP Pool Configuration.

> The template reads the intended TEP Pool configuration from two DAFE excel workbooks:
> * 'fabric_initial_config' workbook for POD 1
> * 'pod_tep_pool' for all other PODs

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tep_pool | TEP Pool | True |   | DAFE Excel Sheet
pod_id | POD ID, asumed to be 1 for the TEP Pool defined in 'fabric_initial_config' workbook | True |   | DAFE Excel Sheet


### Template Body:
```
{% set tepDict = [{'pod_id': '1', 'tep_pool': dafe_data.fabric_initial_config.row(parameters='TEP Pool').value,}] %}
{% for row in dafe_data.pod_tep_pool %}
{% set x = tepDict.append({'pod_id': row.pod_id, 'tep_pool': row.tep_pool}) %}
{% endfor %}
{% for pod in tepDict %}
Verify ACI TEP Pool Configuration - POD {{pod.pod_id}}
    [Documentation]   Verifies that ACI TEP Pool Configuration for POD {{pod.pod_id}}
    ...  - POD ID: {{pod.pod_id}}
    ...  - TEP Pool: {{pod.tep_pool}}
    [Tags]      aci-conf  aci-fabric-tep-pool
    ${return}=  via ACI REST API retrieve "/api/mo/uni/controller/setuppol/setupp-{{pod.pod_id}}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200      Failure executing API call		values=False
    should be equal as strings      ${return.totalCount}  1     Fabric POD does not exist	values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fabricSetupP.attributes.tepPool}   {{pod.tep_pool}}        TEP Pool not matching expected configuration	            values=False


{% endfor %}
```
### Template Data Validation Model:
```json
{'pod_id': {'descr': "POD ID, asumed to be 1 for the TEP Pool defined in 'fabric_initial_config' workbook",
            'length': [1, 64],
            'mandatory': True,
            'source': 'workbook',
            'type': 'str'},
 'tep_pool': {'descr': 'TEP Pool',
              'length': [1, 64],
              'mandatory': True,
              'source': 'workbook',
              'type': 'str'}}
```
## vmmDomP.robot
### Template Description:
Verifies VMware VMM domain configuration.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
vcenter_username | vCenter Username | True |   | DAFE Excel Sheet
vcenter_hostname_ip | vCenter hostname/IP | True | None | DAFE Excel Sheet
name | VMM Domain Name | True |   | DAFE Excel Sheet
fw_policy | FW Policy | False |  | DAFE Excel Sheet
cdp_policy | CDP Interface Policy | False |  | DAFE Excel Sheet
vcenter_controller_name | vCenter Controller Name | True |   | DAFE Excel Sheet
vmm_type | VMM Domain Type | False | vmm_vmware | DAFE Excel Sheet
vmm_sw_mode | vSwitch Type | False | default | DAFE Excel Sheet
vcenter_datacenter_name | vCenter Datacenter Name | True |   | DAFE Excel Sheet
lldp_policy | LLDP Interface Policy | False |  | DAFE Excel Sheet
lacp_policy | LACP Interface Policy | False |  | DAFE Excel Sheet
l2_policy | L2 Interface Policy | False |  | DAFE Excel Sheet
stp_policy | Spanning-tree Interface Policy | False |  | DAFE Excel Sheet
vcenter_credential_profile | vCenter Credential Profile Name | True |   | DAFE Excel Sheet


### Template Body:
```
{% if 'vmm_type' not in config %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% elif config['vmm_type'] not in ['vmware'] %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% endif %}
{% if 'vmm_sw_mode' not in config %}
  {% set x=config.__setitem__('vmm_sw_mode', 'default') %}
{% endif %}
{% if 'stp_policy' not in config %}
  {% set x=config.__setitem__('stp_policy', '') %}
{% endif %}
{% if 'lldp_policy' not in config %}
  {% set x=config.__setitem__('lldp_policy', '') %}
{% endif %}
{% if 'cdp_policy' not in config %}
  {% set x=config.__setitem__('cdp_policy', '') %}
{% endif %}
{% if 'lacp_policy' not in config %}
  {% set x=config.__setitem__('lacp_policy', '') %}
{% endif %}
{% if 'l2_policy' not in config %}
  {% set x=config.__setitem__('l2_policy', '') %}
{% endif %}
{% if 'fw_policy' not in config %}
  {% set x=config.__setitem__('fw_policy', '') %}
{% endif %}
{% if config['vmm_type'] == "vmware" %}
Verify ACI VMware VMM Domain Configuration - Domain {{config['name']}}
    [Documentation]   Verifies that ACI VMM Domain '{{config['name']}}' are configured with the expected parameters
    ...  - VMM Domain Name:  {{config['name']}}
	...  - VMM Switch Type:  {{config['vmm_sw_mode']}}
    ...  - vCenter Datacenter: {{config['vcenter_datacenter_name']}}
    ...  - vCenter Controller Name: {{config['vcenter_controller_name']}}
    ...  - vCenter Hostname/IP: {{config['vcenter_hostname_ip']}}
    ...  - vCenter Credential Profile Name: {{config['vcenter_credential_profile']}}
    ...  - vCenter Username: {{config['vcenter_username']}}
    {% if config['stp_policy'] != '' %}
    ...  - STP Interface Policy: {{config['stp_policy']}}
    {% endif %}
    {% if config['lldp_policy'] != '' %}
    ...  - LLDP Interface Policy: {{config['lldp_policy']}}
    {% endif %}
    {% if config['cdp_policy'] != '' %}
    ...  - CDP Interface Policy: {{config['cdp_policy']}}
    {% endif %}
    {% if config['lacp_policy'] != '' %}
    ...  - LACP Interface Policy: {{config['lacp_policy']}}
    {% endif %}
    {% if config['l2_policy'] != '' %}
    ...  - L2 Interface Policy: {{config['l2_policy']}}
    {% endif %}
    {% if config['fw_policy'] != '' %}
    ...  - FW Policy: {{config['fw_policy']}}
    {% endif %}
    [Tags]      aci-conf  aci-vmm  aci-vmm-vmware
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		VMM Domain does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].vmmDomP.attributes.name}   {{config['name']}}        Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].vmmDomP.attributes.mode}"   "{{config['vmm_sw_mode']}}"      vSwitch Mode not matching expected configuration                 values=False
    {% if config['stp_policy'] != '' %}
	# STP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultStpIfPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultStpIfPol.tnStpIfPolName, "{{config['stp_policy']}}")
	${stp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${stp.totalCount}	1		STP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['lldp_policy'] != '' %}
	# LLDP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultLldpIfPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultLldpIfPol.tnLldpIfPolName, "{{config['lldp_policy']}}")
	${lldp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${lldp.totalCount}	1		LLDP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['cdp_policy'] != '' %}
	# CDP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultCdpIfPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultCdpIfPol.tnCdpIfPolName, "{{config['cdp_policy']}}")
	${cdp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${cdp.totalCount}	1		CDP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['lacp_policy'] != '' %}
	# LACP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultLacpLagPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultLacpLagPol.tnLacpLagPolName, "{{config['lacp_policy']}}")
	${lacp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${lacp.totalCount}	1		LACP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['l2_policy'] != '' %}
	# L2 Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultL2InstPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultL2InstPol.tnL2InstPolName, "{{config['l2_policy']}}")
	${l2}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${l2.totalCount}	1		L2 Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['fw_policy'] != '' %}
	# FW Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultFwPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultFwPol.tnNwsFwPolName, "{{config['fw_policy']}}")
	${fw}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${fw.totalCount}	1		FW Policy not matching expected configuration	values=False
    {% endif %}
	# Credential Profile Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmUsrAccP&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmUsrAccP.name, "{{config['vcenter_credential_profile']}}")
	${credential}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${credential.status}		200		Failure executing API call			values=False
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${credential.totalCount}	1		Credential Profile '{{config['vcenter_credential_profile']}}' not associated with VMM Domain	values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${credential.payload[0].vmmDomP.children[0].vmmUsrAccP.attributes.usr}	{{config['vcenter_username']}}	    vCenter Username not matching expected configuration    values=False
	# vCenter Profile
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}/ctrlr-{{config['vcenter_controller_name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsAcc
	${vcenter}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${vcenter.status}		200		Failure executing API call			values=False
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${vcenter.totalCount}	1		vCenter Profile '{{config['vcenter_controller_name']}}' not associated with VMM Domain	values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.attributes.hostOrIp}		{{config['vcenter_hostname_ip']}}	        vCenter Hostname/IP not matching expected configuration    values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.attributes.rootContName}		{{config['vcenter_datacenter_name']}}	vCenter Datacenter not matching expected configuration    values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.children[0].vmmRsAcc.attributes.tDn}		uni/vmmp-VMware/dom-{{config['name']}}/usracc-{{config['vcenter_credential_profile']}}	vCenter Credential Profile not matching expected configuration    values=False
{% endif %}


```
### Template Data Validation Model:
```json
{'cdp_policy': {'default': '',
                'descr': 'CDP Interface Policy',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'fw_policy': {'default': '',
               'descr': 'FW Policy',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'l2_policy': {'default': '',
               'descr': 'L2 Interface Policy',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'lacp_policy': {'default': '',
                 'descr': 'LACP Interface Policy',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'lldp_policy': {'default': '',
                 'descr': 'LLDP Interface Policy',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'descr': 'VMM Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'stp_policy': {'default': '',
                'descr': 'Spanning-tree Interface Policy',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'vcenter_controller_name': {'descr': 'vCenter Controller Name',
                             'length': [1, 64],
                             'mandatory': True,
                             'regex': {'exact_match': False,
                                       'pattern': '[a-zA-Z0-9_.:-]+'},
                             'source': 'workbook',
                             'type': 'str'},
 'vcenter_credential_profile': {'descr': 'vCenter Credential Profile Name',
                                'length': [1, 64],
                                'mandatory': True,
                                'regex': {'exact_match': False,
                                          'pattern': '[a-zA-Z0-9_.:-]+'},
                                'source': 'workbook',
                                'type': 'str'},
 'vcenter_datacenter_name': {'descr': 'vCenter Datacenter Name',
                             'length': [1, 64],
                             'mandatory': True,
                             'regex': {'exact_match': False,
                                       'pattern': '[a-zA-Z0-9_.:-]+'},
                             'source': 'workbook',
                             'type': 'str'},
 'vcenter_hostname_ip': {'default': 'None',
                         'descr': 'vCenter hostname/IP',
                         'mandatory': True,
                         'source': 'workbook',
                         'type': 'str'},
 'vcenter_username': {'descr': 'vCenter Username',
                      'length': [1, 64],
                      'mandatory': True,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-@]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'vmm_sw_mode': {'default': 'default',
                 'descr': 'vSwitch Type',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'vmm_type': {'default': 'vmm_vmware',
              'descr': 'VMM Domain Type',
              'enum': ['vmm_vmware'],
              'mandatory': False,
              'source': 'workbook'}}
```
## vpcDom.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
right_node_id | Node id of the second vPC Domain Member | True |   | DAFE Excel Sheet
name | vPC Domain Name | True |   | DAFE Excel Sheet
left_node_id | Node id of the first vPC Domain Member | True |   | DAFE Excel Sheet
logical_pair_id | vPC Domain id | True |   | DAFE Excel Sheet


### Template Body:
```
Verify ACI vPC Domain Configuration - Domain {{config['name']}}
    [Documentation]   Verifies that vPC Domain (or vPC Explicit Protection Group) '{{config['name']}}' are configured with the expected parameters
    ...  - vPC Domain Name:  {{config['name']}}
    ...  - Logical Pair ID: {{config['logical_pair_id']}}
    ...  - Left Node ID: {{config['left_node_id']}}
    ...  - Right Node ID: {{config['right_node_id']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-vpc-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/protpol/expgep-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=fabricNodePEp
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		vPC Domain does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].fabricExplicitGEp.attributes.name}   {{config['name']}}      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricExplicitGEp.attributes.id}		{{config['logical_pair_id']}}           Logical Pair ID not matching expected configuration                 values=False
    # Iterate through the fabric nodes
    Set Test Variable  ${left_node_found}		"Node not found"
    Set Test Variable  ${right_node_found}		"Node not found"
    : FOR  ${node}  IN  @{return.payload[0].fabricExplicitGEp.children}
	\  run keyword if  "${node.fabricNodePEp.attributes.id}" == "{{config['left_node_id']}}"  run keyword
	\  ...  Set Test Variable  ${left_node_found}  "Node found"
	\  run keyword if  "${node.fabricNodePEp.attributes.id}" == "{{config['right_node_id']}}"  run keyword
	\  ...  Set Test Variable  ${right_node_found}  "Node found"
	run keyword if  not ${left_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Fabric Node '{{config['left_node_id']}}' not associated with vPC Domain
	run keyword if  not ${right_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Fabric Node '{{config['right_node_id']}}' not associated with vPC Domain


```
### Template Data Validation Model:
```json
{'left_node_id': {'descr': 'Node id of the first vPC Domain Member',
                  'mandatory': True,
                  'range': [101, 4000],
                  'source': 'workbook',
                  'type': 'int'},
 'logical_pair_id': {'descr': 'vPC Domain id',
                     'mandatory': True,
                     'range': [1, 1000],
                     'source': 'workbook',
                     'type': 'int'},
 'name': {'descr': 'vPC Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'right_node_id': {'descr': 'Node id of the second vPC Domain Member',
                   'mandatory': True,
                   'range': [101, 4000],
                   'source': 'workbook',
                   'type': 'int'}}
```
## vzBrCp.robot
### Template Description:
Verifies Contract configuration

If not specified:
* QoS Class assumed to be configured as unspecified
* targetDscp assumed to be configured as unspecified


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
name | Contract Name | True |   | DAFE Excel Sheet
name_alias | Contract name alias | False |   | DAFE Excel Sheet
tag | Tag the contract is associated with | False |   | DAFE Excel Sheet
qos_class | User-Defined QOS Class | False | unspecified | DAFE Excel Sheet
scope | The Scope of the contract | True |   | DAFE Excel Sheet
target_dscp |  | False | unspecified | DAFE Excel Sheet
tenant | Parent tenant Name | True |   | DAFE Excel Sheet
description | Contract description string | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['level1', 'level2', 'level3', 'unspecified'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
{% if 'target_dscp' not in config %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% elif config['target_dscp'] not in ['unspecified', 'CS0', 'CS1', 'AF11', 'AF12', 'AF13', 'CS2', 'AF21', 'AF22', 'AF23', 'CS3', 'AF31', 'AF32', 'AF33', 'CS4', 'AF41', 'AF42', 'AF43', 'VA', 'CS5', 'EF', 'CS6', 'CS7'] %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
{% if 'tag' not in config %}
  {% set x=config.__setitem__('tag', '') %}
{% endif %}
Verify ACI Contract Configuration - Tenant {{config['tenant']}}, Contract {{config['name']}}
    [Documentation]   Verifies that ACI Contract '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Contract Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Scope: {{config['scope']}}
    ...  - Priority / QoS Class: {{config['qos_class']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    {% if config['tag'] != "" %}
    ...  - Tag: {{config['tag']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
	# Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.scope}"  "{{config['scope']}}"                          Scope not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.prio}"  "{{config['qos_class']}}"                       Priority / QoS Class not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.targetDscp}"  "{{config['target_dscp']}}"               Target DSCP not matching expected configuration                values=False
    {% if config['tag'] != '' %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['name']}}/tag-{{config['tag']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Tag not matching expected configuration		values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'description': {'descr': 'Contract description string',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'descr': 'Contract Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'name_alias': {'descr': 'Contract name alias',
                'length': [1, 64],
                'mandatory': False,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'qos_class': {'default': 'unspecified',
               'descr': 'User-Defined QOS Class',
               'mandatory': False,
               'source': 'workbook',
               'type': {'enum': ['level1',
                                 'level2',
                                 'level3',
                                 'unspecified']}},
 'scope': {'descr': 'The Scope of the contract',
           'mandatory': True,
           'source': 'workbook',
           'type': {'enum': ['application-profile',
                             'tenant',
                             'context',
                             'global']}},
 'tag': {'descr': 'Tag the contract is associated with',
         'length': [1, 64],
         'mandatory': False,
         'regex': {'exact_match': False,
                   'pattern': '[a-zA-Z0-9=!#$%()*,-.:;@ _{|}~?&+]+'},
         'source': 'workbook',
         'type': 'str'},
 'target_dscp': {'default': 'unspecified',
                 'descr': '',
                 'enum': ['unspecified',
                          'CS0',
                          'CS1',
                          'AF11',
                          'AF12',
                          'AF13',
                          'CS2',
                          'AF21',
                          'AF22',
                          'AF23',
                          'CS3',
                          'AF31',
                          'AF32',
                          'AF33',
                          'CS4',
                          'AF41',
                          'AF42',
                          'AF43',
                          'VA',
                          'CS5',
                          'EF',
                          'CS6',
                          'CS7'],
                 'mandatory': False,
                 'source': 'workbook'},
 'tenant': {'descr': 'Parent tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## vzEntry.robot
### Template Description:
Verifies Contract Filter Entry configuration


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tcp_flags | TCP Flags | False |  | DAFE Excel Sheet
icmpv6_message | ICMPv6 message type Flags | False | unspecified | DAFE Excel Sheet
IP_protocol | IP Protocol | False | unspecified | DAFE Excel Sheet
to_source_port | End source port block | False | unspecified | DAFE Excel Sheet
arp_flag | ARP flags | False | unspecified | DAFE Excel Sheet
stateful | Stateful control knob | False | no | DAFE Excel Sheet
match_only_fragments | Match only fragments control knob | False | no | DAFE Excel Sheet
icmp_message | ICMPv4 message type Flags | False | unspecified | DAFE Excel Sheet
tenant | Tenant name | True |   | DAFE Excel Sheet
ether_type | Ether Type | True | unspecified | DAFE Excel Sheet
name | Filter Entry Name | True | None | DAFE Excel Sheet
description | Filter Description field | False | None | DAFE Excel Sheet
to_destination_port | End destination port block | False | unspecified | DAFE Excel Sheet
filter | Filter Name | True | None | DAFE Excel Sheet
from_destination_port | Start destination port block | False | unspecified | DAFE Excel Sheet
nameAlias | Filter Name Alias | False | None | DAFE Excel Sheet
from_source_port | Start source port block | False | unspecified | DAFE Excel Sheet


### Template Body:
```
{%- set port_dictionary = {
                              '25': 'smtp',
                              '20': 'ftp-data',
                              '53': 'dns',
                              '80': 'http',
                              '110': 'pop3',
                              '443': 'https',
                              '554': 'rtsp'
                          }
-%}
{% if 'from_source_port' not in config or config['from_source_port'] == ""%}
  {% set x=config.__setitem__('from_source_port', 'unspecified') %}
  {% set from_source_port = 'unspecified' %}
{% elif config['from_source_port'] == 'unspecified' %}
  {% set from_source_port = config['from_source_port'] %}
{% elif config['from_source_port'] in port_dictionary %}
  {% set from_source_port = port_dictionary[config['from_source_port']] %}
{% else %}
  {% set from_source_port = config['from_source_port'] %}
{% endif %}
{% if 'to_source_port' not in config or config['to_source_port'] == "" %}
  {% set x=config.__setitem__('to_source_port', 'unspecified') %}
  {% set to_source_port = 'unspecified' %}
{% elif config['to_source_port'] == 'unspecified' %}
  {% set to_source_port = config['to_source_port'] %}
{% elif config['to_source_port'] in port_dictionary %}
  {% set to_source_port = port_dictionary[config['to_source_port']] %}
{% else %}
  {% set to_source_port = config['to_source_port'] %}
{% endif %}
{% if 'from_destination_port' not in config or config['from_destination_port'] == ""%}
  {% set x=config.__setitem__('from_destination_port', 'unspecified') %}
  {% set from_destination_port = 'unspecified' %}
{% elif config['from_destination_port'] == 'unspecified' %}
  {% set from_destination_port = config['from_destination_port'] %}
{% elif config['from_destination_port'] in port_dictionary %}
  {% set from_destination_port = port_dictionary[config['from_destination_port']] %}
{% else %}
  {% set from_destination_port = config['from_destination_port'] %}
{% endif %}
{% if 'to_destination_port' not in config or config['to_destination_port'] == "" %}
  {% set x=config.__setitem__('to_destination_port', 'unspecified') %}
  {% set to_destination_port = 'unspecified' %}
{% elif config['to_destination_port'] == 'unspecified' %}
  {% set to_destination_port = config['to_destination_port'] %}
{% elif config['to_destination_port'] in port_dictionary %}
  {% set to_destination_port = port_dictionary[config['to_destination_port']] %}
{% else %}
  {% set to_destination_port = config['to_destination_port'] %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'ether_type' not in config or config['ether_type'] == ""%}
  {% set x=config.__setitem__('ether_type', 'unspecified') %}
{% endif %}
{% if 'IP_protocol' not in config or config['IP_protocol'] == ""%}
  {% set x=config.__setitem__('IP_protocol', 'unspecified') %}
{% endif %}
{% if 'tcp_flags' not in config %}
  {% set x=config.__setitem__('tcp_flags', '') %}
{% endif %}
{% if 'match_only_fragments' not in config %}
  {% set x=config.__setitem__('match_only_fragments', 'no') %}
{% elif config['match_only_fragments'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('match_only_fragments', 'no') %}
{% endif %}
{% if 'stateful' not in config %}
  {% set x=config.__setitem__('stateful', 'no') %}
{% elif config['stateful'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('stateful', 'no') %}
{% endif %}
{% if 'arp_flag' not in config %}
  {% set x=config.__setitem__('arp_flag', 'unspecified') %}
{% elif config['arp_flag'] not in ['unspecified', 'reply', 'request'] %}
  {% set x=config.__setitem__('arp_flag', 'unspecified') %}
{% endif %}
Verify ACI Contract Filter Entry Configuration - Tenant {{config['tenant']}}, Filter {{config['filter']}}, Entry {{config['name']}}
    [Documentation]   Verifies that ACI Contract Filter Entry '{{config['name']}}' are configured under tenant '{{config['tenant']}}', Filter '{{config['filter']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Filter Name: {{config['filter']}}
    ...  - Filter Entry Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Ether Type: {{config['ether_type']}}
	{% if (config['ether_type'] == "ip") and (config['IP_protocol'] == "tcp") %}
	...  - IP Protocol: {{config['IP_protocol']}}
	...  - Source Port (from): {{config['from_source_port']}}
	...  - Source Port (to): {{config['to_source_port']}}
	...  - Destination Port (from): {{config['from_destination_port']}}
    ...  - Destination Port (to): {{config['to_destination_port']}}
    ...  - TCP Flags: {{config['tcp_flags']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    ...  - Stateful: {{config['stateful']}}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "udp")  %}
	...  - IP Protocol: {{config['IP_protocol']}}
	...  - Source Port (from): {{config['from_source_port']}}
	...  - Source Port (to): {{config['to_source_port']}}
	...  - Destination Port (from): {{config['from_destination_port']}}
    ...  - Destination Port (to): {{config['to_destination_port']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmp")  %}
	...  - IP Protocol: {{config['IP_protocol']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    {% if config['icmp_message'] != "" %}
    ...  - ICMPv4 Type: {{config['icmp_message']}}
    {% endif %}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmpv6")  %}
	...  - IP Protocol: {{config['IP_protocol']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    {% if config['icmpv6_message'] != "" %}
    ...  - ICMPv6 Type: {{config['icmpv6_message']}}
    {% endif %}
    {% elif config['ether_type'] == "ip"  %}
	...  - IP Protocol: {{config['IP_protocol']}}
    {% elif config['ether_type'] == "arp" %}
    ...  - ARP Flag: {{config['arp_flag']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/flt-{{config['filter']}}/e-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter Entry does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.etherT}"  "{{config['ether_type']}}"                    Ether Type not matching expected configuration                 values=False
    {% if (config['ether_type'] == "ip") and (config['IP_protocol'] == "tcp")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sFromPort}"  "{{from_source_port}}"                     Start Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sToPort}"  "{{to_source_port}}"                         End Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dFromPort}"  "{{from_destination_port}}"                Start Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{to_destination_port}}"                    End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.tcpRules}"  "{{config['tcp_flags']}}"                   TCP Flags not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.stateful}"  "{{config['stateful']}}"                    Stateful not matching expected configuration                 values=False
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "udp")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sFromPort}"  "{{from_source_port}}"                     Start Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sToPort}"  "{{to_source_port}}"                         End Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dFromPort}"  "{{from_destination_port}}"                Start Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{to_destination_port}}"                    End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmp")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{config['to_destination_port']}}"          End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    {% if config['icmp_message'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.icmpv4T}"  "{{config['icmp_message']}}"                 ICMPv4 Message Type not matching expected configuration                 values=False
    {% endif %}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmpv6")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{config['to_destination_port']}}"          End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    {% if config['icmpv6_message'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.icmpv6T}"  "{{config['icmpv6_message']}}"               ICMPv6 Message Type not matching expected configuration                 values=False
    {% endif %}
    {% elif config['ether_type'] == "ip"  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    {% elif config['ether_type'] == "arp" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.arpOpc}"  "{{config['arp_flag']}}"                     ARP Flags not matching expected configuration                 values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'IP_protocol': {'default': 'unspecified',
                 'descr': 'IP Protocol',
                 'length': [1, 64],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'arp_flag': {'default': 'unspecified',
              'descr': 'ARP flags',
              'enum': ['reply', 'request', 'unspecified'],
              'mandatory': False,
              'source': 'workbook'},
 'description': {'default': 'None',
                 'descr': 'Filter Description field',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'ether_type': {'default': 'unspecified',
                'descr': 'Ether Type',
                'length': [1, 64],
                'mandatory': True,
                'regex': {'exact_match': False,
                          'pattern': '[a-zA-Z0-9_.:-]+'},
                'source': 'workbook',
                'type': 'str'},
 'filter': {'default': 'None',
            'descr': 'Filter Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'from_destination_port': {'default': 'unspecified',
                           'descr': 'Start destination port block',
                           'length': [1, 64],
                           'mandatory': False,
                           'regex': {'exact_match': False,
                                     'pattern': '[a-zA-Z0-9_.:-]+'},
                           'source': 'workbook',
                           'type': 'str'},
 'from_source_port': {'default': 'unspecified',
                      'descr': 'Start source port block',
                      'length': [1, 64],
                      'mandatory': False,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'workbook',
                      'type': 'str'},
 'icmp_message': {'default': 'unspecified',
                  'descr': 'ICMPv4 message type Flags',
                  'length': [1, 64],
                  'mandatory': False,
                  'regex': {'exact_match': False,
                            'pattern': '[a-zA-Z0-9_.:-]+'},
                  'source': 'workbook',
                  'type': 'str'},
 'icmpv6_message': {'default': 'unspecified',
                    'descr': 'ICMPv6 message type Flags',
                    'length': [1, 64],
                    'mandatory': False,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'workbook',
                    'type': 'str'},
 'match_only_fragments': {'default': 'no',
                          'descr': 'Match only fragments control knob',
                          'enum': ['yes', 'no'],
                          'mandatory': False,
                          'source': 'workbook'},
 'name': {'default': 'None',
          'descr': 'Filter Entry Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'Filter Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'stateful': {'default': 'no',
              'descr': 'Stateful control knob',
              'enum': ['yes', 'no'],
              'mandatory': False,
              'source': 'workbook'},
 'tcp_flags': {'default': '',
               'descr': 'TCP Flags',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'tenant': {'descr': 'Tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'to_destination_port': {'default': 'unspecified',
                         'descr': 'End destination port block',
                         'length': [1, 64],
                         'mandatory': False,
                         'regex': {'exact_match': False,
                                   'pattern': '[a-zA-Z0-9_.:-]+'},
                         'source': 'workbook',
                         'type': 'str'},
 'to_source_port': {'default': 'unspecified',
                    'descr': 'End source port block',
                    'length': [1, 64],
                    'mandatory': False,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'workbook',
                    'type': 'str'}}
```
## vzFilter.robot
### Template Description:
Verifies Contract Filter configuration

> The configuration of filter entries are not verified in this test case template.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | Tenant name | True |   | DAFE Excel Sheet
name | Filter Name | True |   | DAFE Excel Sheet
nameAlias | Filter Name Alias | False | None | DAFE Excel Sheet
description | Filter Description field | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
Verify ACI Contract Filter Configuration - Tenant {{config['tenant']}}, Filter {{config['name']}}
    [Documentation]   Verifies that ACI Contract Filter '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/flt-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                 values=False
    {% endif %}


```
### Template Data Validation Model:
```json
{'description': {'descr': 'Filter Description field',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'name': {'descr': 'Filter Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'nameAlias': {'default': 'None',
               'descr': 'Filter Name Alias',
               'length': [1, 64],
               'mandatory': False,
               'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
               'source': 'workbook',
               'type': 'str'},
 'tenant': {'descr': 'Tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## vzSubj.robot
### Template Description:
Verifies Contract Subject configuration

If not specified:
* Target DSCP assumed to be configured as unspecified
* QoS Priority assumed to be configured as unspecified
* Apply Both Directions to be enabled
* Reverse Filer Ports to be enabled

> The Tenant and Contract must pre-exist.
> Action, Priority, and Directives of associated Contract Filters are not verified by this template

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
reverse_filter_port |  | False | yes | DAFE Excel Sheet
apply_both_direction |  | False | yes | DAFE Excel Sheet
name | Subject name | True |   | DAFE Excel Sheet
name_alias | Subject name Alias | False |   | DAFE Excel Sheet
contract | Parent Contract Name | True |   | DAFE Excel Sheet
filter | Associated Filter | False |   | DAFE Excel Sheet
qos_class | Subject Qos Class | False | unspecified | DAFE Excel Sheet
target_dscp | Subjet Target DSCP | False | unspecified | DAFE Excel Sheet
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet
description | Subject Description Field | False |   | DAFE Excel Sheet


### Template Body:
```
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['level1', 'level2', 'level3', 'unspecified'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
{% if 'apply_both_direction' not in config %}
  {% set x=config.__setitem__('apply_both_direction', 'yes') %}
{% elif config['apply_both_direction'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('apply_both_direction', 'yes') %}
{% endif %}
{% if 'reverse_filter_port' not in config %}
  {% set x=config.__setitem__('reverse_filter_port', 'yes') %}
{% elif config['reverse_filter_port'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('reverse_filter_port', 'yes') %}
{% endif %}
{% if 'target_dscp' not in config %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% elif config['target_dscp'] not in ['unspecified', 'CS0', 'CS1', 'AF11', 'AF12', 'AF13', 'CS2', 'AF21', 'AF22', 'AF23', 'CS3', 'AF31', 'AF32', 'AF33', 'CS4', 'AF41', 'AF42', 'AF43', 'VA', 'CS5', 'EF', 'CS6', 'CS7'] %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
{% if config['filter'] != "" %}
Verify ACI Contract Subject Configuration Tenant {{config['tenant']}}, Contract {{config['contract']}}, Subject {{config['name']}}, Filter {{config['filter']}}
{% else %}
Verify ACI Contract Subject Configuration Tenant {{config['tenant']}}, Contract {{config['contract']}}, Subject {{config['name']}}
{% endif %}
    [Documentation]   Verifies that ACI Contract Subject '{{config['name']}}' under tenant '{{config['tenant']}}', contract '{{config['contract']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Contract Name: {{config['contract']}}
    ...  - Subject Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    ...  - Priority / QoS Class: {{config['qos_class']}}
    ...  - Apply Both Directions: {{config['apply_both_direction']}}
    ...  - Reverse Filter Ports: {{config['reverse_filter_port']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    {% if config['filter'] != "" %}
    ...  - Associated Filter: {{config['filter']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['contract']}}/subj-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract Subject does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                values=False
    {% endif %}
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.prio}"  "{{config['qos_class']}}"                       Priority / QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.revFltPorts}"  "{{config['reverse_filter_port']}}"      Reverse Filter Ports not matching expected configuration                 values=False
    # Verify associated filter
    {% if config['filter'] != "" and config['apply_both_direction'] == "yes" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['contract']}}/subj-{{config['name']}}/rssubjFiltAtt-{{config['filter']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Filter not associated with Contract Subject		values=False
    {% else %}
    log  Configuration of Filter Association for Tenant '{{config['tenant']}}', Contract '{{config['contract']}}', Subject '{{config['name']}}' not verfied as config verfication of filter association are only supported for filters applied in both directions by the test case           WARN
    {% endif %}


```
### Template Data Validation Model:
```json
{'apply_both_direction': {'default': 'yes',
                          'descr': '',
                          'enum': ['yes', 'no'],
                          'mandatory': False,
                          'source': 'workbook'},
 'contract': {'descr': 'Parent Contract Name',
              'length': [1, 64],
              'mandatory': True,
              'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
              'source': 'workbook',
              'type': 'str'},
 'description': {'descr': 'Subject Description Field',
                 'length': [0, 128],
                 'mandatory': False,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'filter': {'descr': 'Associated Filter',
            'length': [0, 128],
            'mandatory': False,
            'regex': {'exact_match': False,
                      'pattern': '[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]+'},
            'source': 'workbook',
            'type': 'str'},
 'name': {'descr': 'Subject name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'name_alias': {'descr': 'Subject name Alias',
                'mandatory': False,
                'source': 'workbook'},
 'qos_class': {'default': 'unspecified',
               'descr': 'Subject Qos Class',
               'enum': ['level1', 'level2', 'level3', 'unspecified'],
               'mandatory': False,
               'source': 'workbook'},
 'reverse_filter_port': {'default': 'yes',
                         'descr': '',
                         'enum': ['yes', 'no'],
                         'mandatory': False,
                         'source': 'workbook'},
 'target_dscp': {'default': 'unspecified',
                 'descr': 'Subjet Target DSCP',
                 'enum': ['unspecified',
                          'CS0',
                          'CS1',
                          'AF11',
                          'AF12',
                          'AF13',
                          'CS2',
                          'AF21',
                          'AF22',
                          'AF23',
                          'CS3',
                          'AF31',
                          'AF32',
                          'AF33',
                          'CS4',
                          'AF41',
                          'AF42',
                          'AF43',
                          'VA',
                          'CS5',
                          'EF',
                          'CS6',
                          'CS7'],
                 'mandatory': False,
                 'source': 'workbook'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
