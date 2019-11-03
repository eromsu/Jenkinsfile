{#
Checks fabric connectivity between leaf and spine.

> This test case template verifies LLDP neighborship and link operation mode.
#}
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