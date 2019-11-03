*** Settings ***
Library  RASTA
Resource  rasta.robot
Library  XML
Library  String
Library  Collections
Suite Setup   setup-test
Force Tags  aci

*** Variables ***
${testbed}  aciSim_test_testbed.yaml
${apic}     apic1

*** Keywords ***
setup-test
    use testbed "${testbed}"

Logout via url "${logout_url}" and close browser
   visit "${logout_url}"
   close browser

Logout CIMC and close browser
    select the main window
    click on the object with xpath ".//div[contains(@class,'settingIcon')]"
    wait until object is visible via xpath ".//td[@id='logout_text']"
    click on the object with xpath ".//td[@id='logout_text']"
    wait until object is present via xpath ".//span[@id='LP_LoginButton']"
    close browser

Get ACI uribv4 Prefix Match Count
    [Arguments]   ${urib}  ${prefix}
    ${match_count} =  Set Variable  0
    : FOR  ${route}  IN  @{urib}
    \  log  ${route}
    \  log  ${route.uribv4Route.attributes}
    \  ${count} =  Get Match Count  ${route.uribv4Route.attributes}  ${prefix}
    \  ${match_count} =  Evaluate  ${match_count} + ${count}
    log  ${match_count}
    [Return]  ${match_count}

Check ACI Controller NTP Status
    [Arguments]     ${ntpq}
    ${ntp_sync} =  Set Variable  "not_synchronized"
    ${ntp_peers} =      Create List
    : FOR  ${peer}  IN  @{ntpq}
    \  log  ${peer}
    \  Append To List  ${ntp_peers}  ${peer.datetimeNtpq.attributes.remote}
    \  ${tally} =  Run Keyword And Return Status  Should be equal as strings  ${peer.datetimeNtpq.attributes.tally}  *
    \  ${ntp_sync} =  Set Variable If  ${tally}  "synced_remote_server"
    \  ${ntp_server} =  Set Variable If  ${tally}  ${peer.datetimeNtpq.attributes.remote}
    \  ${ntp_statum} =  Set Variable If  ${tally}  ${peer.datetimeNtpq.attributes.stratum}
    ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntp_sync}  "synced_remote_server"
    ${ntp_statum} =  Set Variable If  "${ntp_sync_status} == False"  ${ntpq[0].datetimeNtpq.attributes.stratum}
    [Return]  ${ntp_sync}  ${ntp_server}  ${ntp_statum}  ${ntp_peers}

Get ACI Switch NTP peers
    [Arguments]     ${peer_list}
    ${ntp_peers} =      Create List
    : FOR  ${peer}  IN  @{peer_list}
    \  Append to List  ${ntp_peers}  ${peer.datetimeNtpProvider.attributes.name}
    [Return]  ${ntp_peers}

*** Test Cases ***
Verify ACI Tenant Configuration - Tenant tenant1
    [Documentation]   Verifies that ACI tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    [Tags]      aci-conf  aci-tenant
    # Retrieve Tenant
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Tenant parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
    Log  ${return.payload[0]}
    Log  ${return.payload[1]}
    Should Be Equal as Strings      ${return.payload[1].fvTenant.attributes.dn}     uni/tn-tenant1       Failure retreiving configuration                    values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.name}   tenant1              Failure retreiving configuration                    values=False

Verify ACI Tenant Configuration - Tenant tenant2
    [Documentation]   Verifies that ACI tenant 'tenant2' are configured with the expected parameters:
    ...  - Tenant Name: tenant2
    [Tags]      aci-conf  aci-tenant
    # Retrieve Tenant
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant2
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Tenant parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.dn}     uni/tn-tenant2       Failure retreiving configuration                    values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.name}   tenant2              Failure retreiving configuration                    values=False

