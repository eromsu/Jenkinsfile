{#
Verifies L2 Fabric Access Interface Policy configuration.
#}
{% if 'qinq' not in config %}
  {% set x=config.__setitem__('qinq', 'disabled') %}
{% endif %}
{% if 'reflective_relay' not in config %}
  {% set x=config.__setitem__('reflective_relay', 'disabled') %}
{% endif %}
Verify ACI L2 Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that L2 Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
	...  - VLAN Scope: {{config['vlan_scope']}}
	...  - QinQ: {{config['qinq']}}
	...  - Reflective Relay: {{config['reflective_relay']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/l2IfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.name}			{{config['name']}}    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vlanScope}	{{config['vlan_scope']}}   VLAN Scope not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.qinq}		{{config['qinq']}}   	   QinQ not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vepa}		{{config['reflective_relay']}}   Reflective Relay not matching expected configuration                   values=False

