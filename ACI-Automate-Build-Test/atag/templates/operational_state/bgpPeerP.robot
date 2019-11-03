{#
Verifies L3 Node Level BGP Peer session status.

This test template verifies that the BGP peer are defined on the defined leaf switches,
and that the BGP session are in Established state.
#}
Verify ACI L3out BGP peer state - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, BGP Peer {{config['bgp_peer_ip']}}
    [Documentation]   Verifies that BGP peer state for BGP peer '{{config['bgp_peer_ip']}}' defined under Tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}' 
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - BGP Peer: {{config['bgp_peer_ip']}}
    [Tags]      aci-operations  aci-tenant  aci-tenant-l3out  aci-tenant-l3out-bgp
    # Retrieve VRF associated with L3Out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}
    ${filter} =  Set Variable  rsp-subtree=children&rsp-subtree-class=l3extRsEctx
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retrieving L3Out VRF association		values=False
    ${vrf} =  Set Variable  ${return.payload[0].l3extOut.children[0].l3extRsEctx.attributes.tnFvCtxName}
    # Retrieve Fabric Nodes associated with Node Profile
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}
    ${filter} =  Set Variable  rsp-subtree=children&rsp-subtree-class=l3extRsNodeL3OutAtt
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    run keyword if  "${return.totalCount}" == "0"  run keyword
    ...  RUN  Fail  No fabric nodes associated with L3Out Node Profile
    # Check BGP peer status on each logical node
    : FOR  ${node}  IN  @{return.payload[0].l3extLNodeP.children}
    \  log  ${node.l3extRsNodeL3OutAtt.attributes.tDn}
    \  @{fabric_node} =  Split String  ${node.l3extRsNodeL3OutAtt.attributes.tDn}  /
	\  ${uri} =  Set Variable  /api/node/mo/topology/${fabric_node[1]}/${fabric_node[2]}/sys/bgp/inst/dom-{{config['tenant']}}:${vrf}/peer-[{{config['bgp_peer_ip']}}/32]/ent-[{{config['bgp_peer_ip']}}]
    \  ${return_peer_status}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_peer_status.status}        200		Failure executing API call		values=False
	\  run keyword And Continue on Failure  Should Be Equal as Integers     ${return_peer_status.totalCount}    1		BGP peer not found on ${fabric_node[2]}		values=False
    # add check and only execute test if peer is avialable
    \  run keyword if  "${return_peer_status.totalCount}" == "1"  run keyword
    \  ...  run keyword And Continue on Failure  Should Be Equal as Strings      ${return_peer_status.payload[0].bgpPeerEntry.attributes.operSt}    established		BGP session not established	on ${fabric_node[2]}	values=False