Verify ACI VRF Configuration - Tenant tenant1, VRF main
    [Documentation]   Verifies that ACI VRF 'main' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - VRF Name: main
    ...  - Policy Enforcement: enforced
    ...  - Policy Enforcement Direction: egress
    ...  - BGP Timers: default
    ...  - Monitoring Policy:
    ...  - BGP IPv4 Context Policy Name: default
    ...  - GOLF Opflex Mode:
    ...  - GOLF VRF Name:
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve VRF
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvCtx.attributes.name}   main      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfPref}"  "enforced"     Policy Control Enforcement Preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfDir}"  "egress"     Policy Control Enforcement Direction not matching expected configuration                values=False
    # BGP Timers
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main/rsbgpCtxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP Timer)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP Timer)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBgpCtxPol.attributes.tnBgpCtxPolName}"  "default"             BGP Timer not matching expected configuration                       values=False
    # Monitoring Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main/rsCtxMonPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Monitoring Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Monitoring Policy not matching expected configuration		values=False
    # BGP IPv4 Context Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main/rsctxToBgpCtxAfPol-[default]-ipv4-ucast
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP IPv4 Context Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP IPv4 Context Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToBgpCtxAfPol.attributes.tnBgpCtxAfPolName}"  "default"             BGP IPv4 Context Policy Name not matching expected configuration                       values=False

Verify ACI VRF Configuration - Tenant tenant1, VRF secondary
    [Documentation]   Verifies that ACI VRF 'secondary' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - VRF Name: secondary
    ...  - Policy Enforcement: enforced
    ...  - Policy Enforcement Direction: ingress
    ...  - Monitoring Policy:
    ...  - GOLF Opflex Mode:
    ...  - GOLF VRF Name:
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve VRF
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-secondary
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvCtx.attributes.name}   secondary      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfPref}"  "enforced"     Policy Control Enforcement Preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfDir}"  "ingress"     Policy Control Enforcement Direction not matching expected configuration                values=False
    # Monitoring Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-secondary/rsCtxMonPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Monitoring Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Monitoring Policy not matching expected configuration		values=False

Checking ACI VRF for Faults - Tenant tenant1, VRF main
    [Documentation]   Verifies ACI faults for VRF 'main' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - VRF Name: main
    ...  - Critical fault count <= 1
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 3
    [Tags]      aci-faults  aci-tenant  aci-tenant-vrf
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${critical_count} critical faults (passing threshold 1)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 3  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${minor_count} minor faults (passing threshold 3)"

Checking ACI VRF for Faults - Tenant tenant1, VRF secondary
    [Documentation]   Verifies ACI faults for VRF 'secondary' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - VRF Name: secondary
    ...  - Critical fault count <= 1
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 3
    [Tags]      aci-faults  aci-tenant  aci-tenant-vrf
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-secondary/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${critical_count} critical faults (passing threshold 1)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 3  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${minor_count} minor faults (passing threshold 3)"

Verify ACI VRF BGP Route-Target Configuration - Tenant tenant1, VRF main, Address-Family ipv4-ucast, Route-Target: route-target:as4-nn2:1:1
    [Documentation]   Verifies that ACI BGP Route-Target Profile for VRF 'main' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - VRF Name: main
    ...  - Address-Family: ipv4-ucast
    ...  - BGP Route-Target: route-target:as4-nn2:1:1
    ...  - BGP Route-Target Type: import
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve BGP Route Target
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main/rtp-ipv4-ucast/rt-[route-target:as4-nn2:1:1]-import
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}    1		BGP Route-Target not configured with expected parameters        values=False

Verify ACI VRF BGP Route-Target Configuration - Tenant tenant1, VRF main, Address-Family ipv4-ucast, Route-Target: route-target:as4-nn2:1:2
    [Documentation]   Verifies that ACI BGP Route-Target Profile for VRF 'main' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - VRF Name: main
    ...  - Address-Family: ipv4-ucast
    ...  - BGP Route-Target: route-target:as4-nn2:1:2
    ...  - BGP Route-Target Type: export
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve BGP Route Target
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ctx-main/rtp-ipv4-ucast/rt-[route-target:as4-nn2:1:2]-export
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}    1		BGP Route-Target not configured with expected parameters        values=False

