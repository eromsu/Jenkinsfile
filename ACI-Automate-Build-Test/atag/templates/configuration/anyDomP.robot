{#
Verifies Physical, External Bridged, External Routed, and VMware VMM domain configuration including VLAN pool association.

> The configuration of the VLAN pool itself are not verified by this template.
> Detailed configuration verification (vCenter address, credentials, etc.) are not veriifed by this template.
#}
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

