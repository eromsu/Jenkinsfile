{#
Checks L3 Node Level BGP Peer for faults.

> This test case template looks at the total number of faults regardless whether they are acknowledged or not.
#}
Checking ACI L3Out Node Level BGP Peer for Faults - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['l3out_node_profile']}}, Peer {{config['bgp_peer_ip']}}
    [Documentation]   Verifies ACI faults for L3Out Node Level BGP Peer '{{config['bgp_peer_ip']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}', Node Profile '{{config['l3out_node_profile']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - BGP Peer: {{config['bgp_peer_ip']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-l3out
    # Retrieve Faults
    {% if config['tenant'] == "infra" and config['isGolfPeer'] == "yes" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/infraPeerP--[{{config['bgp_peer_ip']}}]/fltCnts
    {% else %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]/fltCnts
    {% endif %}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${minor_count} minor faults (passing threshold {{config['minor']}})"

