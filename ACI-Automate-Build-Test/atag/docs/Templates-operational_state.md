# Overview
These tests focuses on verification of operational state within the fabric. Examples of this could be software version, state of BGP peers, etc.
## bgpInstP.robot
### Template Description:
Verifies the Fabric BGP peer state on the Route Reflector nodes


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
bgp_rr_node_id | BGP Route Reflector Node id | True | None | DAFE Excel Sheet
pod_id | BGP Route Reflector POD id | True | None | DAFE Excel Sheet


### Template Body:
```
Verify ACI Fabric BGP Peer State - Route Reflector Node '{{config['bgp_rr_node_id']}}'
    [Documentation]   Verifies that Fabric BGP peer state for Route Reflector Node '{{config['bgp_rr_node_id']}}'
    ...  - BGP Route Reflector POD ID: {{config['pod_id']}}
    ...  - BGP Route Reflector Node: {{config['bgp_rr_node_id']}}
    [Tags]      aci-operations  aci-fabric  aci-fabric-bgp
    # Retrieve TEP Pool of POD
    ${uri} =  Set Variable  /api/mo/uni/controller/setuppol/setupp-{{config['pod_id']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call (TEP Pool)		values=False
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retrieving TEP Pool Configuration		values=False
    ${tepPool} =  Set Variable  ${return.payload[0].fabricSetupP.attributes.tepPool}
    # Retrieve list of leaf switches and their associated TEP address
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "leaf")
    ${leafList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${leafList.status}        200		Failure executing API call (Leaf List)		values=False
    run keyword if  "${leafList.totalCount}" == "0"  run keyword
    ...  RUN  Fail  No Leaf switches registered within the Fabric
    : FOR  ${leaf}  IN  @{leafList.payload}
       # Check if leaf is part of the local pod
    \  ${podMember} =  Run Keyword And Return Status    Should Contain  ${leaf.fabricNode.attributes.dn}  pod-1
    \  Continue For Loop If  ${podMember} == False
       # Check BGP Peer state towards leafs in local POD
    \  ${uri} =  Set Variable  /api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['bgp_rr_node_id']}}/sys/bgp/inst/dom-overlay-1/peer-[${tepPool}]/ent-[${leaf.fabricNode.attributes.address}]
    \  ${bgpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${bgpState.status}        200		Failure executing API call (BGP Peer State)		values=False
    \  Should Be Equal as Integers     ${bgpState.totalCount}    1		    Failure retrieving BGP Peer State		values=False
    \  run keyword And Continue on Failure  Should Be Equal as Strings      "${bgpState.payload[0].bgpPeerEntry.attributes.operSt}"     "established"       Fabric BGP session towards node '${leaf.fabricNode.attributes.dn}' is down      values=False


```
### Template Data Validation Model:
```json
{'bgp_rr_node_id': {'default': 'None',
                    'descr': 'BGP Route Reflector Node id',
                    'mandatory': True,
                    'range': [101, 4000],
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
Verifies L3 Node Level BGP Peer session status.

This test template verifies that the BGP peer are defined on the defined leaf switches,

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
l3out | Parent L3 Out Name | True |   | DAFE Excel Sheet
bgp_peer_ip | BGP Peer IP Address | True |   | DAFE Excel Sheet
l3out_node_profile | L3Out Node Profile Name | True |   | DAFE Excel Sheet
tenant | Parent tenant name | True |   | DAFE Excel Sheet


### Template Body:
```
Verify ACI L3out BGP peer state - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, BGP Peer {{config['bgp_peer_ip']}}
    [Documentation]   Verifies that BGP peer state for BGP peer '{{config['bgp_peer_ip']}}' defined under Tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}' 
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - BGP Peer: {{config['bgp_peer_ip']}}
    [Tags]      aci-operations  aci-tenant  aci-tenant-l3out  aci-tenant-l3out-bgp
    # Retrieve VRF associated with L3Out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}
    ${filter} =  Set Variable  rsp-subtree=children&rsp-subtree-class=l3extRsEctx
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retrieving L3Out VRF association		values=False
    ${vrf} =  Set Variable  ${return.payload[0].l3extOut.children[0].l3extRsEctx.attributes.tnFvCtxName}
    # Retrieve Fabric Nodes associated with Node Profile
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}
    ${filter} =  Set Variable  rsp-subtree=children&rsp-subtree-class=l3extRsNodeL3OutAtt
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    run keyword if  "${return.totalCount}" == "0"  run keyword
    ...  RUN  Fail  No fabric nodes associated with L3Out Node Profile
    # Check BGP peer status on each logical node
    : FOR  ${node}  IN  @{return.payload[0].l3extLNodeP.children}
    \  log  ${node.l3extRsNodeL3OutAtt.attributes.tDn}
    \  @{fabric_node} =  Split String  ${node.l3extRsNodeL3OutAtt.attributes.tDn}  /
	\  ${uri} =  Set Variable  /api/node/mo/topology/${fabric_node[1]}/${fabric_node[2]}/sys/bgp/inst/dom-{{config['tenant']}}:${vrf}/peer-[{{config['bgp_peer_ip']}}/32]/ent-[{{config['bgp_peer_ip']}}]
    \  ${return_peer_status}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_peer_status.status}        200		Failure executing API call		values=False
	\  run keyword And Continue on Failure  Should Be Equal as Integers     ${return_peer_status.totalCount}    1		BGP peer not found on ${fabric_node[2]}		values=False
    # add check and only execute test if peer is avialable
    \  run keyword if  "${return_peer_status.totalCount}" == "1"  run keyword
    \  ...  run keyword And Continue on Failure  Should Be Equal as Strings      ${return_peer_status.payload[0].bgpPeerEntry.attributes.operSt}    established		BGP session not established	on ${fabric_node[2]}	values=False