Verify ACI BD Configuration - Tenant tenant1, BD bd1
    [Documentation]   Verifies that ACI BD 'bd1' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd1
    ...  - BD Name Alias:
    ...  - Associated to VRF: main
    ...  - L2 Unknown Unicast Flooding: proxy
    ...  - L3 Unknown Multicast Flooding: flood
    ...  - Multi Destination Flooding: bd-flood
    ...  - Enable PIM: no
    ...  - ARP Flooding: no
    ...  - Unicast Routing: no
    ...  - Limit IP Learning to Subnet: no
    ...  - Endpoint Dataplane Learning: yes
    ...  - Endpoint Move Detection Mode:
    ...  - IGMP Snooping Policy:
    ...  - Legacy Mode: no
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd1
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		BD not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvBD.attributes.name}   bd1      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.nameAlias}"  ""                    Name alias not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMacUcastAct}"  "proxy"      L2 Unknown Unicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMcastAct}"  "flood"       L3 Unknown Multicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.multiDstPktAct}"  "bd-flood"        Multi Destination Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.arpFlood}"  "no"                     ARP Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unicastRoute}"  "no"           Unicast Routing not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.limitIpLearnToSubnets}"  "no"           Limit IP Learning to Subnet not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.ipLearning}"  "yes"           Endpoint Dataplane Learning not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.mcastAllow}"  "no"                   PIM not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.epMoveDetectMode}"  ""                   Endpoint Move Detection Mode not matching expected configuration                values=False
    # VRF Association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd1/rsctx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (VRF)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (VRF)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtx.attributes.tnFvCtxName}"  "main"                    Associated VRF not matching expected configuration                       values=False
    # IGMP Snooping
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd1/rsigmpsn
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Snooping)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Snooping)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsIgmpsn.attributes.tnIgmpSnoopPolName}"  ""                    IGMP Snooping Policy not matching expected configuration                       values=False

Verify ACI BD Configuration - Tenant tenant1, BD bd2
    [Documentation]   Verifies that ACI BD 'bd2' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd2
    ...  - BD Name Alias:
    ...  - Associated to VRF: main
    ...  - L2 Unknown Unicast Flooding: proxy
    ...  - L3 Unknown Multicast Flooding: flood
    ...  - Multi Destination Flooding: bd-flood
    ...  - Enable PIM: no
    ...  - ARP Flooding: no
    ...  - Unicast Routing: yes
    ...  - Limit IP Learning to Subnet: no
    ...  - Endpoint Dataplane Learning: yes
    ...  - Endpoint Move Detection Mode:
    ...  - IGMP Snooping Policy:
    ...  - Legacy Mode: no
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		BD not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvBD.attributes.name}   bd2      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.nameAlias}"  ""                    Name alias not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMacUcastAct}"  "proxy"      L2 Unknown Unicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMcastAct}"  "flood"       L3 Unknown Multicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.multiDstPktAct}"  "bd-flood"        Multi Destination Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.arpFlood}"  "no"                     ARP Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unicastRoute}"  "yes"           Unicast Routing not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.limitIpLearnToSubnets}"  "no"           Limit IP Learning to Subnet not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.ipLearning}"  "yes"           Endpoint Dataplane Learning not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.mcastAllow}"  "no"                   PIM not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.epMoveDetectMode}"  ""                   Endpoint Move Detection Mode not matching expected configuration                values=False
    # VRF Association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2/rsctx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (VRF)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (VRF)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtx.attributes.tnFvCtxName}"  "main"                    Associated VRF not matching expected configuration                       values=False
    # IGMP Snooping
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2/rsigmpsn
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Snooping)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Snooping)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsIgmpsn.attributes.tnIgmpSnoopPolName}"  ""                    IGMP Snooping Policy not matching expected configuration                       values=False

