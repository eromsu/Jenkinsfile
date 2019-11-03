{#
Verifies Link Level Fabric Access Interface Policy configuration.
#}
{% if 'debounce' not in config or config['debounce'] == "" %}
  {% set x=config.__setitem__('debounce', '100') %}
{% endif %}
{% if 'fec_mode' not in config or config['fec_mode'] == "" %}
  {% set x=config.__setitem__('fec_mode', 'inherit') %}
{% endif %}
Verify ACI Link Level Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that Link Level Channel Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
	...  - Speed: {{config['speed']}}
	...  - Auto Negotiation: {{config['autoneg']}}
	...  - Link Debounce Interval: {{config['debounce']}}
	...  - FEC Mode: {{config['fec_mode']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	{{config['name']}}      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			{{config['speed']}}         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		{{config['autoneg']}}          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	{{config['debounce']}}         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	{{config['debounce']}}         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		{{config['fec_mode']}}         	FEC Mode not matching expected configuration            	values=False

