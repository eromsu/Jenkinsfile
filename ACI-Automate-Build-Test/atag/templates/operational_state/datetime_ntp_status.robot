{#
Checkes Datatime / Clock Synchronization status on fabric nodes.
#}
Checking ACI Datetime / Clock Synchronization Status'
    [Documentation]   Verifies ACI Datetime / Clock Synchronization Status
    [Tags]      aci-operations  aci-fabric  aci-fabric-ntp
    # APIC Fabric Nodes
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "controller")
    ${nodeList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${nodeList.status}        200		Failure executing API call		values=False
    run keyword if  "${nodeList.totalCount}" == "0"
    ...  Fail  No Controller Nodes registered within the Fabric
    # Iterate through the controller nodes
    : FOR  ${node}  IN  @{nodeList.payload}
    \  ${uri} =  Set Variable  /api/node/mo/${node.fabricNode.attributes.dn}/sys.json?query-target=subtree&target-subtree-class=datetimeNtpq
    \  ${ntpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${ntpState.status}        200		Failure executing API call (APIC)		values=False
    \  run keyword unless  ${ntpState.totalCount} > 0  run Keywords
    \  ...  Run Keyword And Continue On Failure  Fail  Clock not synchronized on node '${node.fabricNode.attributes.dn}' (no NTP peers defined)
    \  ...  AND  Continue For Loop
    \  @{ntp_status} =  Check ACI Controller NTP Status  ${ntpState.payload}
    \  ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntp_status[0]}  "synced_remote_server"
    \  run keyword unless  ${ntp_sync_status}  run keywords
    \  ...  Run Keyword And Continue On Failure  Fail  Clock not synchonized on node '${node.fabricNode.attributes.dn}' 
    \  ...  AND  log  Node '${node.fabricNode.attributes.dn}', NTP Stratum: ${ntp_status[2]}, NTP peers: ${ntp_status[3]}
    \  run keyword if  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Server: ${ntp_status[1]}, NTP Stratum: ${ntp_status[2]}, NTP peers: ${ntp_status[3]}
    # Leaf Fabric nodes
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "leaf")
    ${nodeList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${nodeList.status}        200		Failure executing API call		values=False
    run keyword if  "${nodeList.totalCount}" == "0"
    ...  Fail  No Leaf Nodes registered within the Fabric
    # Iterate through the leaf nodes
    : FOR  ${node}  IN  @{nodeList.payload}
    \  ${uri} =  Set Variable  /api/node/mo/${node.fabricNode.attributes.dn}/sys/time.json?rsp-subtree=children
    \  ${ntpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${ntpState.status}        200		Failure executing API call (Leaf)		values=False
    \  ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}  "synced_remote_server"
    \  ${ntp_peers} =  Get ACI Switch NTP peers  ${ntpState.payload[0].datetimeClkPol.children}
    \  run keyword And Continue on Failure  Should Be Equal as Strings   ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}   "synced_remote_server"    Clock not synchronized on node '${node.fabricNode.attributes.dn}'       values=False
    \  run keyword unless  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers} 
    \  run keyword if  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Server: ${ntpState.payload[0].datetimeClkPol.attributes.refId}, NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers}
    # Spine Fabric nodes
    ${uri} =  Set Variable  /api/node/class/fabricNode
    ${filter} =  Set Variable  query-target-filter=eq(fabricNode.role, "spine")
    ${nodeList}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${nodeList.status}        200		Failure executing API call		values=False
    run keyword if  "${nodeList.totalCount}" == "0"
    ...  Fail  No Leaf Nodes registered within the Fabric
    # Iterate through the spine nodes
    : FOR  ${node}  IN  @{nodeList.payload}
    \  ${uri} =  Set Variable  /api/node/mo/${node.fabricNode.attributes.dn}/sys/time.json?rsp-subtree=children
    \  ${ntpState} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${ntpState.status}        200		Failure executing API call (Leaf)		values=False
    \  ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}  "synced_remote_server"
    \  ${ntp_peers} =  Get ACI Switch NTP peers  ${ntpState.payload[0].datetimeClkPol.children}
    \  run keyword And Continue on Failure  Should Be Equal as Strings   ${ntpState.payload[0].datetimeClkPol.attributes.srvStatus}   "synced_remote_server"    Clock not synchronized on node '${node.fabricNode.attributes.dn}'       values=False
    \  run keyword unless  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers} 
    \  run keyword if  ${ntp_sync_status}
    \  ...  log  Node '${node.fabricNode.attributes.dn}', NTP Server: ${ntpState.payload[0].datetimeClkPol.attributes.refId}, NTP Stratum: ${ntpState.payload[0].datetimeClkPol.attributes.StratumValue}, NTP peers: ${ntp_peers}

