{#
Verifies APIC Fabric Infrastructure VLAN configuration.

> The Infrastructure VLAN configuration on APICs only. Verification on Spine/Leaf switches are not performed by this template.
#}
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


