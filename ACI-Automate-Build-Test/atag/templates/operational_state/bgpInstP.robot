{#
Verifies the Fabric BGP peer state on the Route Reflector nodes

> This template only verifies the BGP peer state for the BGP sessions internal to the local POD.
#}
Verify ACI Fabric BGP Peer State - Route Reflector Node '{{config['bgp_rr_node_id']}}'
    [Documentation]   Verifies that Fabric BGP peer state for Route Reflector Node '{{config['bgp_rr_node_id']}}'
    ...  - BGP Route Reflector POD ID: {{config['pod_id']}}
    ...  - BGP Route Reflector Node: {{config['bgp_rr_node_id']}}
    [Tags]      aci-operations  aci-fabric  aci-fabric-bgp
    # Retrieve TEP Pool of POD
    ${uri} =  Set Variable  /api/mo/uni/controller/setuppol/setupp-{{config['pod_id']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call (TEP Pool)		values=False
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retrieving TEP Pool Configuration		values=False
    ${tepPool} =  Set Variable  ${return.payload[0].fabricSetupP.attributes.tepPool}
    # Retrieve list of leaf switches and their associated TEP address
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "leaf")
    ${leafList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${leafList.status}        200		Failure executing API call (Leaf List)		values=False
    run keyword if  "${leafList.totalCount}" == "0"  run keyword
    ...  RUN  Fail  No Leaf switches registered within the Fabric
    : FOR  ${leaf}  IN  @{leafList.payload}
       # Check if leaf is part of the local pod
    \  ${podMember} =  Run Keyword And Return Status    Should Contain  ${leaf.fabricNode.attributes.dn}  pod-1
    \  Continue For Loop If  ${podMember} == False
       # Check BGP Peer state towards leafs in local POD
    \  ${uri} =  Set Variable  /api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['bgp_rr_node_id']}}/sys/bgp/inst/dom-overlay-1/peer-[${tepPool}]/ent-[${leaf.fabricNode.attributes.address}]
    \  ${bgpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${bgpState.status}        200		Failure executing API call (BGP Peer State)		values=False
    \  Should Be Equal as Integers     ${bgpState.totalCount}    1		    Failure retrieving BGP Peer State		values=False
    \  run keyword And Continue on Failure  Should Be Equal as Strings      "${bgpState.payload[0].bgpPeerEntry.attributes.operSt}"     "established"       Fabric BGP session towards node '${leaf.fabricNode.attributes.dn}' is down      values=False

