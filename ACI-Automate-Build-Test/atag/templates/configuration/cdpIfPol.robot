{#
Verifies CDP Fabric Access Interface Policy configuration.
#}
Verify ACI CDP Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that CDP Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
	...  - Description: {{config['description']}}
	...  - Admin State: {{config['cdp_state']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/cdpIfP-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.name}		{{config['name']}}     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.adminSt}	{{config['cdp_state']}}     Admin State not matching expected configuration                   values=False

