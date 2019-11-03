{#
Verifies Leaf/Spine Interface Policy Group configuration

> The configuration of associated interface policies are not verified by this template.
#}
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