Verify ACI BD Configuration - Tenant tenant1, BD bd3
    [Documentation]   Verifies that ACI BD 'bd3' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd3
    ...  - BD Name Alias:
    ...  - Associated to VRF: main
    ...  - L2 Unknown Unicast Flooding: proxy
    ...  - L3 Unknown Multicast Flooding: flood
    ...  - Multi Destination Flooding: bd-flood
    ...  - Enable PIM: no
    ...  - ARP Flooding: yes
    ...  - Unicast Routing: yes
    ...  - Limit IP Learning to Subnet: no
    ...  - Endpoint Dataplane Learning: yes
    ...  - Endpoint Move Detection Mode: garp
    ...  - IGMP Snooping Policy:
    ...  - Legacy Mode: no
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd3
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		BD not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvBD.attributes.name}   bd3      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.nameAlias}"  ""                    Name alias not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMacUcastAct}"  "proxy"      L2 Unknown Unicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMcastAct}"  "flood"       L3 Unknown Multicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.multiDstPktAct}"  "bd-flood"        Multi Destination Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.arpFlood}"  "yes"                     ARP Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unicastRoute}"  "yes"           Unicast Routing not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.limitIpLearnToSubnets}"  "no"           Limit IP Learning to Subnet not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.ipLearning}"  "yes"           Endpoint Dataplane Learning not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.mcastAllow}"  "no"                   PIM not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.epMoveDetectMode}"  "garp"                   Endpoint Move Detection Mode not matching expected configuration                values=False
    # VRF Association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd3/rsctx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (VRF)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (VRF)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtx.attributes.tnFvCtxName}"  "main"                    Associated VRF not matching expected configuration                       values=False
    # IGMP Snooping
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd3/rsigmpsn
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Snooping)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Snooping)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsIgmpsn.attributes.tnIgmpSnoopPolName}"  ""                    IGMP Snooping Policy not matching expected configuration                       values=False

Checking ACI BD for Faults - Tenant tenant1, BD bd1
    [Documentation]   Verifies ACI faults for VRF 'bd1' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd1
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-bd
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd1/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold 0)"

Checking ACI BD for Faults - Tenant tenant1, BD bd2
    [Documentation]   Verifies ACI faults for VRF 'bd2' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-bd
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold 0)"

Checking ACI BD for Faults - Tenant tenant1, BD bd3
    [Documentation]   Verifies ACI faults for VRF 'bd3' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd3
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-bd
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd3/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold 0)"

Verify ACI BD Subnet Configuration - Tenant tenant1, BD bd2, Subnet 10.0.0.1/24
    [Documentation]   Verifies that ACI BD Subnet '10.0.0.1/24' under tenant 'tenant1', BD 'bd2' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd2
  	...  - Subnet: 10.0.0.1/24
    ...  - Subnet Scope: public
    ...  - Primary IP Address: no
    ...  - Virtual IP Address: no
    ...  - Subnet Control:
  	...  - ND RA Prefix Policy Name:
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2/subnet-[10.0.0.1/24]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		BD Subnet not configured		values=False
    Should Be Equal as Strings      ${return.payload[0].fvSubnet.attributes.ip}   10.0.0.1/24      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.scope}"  "public"                   Subnet Scope not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.preferred}"  "no"         Primary IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.virtual}"  "no"                Virtual IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.ctrl}"  ""                  Subnet Control not matching expected configuration                       values=False

Verify ACI BD Subnet Configuration - Tenant tenant1, BD bd2, Subnet 11.0.0.1/24
    [Documentation]   Verifies that ACI BD Subnet '11.0.0.1/24' under tenant 'tenant1', BD 'bd2' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd2
  	...  - Subnet: 11.0.0.1/24
    ...  - Subnet Scope: private
    ...  - Primary IP Address: no
    ...  - Virtual IP Address: no
    ...  - Subnet Control:
  	...  - ND RA Prefix Policy Name:
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2/subnet-[11.0.0.1/24]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		BD Subnet not configured		values=False
    Should Be Equal as Strings      ${return.payload[0].fvSubnet.attributes.ip}   11.0.0.1/24      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.scope}"  "private"                   Subnet Scope not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.preferred}"  "no"         Primary IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.virtual}"  "no"                Virtual IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.ctrl}"  ""                  Subnet Control not matching expected configuration                       values=False

Verify ACI BD Subnet Configuration - Tenant tenant1, BD bd3, Subnet 12.0.0.1/24
    [Documentation]   Verifies that ACI BD Subnet '12.0.0.1/24' under tenant 'tenant1', BD 'bd3' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd3
  	...  - Subnet: 12.0.0.1/24
    ...  - Subnet Scope: public
    ...  - Primary IP Address: no
    ...  - Virtual IP Address: no
    ...  - Subnet Control:
  	...  - ND RA Prefix Policy Name:
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd3/subnet-[12.0.0.1/24]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		BD Subnet not configured		values=False
    Should Be Equal as Strings      ${return.payload[0].fvSubnet.attributes.ip}   12.0.0.1/24      Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.scope}"  "public"                   Subnet Scope not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.preferred}"  "no"         Primary IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.virtual}"  "no"                Virtual IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.ctrl}"  ""                  Subnet Control not matching expected configuration                       values=False

