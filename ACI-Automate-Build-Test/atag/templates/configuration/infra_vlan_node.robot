{#
Verifies APIC Fabric Infrastructure VLAN configuration.

> The Infrastructure VLAN configuration on Spine/Leaf switches only. Verification on APICs are not performed by this template.
#}
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


