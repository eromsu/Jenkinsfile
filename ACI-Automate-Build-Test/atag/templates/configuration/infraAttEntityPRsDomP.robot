{# 

Verifies Access Attachable Entity Profile domain association.

The template curretnyly supports the association with 
Physical , External Routed, External Bridged , VMWare VMM Domain

> The configuration of the AAEP and the domains themself are not verified in this test case template.
#}
Verify ACI AAEP Domain Association Configuration - AAEP {{config['aaep_name']}}, Domain {{config['domain_name']}}
    [Documentation]   Verifies that AAEP '{{config['aaep_name']}}' domain association are configured with the expected parameters:
	...  - AAEP Name: {{config['aaep_name']}}
	...  - Domain Name: {{config['domain_name']}}
	...  - Domain Type: {{config['domain_type']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Define tDn
	{% if config['domain_type'] == 'physical' %}
	${tDn} =  Set Variable  uni/phys-{{config['domain_name']}}
	{% elif config['domain_type'] == 'external_l3' %}
	${tDn} =  Set Variable  uni/l3dom-{{config['domain_name']}}
	{% elif config['domain_type'] == 'external_l2' %}
	${tDn} =  Set Variable  uni/l2dom-{{config['domain_name']}}
	{% elif config['domain_type'] == 'vmm_vmware' %}
	${tDn} =  Set Variable  uni/vmmp-VMware/dom-{{config['domain_name']}}
	{% endif %}
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-{{config['aaep_name']}}/rsdomP-[${tDn}]
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Domain association not matching expected configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraRsDomP.attributes.tDn}   ${tDn}	tDn not matching expected configuration        values=False