Verify ACI BD L3Out Configuration - Tenant tenant1, BD bd2, L3Out L3OUT-main_INT
    [Documentation]   Verifies that ACI BD L3Out 'L3OUT-main_INT' under tenant 'tenant1', BD '' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd2
    ...  - Associated L3Out: L3OUT-main_INT
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/BD-bd2/rsBDToOut-L3OUT-main_INT
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		L3Out not associated with BD		values=False
	Should Be Equal as Strings      ${return.payload[0].fvRsBDToOut.attributes.tnL3extOutName}   L3OUT-main_INT      Failure retreiving configuration		                          values=False

Verify ACI Application Profile Configuration - Tenant tenant1, App Profile app1
    [Documentation]   Verifies that ACI Application Profile 'app1' under tenant 'tenant1' are configured with the expected parameters:
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - QoS Class: unspecified
    [Tags]      aci-conf  aci-tenant  aci-tenant-ap
    # Retrieve AP
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	Should Be Equal as Strings      ${return.payload[0].fvAp.attributes.name}   app1      Failure retreiving configuration		                          values=False
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.prio}"  "unspecified"                  QoS Class not matching expected configuration                       values=False

Verify ACI EPG Configuration - Tenant tenant1, App Profile app1, EPG epg1
    [Documentation]   Verifies that ACI EPG 'epg1' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG Name: epg1
    ...  - Associated to BD: bd1
    ...  - QoS Class: unspecified
    ...  - Intra EPG Isolation: unenforced
    ...  - Preferred Group Member: exclude
    ...  - Flood on Encapsulation: disabled
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvAEPg.attributes.name}   epg1                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.prio}"  "unspecified"                    QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.prefGrMemb}"  "exclude"             Preferred Group Member not matching expected configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.pcEnfPref}"  "unenforced"     Intra EPG Isolation not matching expected configuration       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.floodOnEncap}"  "disabled"         Flood on Encapsulation not matching expected configuration    values=False
    # Verify BD association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rsbd
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvRsBd.attributes.tnFvBDName}   bd1   Associated Bridge Domain not matching expected configuration		values=False
    # Verify Data-Plane Policer
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rsdppPol
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Data-Plane Policer not matching expected configuration		values=False

Checking ACI EPG for Faults - Tenant tenant1, App Profile app1, EPG epg1
    [Documentation]   Verifies ACI faults for EPG 'epg1' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG Name: epg1
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-epg
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${minor_count} minor faults (passing threshold 0)"

Verify ACI EPG Domain Configuration - Tenant tenant1, App Profile app1, EPG epg1, Domain baremetal
    [Documentation]   Verifies that ACI EPG Domain association for 'epg1' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG name: epg1
    ...  - Domain Name: baremetal
    ...  - Domain Type: physical
    ...  - Deployment Immediacy: immediate
    ...  - Resolution Immediacy: lazy
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rsdomAtt-[uni/phys-baremetal]
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=vmmSecP
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Domain not associated with EPG		values=False
	  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.tDn}"   "uni/phys-baremetal"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.instrImedcy}"  "immediate"               Deployment Immediacy not matching expected configuration                values=False

Verify ACI EPG Domain Configuration - Tenant tenant1, App Profile app1, EPG epg1, Domain baremetal2
    [Documentation]   Verifies that ACI EPG Domain association for 'epg1' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG name: epg1
    ...  - Domain Name: baremetal2
    ...  - Domain Type: physical
    ...  - Deployment Immediacy: immediate
    ...  - Resolution Immediacy: lazy
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rsdomAtt-[uni/phys-baremetal2]
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=vmmSecP
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Domain not associated with EPG		values=False
	  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.tDn}"   "uni/phys-baremetal2"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.instrImedcy}"  "immediate"               Deployment Immediacy not matching expected configuration                values=False

