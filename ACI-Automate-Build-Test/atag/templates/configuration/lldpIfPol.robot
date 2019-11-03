{#
Verifies LLDP Fabric Access Interface Policy configuration.
#}
Verify ACI LLDP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that LLDP Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - Admin State (RX): {{config['lldp_receive']}}
	...  - Admin State (TX): {{config['lldp_transmit']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lldpIfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.name}		{{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].lldpIfPol.attributes.descr}"   "{{config['description']}}"           Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminRxSt}     {{config['lldp_receive']}}     Admin RX State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminTxSt}     {{config['lldp_transmit']}}     Admin TX State not matching expected configuration                 values=False
	

