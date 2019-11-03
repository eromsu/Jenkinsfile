{#
Verifies Leaf/Spine Interface Profile to Switch Profile assocation configuration

> The Switch Profile must exist.
> The configuration of Interface Profile and Switch Profile are not verified by this template.
#}
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