Verify ACI EPG Domain Configuration - Tenant tenant1, App Profile app1, EPG epg1, Domain vmware_aar2-lab
    [Documentation]   Verifies that ACI EPG Domain association for 'epg1' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG name: epg1
    ...  - Domain Name: vmware_aar2-lab
    ...  - Domain Type: vmm_vmware
    ...  - Deployment Immediacy: lazy
    ...  - Resolution Immediacy: immediate
    ...  - DVS Switching Mode: native
    ...  - DVS Netflow Preference: disabled
    ...  - DVS Static Encapsulation: unknown
    ...  - DVS Allow Promiscuous: reject
    ...  - DVS Forge Transmits: reject
    ...  - DVS Mac Changes: reject
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rsdomAtt-[uni/vmmp-VMware/dom-vmware_aar2-lab]
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=vmmSecP
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Domain not associated with EPG		values=False
	  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.tDn}"   "uni/vmmp-VMware/dom-vmware_aar2-lab"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.instrImedcy}"  "lazy"               Deployment Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.resImedcy}"  "immediate"                    Resolution Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.switchingMode}"  "native"                                 DVS switching mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.netflowPref}"  "disabled"                DVS netflow preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.encap}"  "unknown"                 DVS static encapsulation not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.allowPromiscuous}"  "reject"          DVS allow promiscuous not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.forgedTransmits}"  "reject"           DVS forged transmits not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.macChanges}"  "reject"                DVS mac changes not matching expected configuration                values=False

Verify ACI EPG Binding Configuration - Tenant tenant1, App Profile app1, EPG epg1, Node 201, Interface eth1/1
    [Documentation]   Verifies that ACI EPG Binding for 'epg1' are configured under tenant 'tenant1' are configured with the expected parameters
    ...  with the parameters defined in the NIP
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG Name: epg1
    ...  - POD ID: 1
	...  - Node: 201
 	...  - Interface: eth1/1
	...  - Encapsulation: vlan-100
    ...  - Deployment Immediacy: lazy
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rspathAtt-[topology/pod-1/paths-201/pathep-[eth1/1]]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Interface not having a static binding for the EPG		values=False
	Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.tDn}"   "topology/pod-1/paths-201/pathep-[eth1/1]"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.mode}"  "regular"               Binding Mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.instrImedcy}"  "lazy"               Deployment Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.encap}"  "vlan-100"               VLAN Encapsulation not matching expected configuration                values=False

Verify ACI EPG Binding Configuration - Tenant tenant1, App Profile app1, EPG epg1, Interface Policy Group vPC_Port
    [Documentation]   Verifies that ACI EPG Binding for 'epg1' are configured under tenant 'tenant1' are configured with the expected parameters
    ...  with the parameters defined in the NIP
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG Name: epg1
    ...  - POD ID: 1
    ...  - Node (left): 201
    ...  - Node (right): 202
	...  - Interface Policy Group: vPC_Port
	...  - Encapsulation: vlan-101
    ...  - Deployment Immediacy: lazy
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[vPC_Port]]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Interface not having a static binding for the EPG		values=False
	Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.tDn}"   "topology/pod-1/protpaths-201-202/pathep-[vPC_Port]"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.mode}"  "regular"               Binding Mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.instrImedcy}"  "lazy"               Deployment Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.encap}"  "vlan-101"               VLAN Encapsulation not matching expected configuration                values=False

Verify ACI Contract Filter Configuration - Tenant tenant1, Filter any
    [Documentation]   Verifies that ACI Contract Filter 'any' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Name: any
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-any
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.name}"   "any"    Failure retreiving configuration    values=False

Verify ACI Contract Filter Configuration - Tenant tenant1, Filter udp
    [Documentation]   Verifies that ACI Contract Filter 'udp' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Name: udp
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-udp
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.name}"   "udp"    Failure retreiving configuration    values=False

Checking ACI Contract Filter for Faults - Tenant tenant1, Filter any
    [Documentation]   Verifies ACI faults for Contract Filter 'any' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - Filter Name: any
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-any/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${minor_count} minor faults (passing threshold 0)"

