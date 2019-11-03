{#
Verifies VLAN Pool Encapsulation Block configuration.

> !!! This template can be used as-is for ACI 3.2 and above for prior versions the "role" attribute must be removed.
#}
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

