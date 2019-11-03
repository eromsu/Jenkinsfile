{#
Verifies VLAN Pool configuration.

> The configuration of VLAN Encap Blocks are not verified in this test case template.
#}
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