Checking ACI Contract Filter for Faults - Tenant tenant1, Filter udp
    [Documentation]   Verifies ACI faults for Contract Filter 'udp' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - Filter Name: udp
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-udp/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${minor_count} minor faults (passing threshold 0)"

Verify ACI Contract Filter Entry Configuration - Tenant tenant1, Filter any, Entry any_ent
    [Documentation]   Verifies that ACI Contract Filter Entry 'any_ent' are configured under tenant 'tenant1', Filter 'any' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Filter Name: any
    ...  - Filter Entry Name: any_ent
    ...  - Ether Type: ip
	...  - IP Protocol: unspecified
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-any/e-any_ent
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter Entry does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.name}"   "any_ent"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.etherT}"  "ip"                    Ether Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "unspecified"                     IP Protocol not matching expected configuration                 values=False

Verify ACI Contract Filter Entry Configuration - Tenant tenant1, Filter any, Entry tcp_ent
    [Documentation]   Verifies that ACI Contract Filter Entry 'tcp_ent' are configured under tenant 'tenant1', Filter 'any' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Filter Name: any
    ...  - Filter Entry Name: tcp_ent
    ...  - Ether Type: ip
	...  - IP Protocol: tcp
	...  - Source Port (from): unspecified
	...  - Source Port (to): unspecified
	...  - Destination Port (from): 80
    ...  - Destination Port (to): 81
    ...  - TCP Flags:
    ...  - Apply to Fragments: no
    ...  - Stateful: no
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-any/e-tcp_ent
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter Entry does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.name}"   "tcp_ent"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.etherT}"  "ip"                    Ether Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "tcp"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sFromPort}"  "unspecified"                     Start Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sToPort}"  "unspecified"                         End Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dFromPort}"  "http"                Start Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "81"                    End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.tcpRules}"  ""                   TCP Flags not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "no"     Match Only Fragments not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.stateful}"  "no"                    Stateful not matching expected configuration                 values=False

Verify ACI Contract Filter Entry Configuration - Tenant tenant1, Filter udp, Entry udp_ent
    [Documentation]   Verifies that ACI Contract Filter Entry 'udp_ent' are configured under tenant 'tenant1', Filter 'udp' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Filter Name: udp
    ...  - Filter Entry Name: udp_ent
    ...  - Ether Type: ip
	...  - IP Protocol: udp
	...  - Source Port (from): unspecified
	...  - Source Port (to): unspecified
	...  - Destination Port (from): 123
    ...  - Destination Port (to): 123
    ...  - Apply to Fragments: no
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-udp/e-udp_ent
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter Entry does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.name}"   "udp_ent"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.etherT}"  "ip"                    Ether Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "udp"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sFromPort}"  "unspecified"                     Start Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sToPort}"  "unspecified"                         End Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dFromPort}"  "123"                Start Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "123"                    End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "no"     Match Only Fragments not matching expected configuration                 values=False

Checking ACI Contract Filter Entry for Faults - Tenant tenant1, Filter any, Entry any_ent
    [Documentation]   Verifies ACI faults for Contract Filter Entry 'any_ent' under tenant 'tenant1', filter 'any'
    ...  - Tenant Name: tenant1
    ...  - Filter Name: any
    ...  - Filter Entry Name: any_ent
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-any/e-any_ent/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${minor_count} minor faults (passing threshold 0)"

Checking ACI Contract Filter Entry for Faults - Tenant tenant1, Filter any, Entry tcp_ent
    [Documentation]   Verifies ACI faults for Contract Filter Entry 'tcp_ent' under tenant 'tenant1', filter 'any'
    ...  - Tenant Name: tenant1
    ...  - Filter Name: any
    ...  - Filter Entry Name: tcp_ent
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-any/e-tcp_ent/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${minor_count} minor faults (passing threshold 0)"

Checking ACI Contract Filter Entry for Faults - Tenant tenant1, Filter udp, Entry udp_ent
    [Documentation]   Verifies ACI faults for Contract Filter Entry 'udp_ent' under tenant 'tenant1', filter 'udp'
    ...  - Tenant Name: tenant1
    ...  - Filter Name: udp
    ...  - Filter Entry Name: udp_ent
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/flt-udp/e-udp_ent/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${minor_count} minor faults (passing threshold 0)"

