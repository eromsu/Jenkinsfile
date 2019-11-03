{#
Verifies the Fabric BGP AS number and route reflector configuration

> To be effective, this BGP default policy should be associated with a POD Policy, which are not validated by this template
#}
Verify ACI Fabric BGP Configuration - Route Reflector Node '{{config['bgp_rr_node_id']}}'
    [Documentation]   Verifies that ACI Fabric BGP Configuration are configured with the expected parameters
    ...  - Policy Name: default
    ...  - BGP AS Number: {{config['fabric_bgp_as']}}
    ...  - BGP Route Reflector POD ID: {{config['pod_id']}}
    ...  - BGP Route Reflector Node: {{config['bgp_rr_node_id']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-bgp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/bgpInstP-default/as
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers		${return.payload[0].bgpAsP.attributes.asn}   {{config['fabric_bgp_as']}}    BGP AS Number not matching expected configuration               values=False
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/bgpInstP-default/rr/node-{{config['bgp_rr_node_id']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP RR)		values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		                                                Node not defined as Fabric BGP Route Refelector		            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.payload[0].bgpRRNodePEp.attributes.podId}  {{config['pod_id']}}		        POD ID for Node not matching expected configuration		        values=False

