{#
Verifies vPC Domain (also called vPC explicit protection group) configuration
#}
Verify ACI vPC Domain Configuration - Domain {{config['name']}}
    [Documentation]   Verifies that vPC Domain (or vPC Explicit Protection Group) '{{config['name']}}' are configured with the expected parameters
    ...  - vPC Domain Name:  {{config['name']}}
    ...  - Logical Pair ID: {{config['logical_pair_id']}}
    ...  - Left Node ID: {{config['left_node_id']}}
    ...  - Right Node ID: {{config['right_node_id']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-vpc-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/protpol/expgep-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=fabricNodePEp
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		vPC Domain does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].fabricExplicitGEp.attributes.name}   {{config['name']}}      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricExplicitGEp.attributes.id}		{{config['logical_pair_id']}}           Logical Pair ID not matching expected configuration                 values=False
    # Iterate through the fabric nodes
    Set Test Variable  ${left_node_found}		"Node not found"
    Set Test Variable  ${right_node_found}		"Node not found"
    : FOR  ${node}  IN  @{return.payload[0].fabricExplicitGEp.children}
	\  run keyword if  "${node.fabricNodePEp.attributes.id}" == "{{config['left_node_id']}}"  run keyword
	\  ...  Set Test Variable  ${left_node_found}  "Node found"
	\  run keyword if  "${node.fabricNodePEp.attributes.id}" == "{{config['right_node_id']}}"  run keyword
	\  ...  Set Test Variable  ${right_node_found}  "Node found"
	run keyword if  not ${left_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Fabric Node '{{config['left_node_id']}}' not associated with vPC Domain
	run keyword if  not ${right_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Fabric Node '{{config['right_node_id']}}' not associated with vPC Domain