```
### Template Data Validation Model:
```json
{'bgp_peer_ip': {'descr': 'BGP Peer IP Address',
                 'mandatory': True,
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
 'tenant': {'descr': 'Parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## connectivity_apic.robot
### Template Description:
Checks fabric connectivity between leaf and APIC.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
connection_type | Connection type | True |   | wordbook
from_leaf_node | Hostname of leaf switch (from device) | True | None | wordbook
from_port | Port ID on leaf switch in the format of <slot>/<inteface number> | True | None | wordbook
to_port | Port ID on APIC in the format of <slot>/<inteface number> | True | None | wordbook
to_node | Hostname of APIC (to device) | True | None | wordbook
pod_id | Fabric POD ID which leaf switch belongs to. Value are looked'ed up in node_provisioning sheet | True |   | wordbook


### Template Body:
```
{% if con.connection_type == 'apic' %}
{% set from_leaf_node_id = dafe_data.node_provisioning.row(name=con.from_leaf_node).node_id %}
{% set to_node_id = dafe_data.apic_controller.row(apic_hostname=con.to_node).apic_id %}
{% set pod_id = dafe_data.node_provisioning.row(name=con.from_leaf_node).pod_id %}
{% set from_port_component = con.from_port.split('/') %}
{% set to_port_component = con.to_port.split('/') %}
Verify ACI APIC Connectivity - Node {{from_leaf_node_id}} (eth{{con.from_port}}) to APIC {{to_node_id}} (eth{{con.to_port}})
    [Documentation]   Verifies that ACI APIC Connectivity from node {{from_leaf_node_id}} (eth{{con.from_port}}) to APIC {{to_node_id}} (eth{{con.to_port}}) are connected and operates as expected
    ...  - From POD ID: {{pod_id}}
    ...  - From Node: {{con.from_leaf_node}}
    ...  - From Node ID: {{from_leaf_node_id}}
    ...  - From Port: eth{{con.from_port}}
    ...  - To Node: {{con.to_node}}
    ...  - To Node ID: {{to_node_id}}
    ...  - To Port: {{con.to_port}}
    [Tags]      aci-operations  aci-fabric-connectivity
    # LLDP
    ${uri} =  Set Variable  /api/node/mo/topology/pod-{{pod_id}}/node-{{from_leaf_node_id}}/sys/lldp/inst/if-[eth{{con.from_port}}]
    ${filter} =  Set Variable  query-target=children&target-subtree-class=lldpAdjEp&query-target=subtree
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		No LLDP neighbor found		values=False
	run keyword if  "${return.totalCount}" == "1"  run keywords
    ...  Run keyword And Continue on Failure       Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.sysDesc}      topology/pod-{{pod_id}}/node-{{to_node_id}}              LLDP neighbor not matching expected system name (sysDesc)   values=False
    ...  AND  Run keyword And Continue on Failure   Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.portDesc}    eth{{to_port_component[0]}}-{{to_port_component[1]}}     LLDP neighbor not matching expected port (portDesc)         values=False
    # Link Mode (Fabric)
    ${uri} =  Set Variable  /api/node/mo/topology/pod-{{pod_id}}/lnkcnt-{{to_node_id}}/lnk-{{from_leaf_node_id}}-{{from_port_component[0]}}-{{from_port_component[1]}}-to-{{to_node_id}}-{{to_port_component[0]}}-{{to_port_component[1]}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		Port usage is not "Fabric" as expected		values=False

{% endif %}
{% endfor %}
```
### Template Data Validation Model:
```json
{'connection_type': {'descr': 'Connection type',
                     'enum': ['fabric',
                              'apic',
                              'host',
                              'oob',
                              'console',
                              'spinehost'],
                     'mandatory': True,
                     'source': 'wordbook'},
 'from_leaf_node': {'default': 'None',
                    'descr': 'Hostname of leaf switch (from device)',
                    'length': [1, 64],
                    'mandatory': True,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'wordbook',
                    'type': 'str'},
 'from_port': {'default': 'None',
               'descr': 'Port ID on leaf switch in the format of <slot>/<inteface number>',
               'length': [3, 10],
               'mandatory': True,
               'source': 'wordbook',
               'type': 'str'},
 'pod_id': {'descr': "Fabric POD ID which leaf switch belongs to. Value are looked'ed up in node_provisioning sheet",
            'mandatory': True,
            'range': [1, 10],
            'source': 'wordbook',
            'type': 'int'},
 'to_node': {'default': 'None',
             'descr': 'Hostname of APIC (to device)',
             'length': [1, 64],
             'mandatory': True,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'wordbook',
             'type': 'str'},
 'to_port': {'default': 'None',
             'descr': 'Port ID on APIC in the format of <slot>/<inteface number>',
             'length': [3, 10],
             'mandatory': True,
             'source': 'wordbook',
             'type': 'str'}}
```
## connectivity_fabric.robot
### Template Description:
Checks fabric connectivity between leaf and spine.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
connection_type | Connection type | True |   | wordbook
from_leaf_node | Hostname of leaf switch (from device) | True | None | wordbook
from_port | Port ID on leaf switch in the format of <slot>/<inteface number> | True | None | wordbook
to_port | Port ID on spine switch in the format of <slot>/<inteface number> | True | None | wordbook
to_node | Hostname of spine switch (to device) | True | None | wordbook
pod_id | Fabric POD ID which leaf switch belongs to. Value are looked'ed up in node_provisioning sheet | True |   | wordbook


### Template Body:
```
{%- for con in dafe_data.cabling_matrix -%}
{% if con.connection_type == 'fabric' %}
{% set from_leaf_node_id = dafe_data.node_provisioning.row(name=con.from_leaf_node).node_id %}
{% set to_node_id = dafe_data.node_provisioning.row(name=con.to_node).node_id %}
{% set pod_id = dafe_data.node_provisioning.row(name=con.from_leaf_node).pod_id %}
{% set from_port_component = con.from_port.split('/') %}
{% set to_port_component = con.to_port.split('/') %}
Verify ACI Fabric Connectivity - Node {{from_leaf_node_id}} (eth{{con.from_port}}) to Node {{to_node_id}} (eth{{con.to_port}})
    [Documentation]   Verifies that ACI Fabric Connectivity from node {{from_leaf_node_id}} (eth{{con.from_port}}) to node {{to_node_id}} (eth{{con.to_port}}) are connected and operates as expected
    ...  - From POD ID: {{pod_id}}
    ...  - From Node: {{con.from_leaf_node}}
    ...  - From Node ID: {{from_leaf_node_id}}
    ...  - From Port: eth{{con.from_port}}
    ...  - To Node: {{con.to_node}}
    ...  - To Node ID: {{to_node_id}}
    ...  - To Port: eth{{con.to_port}}
    [Tags]      aci-operations  aci-fabric-connectivity
    # LLDP
    ${uri} =  Set Variable  /api/node/mo/topology/pod-{{pod_id}}/node-{{from_leaf_node_id}}/sys/lldp/inst/if-[eth{{con.from_port}}]
    ${filter} =  Set Variable  query-target=children&target-subtree-class=lldpAdjEp&query-target=subtree
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		No LLDP neighbor found		values=False
	run keyword if  "${return.totalCount}" == "1"  run keywords
    ...  Run keyword And Continue on Failure       Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.sysDesc}      topology/pod-{{pod_id}}/node-{{to_node_id}}                                   LLDP neighbor not matching expected system name (sysDesc)   values=False
    ...  AND  Run keyword And Continue on Failure   Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.portDesc}     topology/pod-{{pod_id}}/paths-{{to_node_id}}/pathep-[eth{{con.to_port}}]     LLDP neighbor not matching expected port (portDesc)         values=False
    # Link Mode (Fabric)
    ${uri} =  Set Variable  /api/node/mo/topology/pod-{{pod_id}}/lnkcnt-{{to_node_id}}/lnk-{{from_leaf_node_id}}-{{from_port_component[0]}}-{{from_port_component[1]}}-to-{{to_node_id}}-{{to_port_component[0]}}-{{to_port_component[1]}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		Port usage is not "Fabric" as expected		values=False

{% endif %}
{% endfor %}
```
### Template Data Validation Model:
```json
{'connection_type': {'descr': 'Connection type',
                     'enum': ['fabric',
                              'apic',
                              'host',
                              'oob',
                              'console',
                              'spinehost'],
                     'mandatory': True,
                     'source': 'wordbook'},
 'from_leaf_node': {'default': 'None',
                    'descr': 'Hostname of leaf switch (from device)',
                    'length': [1, 64],
                    'mandatory': True,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'wordbook',
                    'type': 'str'},
 'from_port': {'default': 'None',
               'descr': 'Port ID on leaf switch in the format of <slot>/<inteface number>',
               'length': [3, 10],
               'mandatory': True,
               'source': 'wordbook',
               'type': 'str'},
 'pod_id': {'descr': "Fabric POD ID which leaf switch belongs to. Value are looked'ed up in node_provisioning sheet",
            'mandatory': True,
            'range': [1, 10],
            'source': 'wordbook',
            'type': 'int'},
 'to_node': {'default': 'None',
             'descr': 'Hostname of spine switch (to device)',
             'length': [1, 64],
             'mandatory': True,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'wordbook',
             'type': 'str'},
 'to_port': {'default': 'None',
             'descr': 'Port ID on spine switch in the format of <slot>/<inteface number>',
             'length': [3, 10],
             'mandatory': True,
             'source': 'wordbook',
             'type': 'str'}}
```
## connectivity_host.robot
### Template Description:
Checks fabric connectivity between leaf and endpoints (servers, Firewall's, Load Balancer's, etc.).

> This test case template relies on LLDP or CDP to verify connectivity.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
connection_type | Connection type | True |   | wordbook
from_leaf_node | Hostname of leaf switch (from device) | True | None | wordbook
from_port | Port ID on leaf switch in the format of <slot>/<inteface number> | True | None | wordbook
to_port | Port name/ID on connected device | True | None | wordbook
to_node | Hostname of conneced device (to device) | True | None | wordbook
pod_id | Fabric POD ID which leaf switch belongs to. Value are looked'ed up in node_provisioning sheet | True |   | wordbook


### Template Body:
```
{%- for con in dafe_data.cabling_matrix -%}
{% if con.connection_type == 'host' %}
{% set from_leaf_node_id = dafe_data.node_provisioning.row(name=con.from_leaf_node).node_id %}
{% set pod_id = dafe_data.node_provisioning.row(name=con.from_leaf_node).pod_id %}
{% set from_port_component = con.from_port.split('/') %}
Verify ACI Host Connectivity - Node {{from_leaf_node_id}} (eth{{con.from_port}}) to Host {{con.to_node}} ({{con.to_port}})
    [Documentation]   Verifies that ACI Fabric Connectivity from node {{from_leaf_node_id}} (eth{{con.from_port}}) to host {{con.to_node}} ({{con.to_port}}) are connected and operates as expected
    ...  - From POD ID: {{pod_id}}
    ...  - From Node: {{con.from_leaf_node}}
    ...  - From Node ID: {{from_leaf_node_id}}
    ...  - From Port: eth{{con.from_port}}
    ...  - To Host: {{con.to_node}}
    ...  - To Port: {{con.to_port}}
    [Tags]      aci-operations  aci-fabric-connectivity
    ## Retreive LLDP and CDP neighbors
    # LLDP
    ${uri} =  Set Variable  /api/node/mo/topology/pod-{{pod_id}}/node-{{from_leaf_node_id}}/sys/lldp/inst/if-[eth{{con.from_port}}]
    ${filter} =  Set Variable  query-target=children&target-subtree-class=lldpAdjEp&query-target=subtree
	${lldp_return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${lldp_return.status}        200		Failure executing API call		values=False
    # CDP
    ${uri} =  Set Variable  /api/node/mo/topology/pod-{{pod_id}}/node-{{from_leaf_node_id}}/sys/cdp/inst/if-[eth{{con.from_port}}]
    ${filter} =  Set Variable  query-target=children&target-subtree-class=cdpAdjEp&query-target=subtree
	${cdp_return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${cdp_return.status}        200		Failure executing API call		values=False
    ## Verify LLDP and CDP neighbors
    run keyword if  "${lldp_return.totalCount}" == "0" and "${cdp_return.totalCount}" == "0"  run keyword
    ...  fail  No LLDP or CDP neighbors on port, check configuration on both leaf and endpoint
    run keyword if  "${lldp_return.totalCount}" == "1" and "${cdp_return.totalCount}" == "0"   run keywords
    ...  Run keyword And Continue on Failure  Should Contain  ${lldp_return.payload[0].lldpAdjEp.attributes.sysDesc}  {{con.to_node}}           LLDP neighbor does not have expected host name                  values=false
    ...  AND  Run keyword And Continue on Failure  Should Contain  ${lldp_return.payload[0].lldpAdjEp.attributes.portDesc}  {{con.to_port}}     LLDP neighbor are not connected using expected port (name/ID mismatch)      values=false
    run keyword if  "${cdp_return.totalCount}" == "1" and "${lldp_return.totalCount}" == "0"  run keywords
    ...  Run keyword And Continue on Failure  Should Contain  ${cdp_return.payload[0].cdpAdjEp.attributes.sysName}  {{con.to_node}}             CDP neighbor does not have expected host name                   values=false
    ...  AND  Run keyword And Continue on Failure  Should Contain  ${cdp_return.payload[0].cdpAdjEp.attributes.portId}  {{con.to_port}}         CDP neighbor are not connected using expected port (name/ID mismatch)       values=false
    run keyword if  "${lldp_return.totalCount}" == "1" and "${cdp_return.totalCount}" == "1"  run keyword
    ...  Run keyword And Continue on Failure  Should Contain  ${lldp_return.payload[0].lldpAdjEp.attributes.sysDesc}  {{con.to_node}}           LLDP neighbor does not have expected host name                  values=false
    ...  AND  Run keyword And Continue on Failure  Should Contain  ${lldp_return.payload[0].lldpAdjEp.attributes.portDesc}  {{con.to_port}}     LLDP neighbor are not connected using expected port (name/ID mismatch)      values=false
    ...  AND  Run keyword And Continue on Failure  Should Contain  ${cdp_return.payload[0].cdpAdjEp.attributes.sysName}  {{con.to_node}}        CDP neighbor does not have expected host name                   values=false
    ...  AND  Run keyword And Continue on Failure  Should Contain  ${cdp_return.payload[0].cdpAdjEp.attributes.portId}  {{con.to_port}}         CDP neighbor are not connected using expected port (name/ID mismatch)       values=false
{% endif %}
{% endfor %}
```
### Template Data Validation Model:
```json
{'connection_type': {'descr': 'Connection type',
                     'enum': ['fabric',
                              'apic',
                              'host',
                              'oob',
                              'console',
                              'spinehost'],
                     'mandatory': True,
                     'source': 'wordbook'},
 'from_leaf_node': {'default': 'None',
                    'descr': 'Hostname of leaf switch (from device)',
                    'length': [1, 64],
                    'mandatory': True,
                    'regex': {'exact_match': False,
                              'pattern': '[a-zA-Z0-9_.:-]+'},
                    'source': 'wordbook',
                    'type': 'str'},
 'from_port': {'default': 'None',
               'descr': 'Port ID on leaf switch in the format of <slot>/<inteface number>',
               'length': [3, 10],
               'mandatory': True,
               'source': 'wordbook',
               'type': 'str'},
 'pod_id': {'descr': "Fabric POD ID which leaf switch belongs to. Value are looked'ed up in node_provisioning sheet",
            'mandatory': True,
            'range': [1, 10],
            'source': 'wordbook',
            'type': 'int'},
 'to_node': {'default': 'None',
             'descr': 'Hostname of conneced device (to device)',
             'length': [1, 64],
             'mandatory': True,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'wordbook',
             'type': 'str'},
 'to_port': {'default': 'None',
             'descr': 'Port name/ID on connected device',
             'length': [1, 64],
             'mandatory': True,
             'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
             'source': 'wordbook',
             'type': 'str'}}
```
## datetime_ntp_status.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
### Template Body:
```
Checking ACI Datetime / Clock Synchronization Status'
    [Documentation]   Verifies ACI Datetime / Clock Synchronization Status
    [Tags]      aci-operations  aci-fabric  aci-fabric-ntp
    # APIC Fabric Nodes
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "controller")
    ${nodeList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${nodeList.status}        200		Failure executing API call		values=False
    run keyword if  "${nodeList.totalCount}" == "0"
    ...  Fail  No Controller Nodes registered within the Fabric
    # Iterate through the controller nodes
    : FOR  ${node}  IN  @{nodeList.payload}
    \  ${uri} =  Set Variable  /api/node/mo/${node.fabricNode.attributes.dn}/sys.json?query-target=subtree&target-subtree-class=datetimeNtpq
    \  ${ntpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${ntpState.status}        200		Failure executing API call (APIC)		values=False
    \  run keyword unless  ${ntpState.totalCount} > 0  run Keywords
    \  ...  Run Keyword And Continue On Failure  Fail  Clock not synchronized on node '${node.fabricNode.attributes.dn}' (no NTP peers defined)
    \  ...  AND  Continue For Loop
    \  @{ntp_status} =  Check ACI Controller NTP Status  ${ntpState.payload}
    \  ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntp_status[0]}  "synced_remote_server"
    \  run keyword unless  ${ntp_sync_status}  run keywords
    \  ...  Run Keyword And Continue On Failure  Fail  Clock not synchonized on node '${node.fabricNode.attributes.dn}' 
    \  ...  AND  log  Node '${node.fabricNode.attributes.dn}', NTP Stratum: ${ntp_status[2]}, NTP peers: ${ntp_status[3]}
    \  run keyword if  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Server: ${ntp_status[1]}, NTP Stratum: ${ntp_status[2]}, NTP peers: ${ntp_status[3]}
    # Leaf Fabric nodes
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "leaf")
    ${nodeList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${nodeList.status}        200		Failure executing API call		values=False
    run keyword if  "${nodeList.totalCount}" == "0"
    ...  Fail  No Leaf Nodes registered within the Fabric
    # Iterate through the leaf nodes
    : FOR  ${node}  IN  @{nodeList.payload}
    \  ${uri} =  Set Variable  /api/node/mo/${node.fabricNode.attributes.dn}/sys/time.json?rsp-subtree=children
    \  ${ntpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${ntpState.status}        200		Failure executing API call (Leaf)		values=False
    \  ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}  "synced_remote_server"
    \  ${ntp_peers} =  Get ACI Switch NTP peers  ${ntpState.payload[0].datetimeClkPol.children}
    \  run keyword And Continue on Failure  Should Be Equal as Strings   ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}   "synced_remote_server"    Clock not synchronized on node '${node.fabricNode.attributes.dn}'       values=False
    \  run keyword unless  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers} 
    \  run keyword if  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Server: ${ntpState.payload[0].datetimeClkPol.attributes.refId}, NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers}
    # Spine Fabric nodes
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "spine")
    ${nodeList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${nodeList.status}        200		Failure executing API call		values=False
    run keyword if  "${nodeList.totalCount}" == "0"
    ...  Fail  No Leaf Nodes registered within the Fabric
    # Iterate through the spine nodes
    : FOR  ${node}  IN  @{nodeList.payload}
    \  ${uri} =  Set Variable  /api/node/mo/${node.fabricNode.attributes.dn}/sys/time.json?rsp-subtree=children
    \  ${ntpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${ntpState.status}        200		Failure executing API call (Leaf)		values=False
    \  ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}  "synced_remote_server"
    \  ${ntp_peers} =  Get ACI Switch NTP peers  ${ntpState.payload[0].datetimeClkPol.children}
    \  run keyword And Continue on Failure  Should Be Equal as Strings   ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}   "synced_remote_server"    Clock not synchronized on node '${node.fabricNode.attributes.dn}'       values=False
    \  run keyword unless  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers} 
    \  run keyword if  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Server: ${ntpState.payload[0].datetimeClkPol.attributes.refId}, NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers}


```
### Template Data Validation Model:
No Validation model defined
## hardware_state_cimc.robot
### Template Description:
Checks APIC hardware status LEDs

The following status LEDs are verified:
- PSU
- Temperature
- FAN
- Overall Health
- DIMM (memory)

> Verfification are done through the CIMC (SSH connection).

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
apic_hostname | APIC Hostname | True | None | wordbook
apic_id | APIC Node ID | True |   | wordbook
cimc_ip | CIMC IP Address in the form of IP/Mask | True | None | DAFE Excel Sheet


### Template Body:
```
{% set cimc_ip = config['cimc_ip'].split('/') %}
Verify APIC Hardware State - APIC {{config['apic_id']}}
    [Documentation]  Verifies the APIC hardware health through the CIMC interface.
    ...  APIC Node ID: {{config['apic_id']}}
    ...  APIC Hostname: {{config['apic_hostname']}}
    ...  CIMC IP: {{ cimc_ip[0] }}
    [Tags]      aci-operations  aci-operations-hardware
    # Login
    connect to device "{{config['apic_hostname']}}_cimc" via "cli"
    # Get Env LED status
    execute command "scope chassis" on device "{{config['apic_hostname']}}_cimc"
    ${output}=  execute command "show led" on device "{{config['apic_hostname']}}_cimc"
    # Analyse output
    @{table_headers} =  Create List    LED Name   LED State   LED Color
    ${result}=  parse table output "${output}" using headers "${table_headers}" and delimiter ""
    #@{status}=   Get Value From Json   ${result}   $[?(@.'LED Name'=='LED_PSU_STATUS')]['LED State','LED Color']
    ${psu_led_status}=     Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_PSU_STATUS"
    ${psu_led_color}=      Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_PSU_STATUS"
    ${temp_led_status}=    Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_TEMP_STATUS"
    ${temp_led_color}=     Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_TEMP_STATUS"
    ${fan_led_status}=     Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_FAN_STATUS"
    ${fan_led_color}=      Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_FAN_STATUS"
    ${hlth_led_status}=    Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_HLTH_STATUS"
    ${hlth_led_color}=     Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_HLTH_STATUS"
    ${dimm_led_status}=    Get Value From JSON "${result}" for key "LED State" where "LED Name" is "OVERALL_DIMM_STATUS"
    ${dimm_led_color}=     Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "OVERALL_DIMM_STATUS"
    Run keyword And Continue on Failure     Should be Equal     ${psu_led_status}   ON      PSU LED not turned on       values=False
    Run keyword And Continue on Failure     Should be Equal     ${psu_led_color}    GREEN   PSU LED not green           values=False
    Run keyword And Continue on Failure     Should be Equal     ${temp_led_status}  ON      TEMP LED not turned on      values=False
    Run keyword And Continue on Failure     Should be Equal     ${temp_led_color}   GREEN   TEMP LED not green          values=False
    Run keyword And Continue on Failure     Should be Equal     ${fan_led_status}   ON      FAN LED not turned on       values=False
    Run keyword And Continue on Failure     Should be Equal     ${fan_led_color}    GREEN   FAN LED not green           values=False
    Run keyword And Continue on Failure     Should be Equal     ${hlth_led_status}  ON      Health LED not turned on    values=False
    Run keyword And Continue on Failure     Should be Equal     ${hlth_led_color}   GREEN   Health LED not green        values=False
    Run keyword And Continue on Failure     Should be Equal     ${dimm_led_status}  ON      DIMM LED not turned on      values=False
    Run keyword And Continue on Failure     Should be Equal     ${dimm_led_color}   GREEN   DIMM LED not green          values=False




```
### Template Data Validation Model:
```json
{'apic_hostname': {'default': 'None',
                   'descr': 'APIC Hostname',
                   'length': [1, 64],
                   'mandatory': True,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'wordbook',
                   'type': 'str'},
 'apic_id': {'descr': 'APIC Node ID',
             'mandatory': True,
             'range': [1, 100],
             'source': 'wordbook',
             'type': 'int'},
 'cimc_ip': {'default': 'None',
             'descr': 'CIMC IP Address in the form of IP/Mask',
             'mandatory': True,
             'source': 'workbook',
             'type': 'str'}}
```
## interface_counters.robot
### Template Description:
Collects interface counters (CRC, input errors and discards, output errors and discards) from all interfaces within the fabric twice.

After collection of counters are the two compared to see if any of them have increased.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
counter_collection_interval | Time interval between counter collection | True |   | ATAG config file


### Template Body:
```
Collect ACI Interface Counters
    [Documentation]  Collect interfaces error counters twice with an interval
    ...  - Interval between counter collection: {{config['counter_collection_interval']}}
    [Tags]      aci-operations  aci-fabric-counters
    # Gather interface list
    ${uri}=     Set Variable  /api/node/class/l1PhysIf
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200          Failure retrieving interface list		values=False
    Should Not Be Equal As Integers    ${return.totalCount}  0      No interfaces found in Fabric           values=False
    Set Suite Variable  ${fabric_interfaces}  ${return.payload}
    # Prepare dictionaries to store interface counters
    ${dn_crc_one}=      Create Dictionary
    ${dn_rxerr_one}=    Create Dictionary
    ${dn_rxdsc_one}=    Create Dictionary
    ${dn_txerr_one}=    Create Dictionary
    ${dn_txdsc_one}=    Create Dictionary
    ${dn_crc_two}=      Create Dictionary
    ${dn_rxerr_two}=    Create Dictionary
    ${dn_rxdsc_two}=    Create Dictionary
    ${dn_txerr_two}=    Create Dictionary
    ${dn_txdsc_two}=    Create Dictionary
    # For each interface pull five error counters and add them to a respective dictionary first time
    :FOR  ${intf}  IN  @{fabric_interfaces}
    \  # Collect and store CRC errors
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgEtherStats
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  run keyword And Continue on Failure  Should Be Equal as Integers     ${return_dn.status}   200       Error retrieving dbgEtherStats object for interface with DN "${dn}" (1st collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving CRC errors for interface with DN "${dn}" (1st collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  ${crc_err} =   Convert to Integer  ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  Set To Dictionary    ${dn_crc_one}  ${dn}  ${crc_err}
    \  # Collect and store ingress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfIn
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfIn object for interface with DN "${dn}" (1st collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving ingress errors and discards for interface with DN "${dn}" (1st collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  Set To Dictionary    ${dn_rxerr_one}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_rxdsc_one}  ${dn}  ${dsc_err}
    \  # Collect and store egress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfOut
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfOut object for interface with DN "${dn}" (1st collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving egress errors and discards for interface with DN "${dn}" (1st collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  Set To Dictionary    ${dn_txerr_one}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_txdsc_one}  ${dn}  ${dsc_err}
    # Wait for some time before collecting the counters again
    Log to console  \nPausing execution for {{config['counter_collection_interval']}} before resume collecting interface counters (2nd time)
    Sleep  {{config['counter_collection_interval']}}
    # Temporarily refresh login on APIC to address BUG in RASTA (https://wwwin-github.cisco.com/AS-Community/RASTA/pull/237)
    ACI REST login on ${apic}
    # For each interface pull five error counters and add them to a respective dictionary second time
    :FOR  ${intf}  IN  @{fabric_interfaces}
    \  # Collect and store CRC errors
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgEtherStats
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  run keyword And Continue on Failure  Should Be Equal as Integers     ${return_dn.status}   200       Error retrieving dbgEtherStats object for interface with DN "${dn}" (2nd collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving CRC errors for interface with DN "${dn}" (2nd collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  ${crc_err} =   Convert to Integer  ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  Set To Dictionary    ${dn_crc_two}  ${dn}  ${crc_err}
    \  # Collect and store ingress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfIn
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfIn object for interface with DN "${dn}" (2nd collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving ingress errors and discards for interface with DN "${dn}" (2nd collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  Set To Dictionary    ${dn_rxerr_two}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_rxdsc_two}  ${dn}  ${dsc_err}
    \  # Collect and store egress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfOut
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfOut object for interface with DN "${dn}" (2nd collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving egress errors and discards for interface with DN "${dn}" (2nd collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  Set To Dictionary    ${dn_txerr_two}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_txdsc_two}  ${dn}  ${dsc_err}
    # Make dictionaries available for the counter comparison tests
    Set Suite Variable  ${dn_crc_one}
    Set Suite Variable  ${dn_rxerr_one}
    Set Suite Variable  ${dn_rxdsc_one}
    Set Suite Variable  ${dn_txerr_one}
    Set Suite Variable  ${dn_txdsc_one}
    Set Suite Variable  ${dn_crc_two}
    Set Suite Variable  ${dn_rxerr_two}
    Set Suite Variable  ${dn_rxdsc_two}
    Set Suite Variable  ${dn_txerr_two}
    Set Suite Variable  ${dn_txdsc_two}
    
Verify ACI Interface Counters (CRC error)
    [Documentation]  Verify that interface CRC error counters are not incrementing on any node/interface
    [Tags]      aci-operations  aci-fabric-counters
    Variable Should Exist  ${dn_crc_one}  Collection of interface CRC counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_crc_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected CRC counter 1st database does not contain any entries                values=False
    Variable Should Exist  ${dn_crc_two}  Collection of interface CRC counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_crc_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected CRC counter 2nd database does not contain any entries                values=False
    # Compare two respective dictionaries for counter increment
    :FOR  ${key}  IN  @{dn_crc_one}
    \  ${crc_one}=    Get From Dictionary    ${dn_crc_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_crc_two}  ${key}
    \  ${crc_two}=    Get From Dictionary    ${dn_crc_two}  ${key}
    \  Run keyword if  ${crc_two} > ${crc_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has CRC errors incrementing

Verify ACI Interface Counters (input error and discard)
    [Documentation]  Verify that interface input error and discard counters are not incrementing on any node/interface
    [Tags]      aci-operations  aci-fabric-counters
    Variable Should Exist  ${dn_rxerr_one}  Collection of interface RX error counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_rxerr_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX error counter 1st database does not contain any entries                   values=False
    Variable Should Exist  ${dn_rxerr_two}  Collection of interface RX error counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_rxerr_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX error counter 2nd database does not contain any entries                   values=False
    Variable Should Exist  ${dn_rxdsc_one}  Collection of interface RX discard counter failed 1st time, see previous test case for details
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX discard counter 1st database does not contain any entries                 values=False
    Variable Should Exist  ${dn_rxdsc_two}  Collection of interface RX discard counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_rxdsc_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX discard counter 2nd database does not contain any entries                 values=False
    # Compare two respective dictionaries for counter increment
    :FOR  ${key}  IN  @{dn_rxerr_one}
    \  ${err_one}=    Get From Dictionary    ${dn_rxerr_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_rxerr_two}  ${key}
    \  ${err_two}=    Get From Dictionary    ${dn_rxerr_two}  ${key}
    \  Run keyword if  ${err_two} > ${err_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has input errors incrementing
    \  Dictionary Should Contain Key    ${dn_rxdsc_one}  ${key}
    \  ${dsc_one}=    Get From Dictionary    ${dn_rxdsc_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_rxdsc_two}  ${key}
    \  ${dsc_two}=    Get From Dictionary    ${dn_rxdsc_two}  ${key}
    \  Run keyword if  ${dsc_two} > ${dsc_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has input discards incrementing

Verify ACI Interface Counters (output error and discard)
    [Documentation]  Verify that interface output error and discard counters are not incrementing on any node/interface
    [Tags]      aci-operations  aci-fabric-counters
    Variable Should Exist  ${dn_txerr_one}  Collection of interface TX error counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txerr_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX error counter 1st database does not contain any entries                   values=False
    Variable Should Exist  ${dn_txerr_two}  Collection of interface TX error counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txerr_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX error counter 2nd database does not contain any entries                   values=False
    Variable Should Exist  ${dn_txdsc_one}  Collection of interface TX discard counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txdsc_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX discard counter 1st database does not contain any entries                 values=False
    Variable Should Exist  ${dn_txdsc_two}  Collection of interface TX discard counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txdsc_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX discard counter 2nd database does not contain any entries                 values=False
    # Compare two respective dictionaries for counter increment
    :FOR  ${key}  IN  @{dn_txerr_one}
    \  ${err_one}=    Get From Dictionary    ${dn_txerr_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_txerr_two}  ${key}
    \  ${err_two}=    Get From Dictionary    ${dn_txerr_two}  ${key}
    \  Run keyword if  ${err_two} > ${err_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has output errors incrementing
    \  Dictionary Should Contain Key    ${dn_txdsc_one}  ${key}
    \  ${dsc_one}=    Get From Dictionary    ${dn_txdsc_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_txdsc_two}  ${key}
    \  ${dsc_two}=    Get From Dictionary    ${dn_txdsc_two}  ${key}
    \  Run keyword if  ${dsc_two} > ${dsc_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has output discards incrementing


```
### Template Data Validation Model:
```json
{'counter_collection_interval': {'descr': 'Time interval between counter collection',
                                 'mandatory': True,
                                 'regex': {'exact_match': False,
                                           'pattern': '[a-zA-Z0-9]+'},
                                 'source': 'config',
                                 'type': 'string'}}
```
## login.robot
### Template Description:
Checks that ACI user login


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
password | Password for APIC user | True |   | ATAG config file


### Template Body:
```
Verify ACI Login
    [Documentation]   Verifies ACI user login
    [Tags]      aci-operations  aci-fabric-aaa
    ${auth_cookie}=  ACI REST login on ${apic}
    log  "Authentication successful, received authentication token '${auth_cookie}"


```
### Template Data Validation Model:
```json
{'password': {'descr': 'Password for APIC user',
              'length': [1, 64],
              'mandatory': True,
              'source': 'config',
              'type': 'str'}}
```
## login_cimc.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
apic_hostname | APIC Hostname | True | None | wordbook
apic_id | APIC Node ID | True |   | wordbook
cimc_ip | CIMC IP Address in the form of IP/Mask | True | None | DAFE Excel Sheet


### Template Body:
```
{% set cimc_ip = config['cimc_ip'].split('/') %}
Verify CIMC Login - APIC {{config['apic_id']}}
    [Documentation]  Verifies CIMC login
    ...  APIC Node ID: {{config['apic_id']}}
    ...  APIC Hostname: {{config['apic_hostname']}}
    ...  CIMC IP: {{ cimc_ip[0] }}
    [Tags]      aci-operations  aci-apic-cimc
    # Login
    connect to device "{{config['apic_hostname']}}_cimc" via "cli"


```
### Template Data Validation Model:
```json
{'apic_hostname': {'default': 'None',
                   'descr': 'APIC Hostname',
                   'length': [1, 64],
                   'mandatory': True,
                   'regex': {'exact_match': False,
                             'pattern': '[a-zA-Z0-9_.:-]+'},
                   'source': 'wordbook',
                   'type': 'str'},
 'apic_id': {'descr': 'APIC Node ID',
             'mandatory': True,
             'range': [1, 100],
             'source': 'wordbook',
             'type': 'int'},
 'cimc_ip': {'default': 'None',
             'descr': 'CIMC IP Address in the form of IP/Mask',
             'mandatory': True,
             'source': 'workbook',
             'type': 'str'}}
```
## route_presence_ipv4.robot
### Template Description:
Checks within a specivfied VRF the presense of a particular prefix within the routing table of all leafs,
where the VRF have been deployed.

> This testcase template only works for external routes, as ACI internal routes may intentionally not be programmed on all leafs.

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
prefix |   | True | None | ATAG config file
name | VRF Name | True |   | ATAG config file
tenant | Tenant Name | True |   | ATAG config file


### Template Body:
```
{% set prefix_config_parameter = config['tenant'] + "|" + config['name'] + "|routes" %}
{% if config[prefix_config_parameter] %}
{% for prefix in config[prefix_config_parameter] %}
Verify ACI IPv4 Route - Tenant {{config['tenant']}}, VRF {{config['name']}}, Prefix {{prefix}}
    ${apic} =  Set Variable  apic3
    [Documentation]   Verifies a route towards IPv4 prefix '{{prefix}}' is present on at least one leaf within Tenant '{{config['tenant']}}', VRF '{{config['name']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['name']}}
    ...  - Prefix: {{prefix}}
    [Tags]      aci-operational-state  aci-tenant  aci-tenant-vrf  aci-tenant-vrf-route
    # Retrieve list of nodes with VRF deployed
    log  Retrieving host with VRF deployed
    ${uri} =  Set Variable  /api/node/class/uribv4Dom
    ${filter} =  Set Variable  rsp-subtree-class=uribv4Route&query-target-filter=eq(uribv4Dom.name,"{{config['tenant']}}:{{config['name']}}")
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200      Failure executing API call		values=False
    # Verify if VRF are deployed on any node
    run keyword if  ${return.totalCount} == 0  run keyword
    ...  Fail  VRF '{{config['name']}}' under Tenant '{{config['tenant']}}' are not deployed on any fabric node
    # Iterate through the nodes with VRF deployed and check if prefix is present in urib
    log  Iterate through the nodes with VRF deployed and check if prefix is present in urib
    : FOR   ${node}  IN  @{return.payload}
    \  # Extract node id from dn
    \  ${matches} =  Get Regexp Matches  ${node.uribv4Dom.attributes.dn}  pod-\\d+\/node-\\d+
    \  ${node_id} =  Set Variable  ${matches[0]}
    \  log  Inspecting uribv4 on node '${node_id}'
    \  # Retrieve uribv4 from node
    \  ${uri} =   Set Variable  /api/mo/topology/${node_id}/sys/uribv4/dom-{{config['tenant']}}:{{config['name']}}/db-rt
    \  ${filter} =  Set Variable  rsp-subtree=children
    \  ${urib}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${urib.status}   200     Failure executing API call		values=False
    \  ${urib_entries} =  Set Variable  ${urib.payload[0].uribv4Db.children}
    \  ${match_count} =  Get ACI uribv4 Prefix Match Count  ${urib_entries}  {{prefix}}
    \  log  Prefix matched ${match_count} time within the urib of tenant '{{config['tenant']}}', vrf '{{config['name']}}' on node '${node_id}'
    \  run keyword if  ${match_count} == 0  run keyword
    \  ...  run keyword And Continue on Failure    Fail    Prefix '{{prefix}}' are not present in the routing table of node '${node_id}' under tenant '{{config['tenant']}}', vrf '{{config['name']}}'

{% endfor %}
{% endif %}

```
### Template Data Validation Model:
```json
{'name': {'descr': 'VRF Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'config',
          'type': 'str'},
 'prefix': {'default': 'None',
            'mandatory': True,
            'source': 'config',
            'type': 'str'},
 'tenant': {'descr': 'Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'config',
            'type': 'str'}}
```
## software_version_apic.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
apic_id | APIC Fabric ID | True |   | wordbook
sw_running_mode | Expected Software Version | False | normal | ATAG config file
pod_id | Fabric POD ID which the APIC belongs to | True |   | wordbook
software_version | Expected Software Version | True | None | ATAG config file


### Template Body:
```
{% if 'sw_running_mode' not in config %}
  {% set x=config.__setitem__('sw_running_mode', 'normal') %}
{% endif %}
Verify APIC Software Version - APIC {{config['apic_id']}}
    [Documentation]   Verifies that APIC {{config['apic_id']}} in POD {{config['pod_id']}} are running the expeced software version
    ...  POD: {{config['pod_id']}}
    ...  APIC ID: {{config['apic_id']}}
    ...  Software Version: {{config['software_version']}}
    ...  Software Running Mode: {{config['sw_running_mode']}}
    [Tags]      aci-operations  aci-software-version
    ${uri} =  Set Variable  /api/mo/topology/pod-{{config['pod_id']}}/node-{{config['apic_id']}}/sys/ctrlrfwstatuscont/ctrlrrunning
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving controller software information		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareCtrlrRunning.attributes.version}   {{config['software_version']}}         APIC controller not running expected software version                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareCtrlrRunning.attributes.mode}      {{config['sw_running_mode']}}          Software running mode not matching expected configration                    values=False


```
### Template Data Validation Model:
```json
{'apic_id': {'descr': 'APIC Fabric ID',
             'mandatory': True,
             'range': [1, 100],
             'source': 'wordbook',
             'type': 'int'},
 'pod_id': {'descr': 'Fabric POD ID which the APIC belongs to',
            'mandatory': True,
            'range': [1, 10],
            'source': 'wordbook',
            'type': 'int'},
 'software_version': {'default': 'None',
                      'descr': 'Expected Software Version',
                      'length': [1, 64],
                      'mandatory': True,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'config',
                      'type': 'str'},
 'sw_running_mode': {'default': 'normal',
                     'descr': 'Expected Software Version',
                     'length': ['normal'],
                     'mandatory': False,
                     'source': 'config',
                     'type': 'enum'}}
```
## software_version_node.robot
### Template Description:

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
sw_running_mode | Expected Software Version | False | normal | ATAG config file
software_version | Expected Software Version | True | None | ATAG config file
pod_id | Fabric POD ID which the switch belongs to | True |   | wordbook
node_id | Node ID | True |   | wordbook


### Template Body:
```
{% if 'sw_running_mode' not in config %}
  {% set x=config.__setitem__('sw_running_mode', 'normal') %}
{% endif %}
Verify ACI Node Software Version - Node {{config['node_id']}}
    [Documentation]   Verifies that ACI Node {{config['node_id']}} in POD {{config['pod_id']}} are running the expeced software version
    ...  POD: {{config['pod_id']}}
    ...  Node ID: {{config['node_id']}}
    ...  Software Version: {{config['software_version']}}
    ...  Software Running Mode: {{config['sw_running_mode']}}
    [Tags]      aci-operations  aci-software-version
    ${uri} =  Set Variable  /api/mo/topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}/sys/fwstatuscont/running
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving node software information		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareRunning.attributes.peVer}   {{config['software_version']}}           Node not running expected software version                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareRunning.attributes.mode}    {{config['sw_running_mode']}}            Software running mode not matching expected configration                    values=False


```
### Template Data Validation Model:
```json
{'node_id': {'descr': 'Node ID',
             'mandatory': True,
             'range': [101, 4000],
             'source': 'wordbook',
             'type': 'int'},
 'pod_id': {'descr': 'Fabric POD ID which the switch belongs to',
            'mandatory': True,
            'range': [1, 10],
            'source': 'wordbook',
            'type': 'int'},
 'software_version': {'default': 'None',
                      'descr': 'Expected Software Version',
                      'length': [1, 64],
                      'mandatory': True,
                      'regex': {'exact_match': False,
                                'pattern': '[a-zA-Z0-9_.:-]+'},
                      'source': 'config',
                      'type': 'str'},
 'sw_running_mode': {'default': 'normal',
                     'descr': 'Expected Software Version',
                     'length': ['normal'],
                     'mandatory': False,
                     'source': 'config',
                     'type': 'enum'}}
```
