{#
Checks fabric connectivity between leaf and endpoints (servers, Firewall's, Load Balancer's, etc.).

> This test case template relies on LLDP or CDP to verify connectivity.
> Note: If endpoints does not run either of these protocols will the test fail.
#}
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