Verify ACI Contract Configuration - Tenant tenant1, Contract permit_any
    [Documentation]   Verifies that ACI Contract 'permit_any' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Contract Name: permit_any
    ...  - Name Alias:
    ...  - Scope: context
    ...  - Priority / QoS Class: unspecified
    ...  - Target DSCP: unspecified
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
	# Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/brc-permit_any
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.name}"   "permit_any"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.nameAlias}"  ""                 Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.scope}"  "context"                          Scope not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.prio}"  "unspecified"                       Priority / QoS Class not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.targetDscp}"  "unspecified"               Target DSCP not matching expected configuration                values=False

Checking ACI Contract for Faults - Tenant tenant1, Contract permit_any
    [Documentation]   Verifies ACI faults for Contract 'permit_any' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - Contract Name: permit_any
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/brc-permit_any/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Contract has ${minor_count} minor faults (passing threshold 0)"

Verify ACI Contract Subject Configuration Tenant tenant1, Contract permit_any, Subject any_subj, Filter any
    [Documentation]   Verifies that ACI Contract Subject 'any_subj' under tenant 'tenant1', contract 'permit_any' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Contract Name: permit_any
    ...  - Subject Name: any_subj
    ...  - Name Alias:
    ...  - Priority / QoS Class: unspecified
    ...  - Apply Both Directions: yes
    ...  - Reverse Filter Ports: yes
    ...  - Target DSCP: unspecified
    ...  - Associated Filter: any
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/brc-permit_any/subj-any_subj
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract Subject does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.name}"   "any_subj"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.nameAlias}"  ""                 Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.prio}"  "unspecified"                       Priority / QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.revFltPorts}"  "yes"      Reverse Filter Ports not matching expected configuration                 values=False
    # Verify associated filter
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/brc-permit_any/subj-any_subj/rssubjFiltAtt-any
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Filter not associated with Contract Subject		values=False

Verify ACI Contract Subject Configuration Tenant tenant1, Contract permit_any, Subject any_subj, Filter udp
    [Documentation]   Verifies that ACI Contract Subject 'any_subj' under tenant 'tenant1', contract 'permit_any' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Contract Name: permit_any
    ...  - Subject Name: any_subj
    ...  - Name Alias:
    ...  - Priority / QoS Class: unspecified
    ...  - Apply Both Directions: yes
    ...  - Reverse Filter Ports: yes
    ...  - Target DSCP: unspecified
    ...  - Associated Filter: udp
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/brc-permit_any/subj-any_subj
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract Subject does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.name}"   "any_subj"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.nameAlias}"  ""                 Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.prio}"  "unspecified"                       Priority / QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.revFltPorts}"  "yes"      Reverse Filter Ports not matching expected configuration                 values=False
    # Verify associated filter
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/brc-permit_any/subj-any_subj/rssubjFiltAtt-udp
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Filter not associated with Contract Subject		values=False

Verify ACI EPG Contract Configuration - App Profile app1, EPG epg1, Contract permit_any
    [Documentation]   Verifies that ACI EPG Contract association for 'permit_any' are configured under tenant 'tenant1'are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - Application Profile Name: app1
    ...  - EPG Name: epg1
    ...  - Contract name: permit_any
    ...  - Consume Contract: yes
    ...  - Provide Contract: yes
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    # Retrieve Configuration (consume contract)
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rscons-permit_any
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure      Should Be Equal as Integers     ${return.totalCount}  1		Contract not consumed by EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings         "${return.payload[0].fvRsCons.attributes.tnVzBrCPName}"  "permit_any"               Consumed Contract not matching expected configuration                values=False
    # Retrieve Configuration (provide contract)
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/ap-app1/epg-epg1/rsprov-permit_any
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure      Should Be Equal as Integers     ${return.totalCount}  1		Contract not provided by EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings         "${return.payload[0].fvRsProv.attributes.tnVzBrCPName}"  "permit_any"               Provided Contract not matching expected configuration                values=False
