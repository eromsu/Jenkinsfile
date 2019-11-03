{#
Verifies MCP Fabric Access Interface Policy configuration.
#}
Verify ACI MCP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that LLDP Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}	
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - MCP State: {{config['mcp_state']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/mcpIfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.name}		{{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].mcpIfPol.attributes.descr}"   "{{config['description']}}"          Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.adminSt}     {{config['mcp_state']}}     		Admin State not matching expected configuration                 values=False

