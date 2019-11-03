*** Settings ***
Library  RASTA
Resource  rasta.robot
Library  XML
Library  String
Library  Collections
Suite Setup   setup-test
Force Tags  aci

*** Variables ***
${testbed}  aci_tests_testbed.yaml
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
Verify ACI Fabric BGP Configuration - Route Reflector Node '101'
    [Documentation]   Verifies that ACI Fabric BGP Configuration are configured with the expected parameters
    ...  - Policy Name: default
    ...  - BGP AS Number: 65500
    ...  - BGP Route Reflector POD ID: 1
    ...  - BGP Route Reflector Node: 101
    [Tags]      aci-conf  aci-fabric  aci-fabric-bgp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/bgpInstP-default/as
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers		${return.payload[0].bgpAsP.attributes.asn}   65500    BGP AS Number not matching expected configuration               values=False
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/bgpInstP-default/rr/node-101
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP RR)		values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		                                                Node not defined as Fabric BGP Route Refelector		            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.payload[0].bgpRRNodePEp.attributes.podId}  1		        POD ID for Node not matching expected configuration		        values=False

Checking ACI Fabric BGP Configuration for Faults
    [Documentation]   Verifies ACI faults for Fabric BGP Configuration
    ...  - Policy Name: default
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-bgp
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/fabric/bgpInstP-default/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold 0)"

Verify ACI DNS Profile Configuration - Profile 'local', Domain Name 'cisco.com'
    [Documentation]   Verifies that ACI DNS Profile 'local' are configured with the expected parameters
    ...  - Profile Name: local
    ...  - Description: 
    ...  - Management EPG: oob
    ...  - Domain Name: cisco.com
    ...  - Default Domain Name: yes
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-local
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (DNS Profile)		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Profile not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProfile.attributes.epgDn}"   "uni/tn-mgmt/mgmtp-default/oob-default"       Management EPG not matching expected configuration              values=False
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-local/dom-cisco.com
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Domain Name)		values=False
	Should Be Equal as Integers     ${return.totalCount}  1            Domain Name not associated with DNS Profile	            values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].dnsDomain.attributes.isDefault}"  "yes"	Default Domain Name Setting not matching expected configuration		        values=False

Verify ACI DNS Profile Configuration - Profile 'local', DNS Server '1.1.1.1'
    [Documentation]   Verifies that ACI DNS Provider '1.1.1.1' under Profile 'local' are configured with the expected parameters
    ...  - DNS Profile Name: local
    ...  - DNS Server Name: dns1
    ...  - DNS Server Address: 1.1.1.1
    ...  - Preferred DNS Server: yes
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-local/prov-[1.1.1.1]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.preferred}"     "yes"       Preferred DNS Server Setting not matching expected configuration              values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.name}"          "dns1"        DNS Server Name not matching expected configuration                 values=False

Verify ACI DNS Profile Configuration - Profile 'local', DNS Server '1.1.1.2'
    [Documentation]   Verifies that ACI DNS Provider '1.1.1.2' under Profile 'local' are configured with the expected parameters
    ...  - DNS Profile Name: local
    ...  - DNS Server Name: dns2
    ...  - DNS Server Address: 1.1.1.2
    ...  - Preferred DNS Server: no
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-local/prov-[1.1.1.2]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.preferred}"     "no"       Preferred DNS Server Setting not matching expected configuration              values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.name}"          "dns2"        DNS Server Name not matching expected configuration                 values=False

Verify ACI Datetime Profile Configuration - Profile 'local'
    [Documentation]   Verifies that ACI Datetime Profile 'local' are configured with the expected parameters
    ...  - Profile Name: local
    ...  - Description: Test
    ...  - Admin State: enabled
    ...  - Authentication State: disabled
    ...  - Server State: enabled
    ...  - Master Mode: enabled
    ...  - Stratum Value: 3
    [Tags]      aci-conf  aci-fabric  aci-fabric-ntp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/time-local
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Datetime Profile not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.descr}"   "Test"                                            Description not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.adminSt}"   "enabled"                                          Admin State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.authSt}"   "disabled"                                  Authentication State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.serverState}"   "enabled"                                     Server State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.masterMode}"   "enabled"                                       Master Mode not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.StratumValue}"   "3"                                   Stratum Value not matching expected configuration                 values=False

Checking ACI Datetime Profile Configuration for Faults - Profile 'local'
    [Documentation]   Verifies ACI faults for Datetime Profile Configuration
    ...  - Profile Name: local
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-ntp
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/fabric/time-local/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold 0)"

Verify ACI Datetime NTP Provider Configuration - Provider '11.11.11.11'
    [Documentation]   Verifies that ACI NTP Provider '11.11.11.11' are configured with the expected parameters
    ...  - Datetime Profile Name: local
    ...  - NTP Provider: 11.11.11.11
    ...  - Minimum Poll Interval: 4
    ...  - Maximum Poll Interval: 6
    ...  - Preferred: yes
    ...  - Management EPG: oob
    [Tags]      aci-conf  aci-fabric  aci-fabric-ntp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/time-local/ntpprov-11.11.11.11
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		NTP Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.minPoll}"       "4"                                    Minimum Poll Interval not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.maxPoll}"       "6"                                    Maximum Poll Interval not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.preferred}"     "yes"                                Preferred setting not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.epgDn}"         "uni/tn-mgmt/mgmtp-default/oob-default"            Management EPG not matching expected configuration                 values=False

Checking ACI Datetime NTP Provider Configuration for Faults - Provider '11.11.11.11'
    [Documentation]   Verifies ACI faults for Datetime Profile Configuration
    ...  - Datetime Profile Name: local
    ...  - NTP Provider: 11.11.11.11
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-ntp
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/fabric/time-local/ntpprov-11.11.11.11/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold 0)"

Verify ACI VLAN Pool Configuration - VLAN Pool baremetal
    [Documentation]   Verifies that VLAN Pool 'baremetal' are configured with the expected parameters:
    ...  - VLAN Pool Name: baremetal
    ...  - Allocation Mode: static
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[baremetal]-static
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvnsVlanInstP.attributes.name}   baremetal                Failure retreiving configuration        values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvnsVlanInstP.attributes.allocMode}   static     Allocation mode not matching expected configuration                values=False        values=False

Verify ACI VLAN Pool Configuration - VLAN Pool dyn-pool
    [Documentation]   Verifies that VLAN Pool 'dyn-pool' are configured with the expected parameters:
    ...  - VLAN Pool Name: dyn-pool
    ...  - Allocation Mode: dynamic
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[dyn-pool]-dynamic
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvnsVlanInstP.attributes.name}   dyn-pool                Failure retreiving configuration        values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvnsVlanInstP.attributes.allocMode}   dynamic     Allocation mode not matching expected configuration                values=False        values=False

Checking ACI VLAN Pool for Faults - VLAN Pool baremetal
    [Documentation]   Verifies ACI faults for VLAN Pool 'baremetal'
    ...  - VLAN Pool Name: 
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
    [Tags]      aci-faults  aci-fabric  aci-fabric-vlan-pool
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[baremetal]-static/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${minor_count} minor faults (passing threshold 1)"

Checking ACI VLAN Pool for Faults - VLAN Pool dyn-pool
    [Documentation]   Verifies ACI faults for VLAN Pool 'dyn-pool'
    ...  - VLAN Pool Name: 
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
    [Tags]      aci-faults  aci-fabric  aci-fabric-vlan-pool
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[dyn-pool]-dynamic/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${minor_count} minor faults (passing threshold 1)"

Verify ACI VLAN Pool Encap Block Configuration - VLAN Pool baremetal, Encapsulation Block 'VLAN 100-200
    [Documentation]   Verifies that VLAN Encapsulation Block 'VLAN 100-200 are configured with the expected parameters:
    ...  - VLAN Pool Name: baremetal
    ...  - VLAN Pool Allocation Mode: static
	...  - Encapsulation Block Mode: inherit
    ...  - Encapsulation Block Role: external
    ...  - Encapsulation Block Start: vlan-100
    ...  - Encapsulation Block Stop: vlan-200
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[baremetal]-static/from-[vlan-100]-to-[vlan-200]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "xml"
    Should Be Equal as Integers     @{return}[0]    200		Failure executing API call		values=False
    ${xml_root} =  Parse XML  @{return}[1]
    Should Be Equal  ${xml_root.tag}  imdata    Failure retreiving configuration        values=False
    # Verify Configuration Parameters
	Element Attribute Should Be  ${xml_root}  totalCount  1
    Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  allocMode  inherit      xpath=fvnsEncapBlk      message=Block Allocation Mode not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  from   vlan-100     xpath=fvnsEncapBlk      message=Start VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  to   vlan-200        xpath=fvnsEncapBlk      message=Stop VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  role   external                xpath=fvnsEncapBlk      message=Block Role not matching expected configuration

Verify ACI VLAN Pool Encap Block Configuration - VLAN Pool baremetal, Encapsulation Block 'VLAN 300-400
    [Documentation]   Verifies that VLAN Encapsulation Block 'VLAN 300-400 are configured with the expected parameters:
    ...  - VLAN Pool Name: baremetal
    ...  - VLAN Pool Allocation Mode: static
	...  - Encapsulation Block Mode: inherit
    ...  - Encapsulation Block Role: external
    ...  - Encapsulation Block Start: vlan-300
    ...  - Encapsulation Block Stop: vlan-400
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[baremetal]-static/from-[vlan-300]-to-[vlan-400]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "xml"
    Should Be Equal as Integers     @{return}[0]    200		Failure executing API call		values=False
    ${xml_root} =  Parse XML  @{return}[1]
    Should Be Equal  ${xml_root.tag}  imdata    Failure retreiving configuration        values=False
    # Verify Configuration Parameters
	Element Attribute Should Be  ${xml_root}  totalCount  1
    Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  allocMode  inherit      xpath=fvnsEncapBlk      message=Block Allocation Mode not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  from   vlan-300     xpath=fvnsEncapBlk      message=Start VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  to   vlan-400        xpath=fvnsEncapBlk      message=Stop VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  role   external                xpath=fvnsEncapBlk      message=Block Role not matching expected configuration

Verify ACI VLAN Pool Encap Block Configuration - VLAN Pool dyn-pool, Encapsulation Block 'VLAN 10-30
    [Documentation]   Verifies that VLAN Encapsulation Block 'VLAN 10-30 are configured with the expected parameters:
    ...  - VLAN Pool Name: dyn-pool
    ...  - VLAN Pool Allocation Mode: dynamic
	...  - Encapsulation Block Mode: inherit
    ...  - Encapsulation Block Role: external
    ...  - Encapsulation Block Start: vlan-10
    ...  - Encapsulation Block Stop: vlan-30
    [Tags]      aci-conf  aci-fabric  aci-fabric-vlan-pool
    # Retrieve VLAN Pool
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[dyn-pool]-dynamic/from-[vlan-10]-to-[vlan-30]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "xml"
    Should Be Equal as Integers     @{return}[0]    200		Failure executing API call		values=False
    ${xml_root} =  Parse XML  @{return}[1]
    Should Be Equal  ${xml_root.tag}  imdata    Failure retreiving configuration        values=False
    # Verify Configuration Parameters
	Element Attribute Should Be  ${xml_root}  totalCount  1
    Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  allocMode  inherit      xpath=fvnsEncapBlk      message=Block Allocation Mode not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  from   vlan-10     xpath=fvnsEncapBlk      message=Start VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  to   vlan-30        xpath=fvnsEncapBlk      message=Stop VLAN not matching expected configuration
	Run keyword And Continue on Failure  Element Attribute Should Be  ${xml_root}  role   external                xpath=fvnsEncapBlk      message=Block Role not matching expected configuration

 
Verify ACI Physical Domain Configuration - Domain baremetal, VLAN Pool baremetal
    [Documentation]   Verifies that Physical Domain 'baremetal' are configured with the expected parameters:
	...  - Domain Name: baremetal
	...  - Associated VLAN Pool: baremetal
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/phys-baremetal
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].physDomP.attributes.name}   baremetal   Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].physDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool 'baremetal' not associated with domain

 
Verify ACI Physical Domain Configuration - Domain baremetal2, VLAN Pool baremetal
    [Documentation]   Verifies that Physical Domain 'baremetal2' are configured with the expected parameters:
	...  - Domain Name: baremetal2
	...  - Associated VLAN Pool: baremetal
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/phys-baremetal2
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].physDomP.attributes.name}   baremetal2   Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].physDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool 'baremetal' not associated with domain

 
Verify ACI Physical Domain Configuration - Domain baremetal3, VLAN Pool dyn-pool
    [Documentation]   Verifies that Physical Domain 'baremetal3' are configured with the expected parameters:
	...  - Domain Name: baremetal3
	...  - Associated VLAN Pool: dyn-pool
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/phys-baremetal3
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].physDomP.attributes.name}   baremetal3   Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].physDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[dyn-pool]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[dyn-pool]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool 'dyn-pool' not associated with domain

Verify ACI L3 External Domain Configuration - Domain l3out_dom, VLAN Pool baremetal
    [Documentation]   Verifies that L3 External Domain 'l3out_dom' are configured with the expected parameters
	...  - Domain Name: l3out_dom
	...  - Associated VLAN Pool: baremetal
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/l3dom-l3out_dom
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings		${return.payload[0].l3extDomP.attributes.name}   l3out_dom     Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].l3extDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool 'baremetal' not associated with domain

Verify ACI L2 External Domain Configuration - Domain l2out_dom, VLAN Pool baremetal
    [Documentation]   Verifies that L2 External Domain 'l2out_dom' are configured with the expected parameters
	...  - Domain Name: l2out_dom
	...  - Associated VLAN Pool: baremetal
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/l2dom-l2out_dom
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].l2extDomP.attributes.name}   l2out_dom  Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].l2extDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[baremetal]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool 'baremetal' not associated with domain

Verify ACI VMware VMM Domain VLAN Pool Configuration - Domain vmware_aar2-lab, VLAN Pool dyn-pool
    [Documentation]   Verifies that VMware VMM Domain 'vmware_aar2-lab' are configured with the expected parameters
	...  - Domain Name: vmware_aar2-lab
	...  - Associated VLAN Pool: dyn-pool
    [Tags]      aci-conf  aci-fabric  aci-fabric-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/vmmp-VMware/dom-vmware_aar2-lab
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsVlanNs
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings     ${return.payload[0].vmmDomP.attributes.name}   vmware_aar2-lab  Failure retreiving configuration		values=False
    # Iterate through associated VLAN pools to find a match
	: FOR  ${vlan_pool}  IN   @{return.payload[0].vmmDomP.children}
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[dyn-pool]-static"   Static VLAN Pool associated with domain
    \  Pass Execution If  "${vlan_pool.infraRsVlanNs.attributes.tDn}" == "uni/infra/vlanns-[dyn-pool]-dynamic"  Dynamic VLAN Pool associated with domain
    # No match found, fail test case
    Fail  VLAN Pool 'dyn-pool' not associated with domain

 
Checking ACI Physical Domain for Faults - Domain baremetal
    [Documentation]   Verifies ACI faults for Physical Domain 'baremetal'
	...  - Domain Name: baremetal
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/phys-baremetal/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold 0)"

 
Checking ACI Physical Domain for Faults - Domain baremetal2
    [Documentation]   Verifies ACI faults for Physical Domain 'baremetal2'
	...  - Domain Name: baremetal2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/phys-baremetal2/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold 0)"

 
Checking ACI Physical Domain for Faults - Domain baremetal3
    [Documentation]   Verifies ACI faults for Physical Domain 'baremetal3'
	...  - Domain Name: baremetal3
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/phys-baremetal3/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold 0)"

Checking ACI L3 External Domain for Faults - Domain l3out_dom
    [Documentation]   Verifies ACI faults for L3 External Domain 'l3out_dom'
	...  - Domain Name: l3out_dom
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/l3dom-l3out_dom/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold 0)"

Checking ACI L2 External Domain for Faults - Domain l2out_dom
    [Documentation]   Verifies ACI faults for L2 External Domain 'l2out_dom'
	...  - Domain Name: l2out_dom
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/l2dom-l2out_dom/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold 0)"

Checking ACI VMware VMM VLAN Pool Association for Faults - Domain vmware_aar2-lab
    [Documentation]   Verifies ACI faults for VMware VMM Domain 'vmware_aar2-lab'
	...  - Domain Name: vmware_aar2-lab
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 2
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/vmmp-VMware/dom-vmware_aar2-lab/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold 2)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold 0)"

Verify ACI VMware VMM Domain Configuration - Domain vmware_aar2-lab
    [Documentation]   Verifies that ACI VMM Domain 'vmware_aar2-lab' are configured with the expected parameters
    ...  - VMM Domain Name:  vmware_aar2-lab
	...  - VMM Switch Type:  default
    ...  - vCenter Datacenter: aar2-lab
    ...  - vCenter Controller Name: aar2-lab-vcenter1
    ...  - vCenter Hostname/IP: 10.49.96.50
    ...  - vCenter Credential Profile Name: aar2-lab-vcenter1
    ...  - vCenter Username: administrator@vsphere.local
    [Tags]      aci-conf  aci-vmm  aci-vmm-vmware
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/vmmp-VMware/dom-vmware_aar2-lab
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		VMM Domain does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].vmmDomP.attributes.name}   vmware_aar2-lab        Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].vmmDomP.attributes.mode}"   "default"      vSwitch Mode not matching expected configuration                 values=False
	# Credential Profile Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-vmware_aar2-lab
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmUsrAccP&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmUsrAccP.name, "aar2-lab-vcenter1")
	${credential}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${credential.status}		200		Failure executing API call			values=False
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${credential.totalCount}	1		Credential Profile 'aar2-lab-vcenter1' not associated with VMM Domain	values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${credential.payload[0].vmmDomP.children[0].vmmUsrAccP.attributes.usr}	administrator@vsphere.local	    vCenter Username not matching expected configuration    values=False
	# vCenter Profile
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-vmware_aar2-lab/ctrlr-aar2-lab-vcenter1
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsAcc
	${vcenter}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${vcenter.status}		200		Failure executing API call			values=False
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${vcenter.totalCount}	1		vCenter Profile 'aar2-lab-vcenter1' not associated with VMM Domain	values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.attributes.hostOrIp}		10.49.96.50	        vCenter Hostname/IP not matching expected configuration    values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.attributes.rootContName}		aar2-lab	vCenter Datacenter not matching expected configuration    values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.children[0].vmmRsAcc.attributes.tDn}		uni/vmmp-VMware/dom-vmware_aar2-lab/usracc-aar2-lab-vcenter1	vCenter Credential Profile not matching expected configuration    values=False

Checking VMware VMM Domain for Faults - Domain vmware_aar2-lab
    [Documentation]   Verifies ACI faults for VMware VMM Domain 'vmware_aar2-lab'
    ...  - VMM Domain Name:  vmware_aar2-lab
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 1
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-vmm  aci-vmm-vmware
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/vmmp-VMware/dom-vmware_aar2-lab/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${major_count} major faults (passing threshold 1)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${minor_count} minor faults (passing threshold 0)"

Verify ACI AAEP Configuration - AAEP baremetal
    [Documentation]   Verifies that AAEP 'baremetal' are configured with the expected parameters:
	...  - AAEP Name: baremetal
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-baremetal
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsFuncToEpg
    ${return}  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraAttEntityP.attributes.name}   baremetal                            Failure retreiving configuration		                          values=False
	Variable Should Not Exist  ${return.payload[0].infraAttEntityP.children}   Infrastructure VLAN enabled, which are not matching expected configuration

Verify ACI AAEP Configuration - AAEP baremetal2
    [Documentation]   Verifies that AAEP 'baremetal2' are configured with the expected parameters:
	...  - AAEP Name: baremetal2
	...  - Enable Infrastructure VLAN: yes
	...  - Infrastructure VLAN: 4
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-baremetal2
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsFuncToEpg
    ${return}  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraAttEntityP.attributes.name}   baremetal2                            Failure retreiving configuration		                          values=False
	# Check Infra VLAN
	Variable Should Exist  ${return.payload[0].infraAttEntityP.children}   Infrastructure VLAN not enabled, which are not matching expected configuration
	Should Be Equal as Strings  ${return.payload[0].infraAttEntityP.children[0].infraProvAcc.children[0].infraRsFuncToEpg.attributes.encap}  vlan-4	Infrastructure VLAN not matching expected configuration			values=False

Checking ACI AAEP for Faults - AAEP baremetal
    [Documentation]   Verifies ACI faults for AAEP 'baremetal'
	...  - AAEP Name: baremetal
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-aaep
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/attentp-baremetal/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${minor_count} minor faults (passing threshold 0)"

Checking ACI AAEP for Faults - AAEP baremetal2
    [Documentation]   Verifies ACI faults for AAEP 'baremetal2'
	...  - AAEP Name: baremetal2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-aaep
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/attentp-baremetal2/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${minor_count} minor faults (passing threshold 0)"

Verify ACI AAEP Domain Association Configuration - AAEP baremetal, Domain baremetal
    [Documentation]   Verifies that AAEP 'baremetal' domain association are configured with the expected parameters:
	...  - AAEP Name: baremetal
	...  - Domain Name: baremetal
	...  - Domain Type: physical
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Define tDn
	${tDn} =  Set Variable  uni/phys-baremetal
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-baremetal/rsdomP-[${tDn}]
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Domain association not matching expected configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraRsDomP.attributes.tDn}   ${tDn}	tDn not matching expected configuration        values=False

Verify ACI AAEP Domain Association Configuration - AAEP baremetal, Domain l3out_dom
    [Documentation]   Verifies that AAEP 'baremetal' domain association are configured with the expected parameters:
	...  - AAEP Name: baremetal
	...  - Domain Name: l3out_dom
	...  - Domain Type: external_l3
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Define tDn
	${tDn} =  Set Variable  uni/l3dom-l3out_dom
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-baremetal/rsdomP-[${tDn}]
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Domain association not matching expected configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraRsDomP.attributes.tDn}   ${tDn}	tDn not matching expected configuration        values=False

Verify ACI AAEP Domain Association Configuration - AAEP baremetal2, Domain baremetal2
    [Documentation]   Verifies that AAEP 'baremetal2' domain association are configured with the expected parameters:
	...  - AAEP Name: baremetal2
	...  - Domain Name: baremetal2
	...  - Domain Type: physical
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Define tDn
	${tDn} =  Set Variable  uni/phys-baremetal2
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-baremetal2/rsdomP-[${tDn}]
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Domain association not matching expected configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraRsDomP.attributes.tDn}   ${tDn}	tDn not matching expected configuration        values=False

Verify ACI AAEP Domain Association Configuration - AAEP baremetal2, Domain l3out_dom
    [Documentation]   Verifies that AAEP 'baremetal2' domain association are configured with the expected parameters:
	...  - AAEP Name: baremetal2
	...  - Domain Name: l3out_dom
	...  - Domain Type: external_l3
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Define tDn
	${tDn} =  Set Variable  uni/l3dom-l3out_dom
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-baremetal2/rsdomP-[${tDn}]
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Domain association not matching expected configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraRsDomP.attributes.tDn}   ${tDn}	tDn not matching expected configuration        values=False

Verify ACI vPC Domain Configuration - Domain Leaf1_2
    [Documentation]   Verifies that vPC Domain (or vPC Explicit Protection Group) 'Leaf1_2' are configured with the expected parameters
    ...  - vPC Domain Name:  Leaf1_2
    ...  - Logical Pair ID: 1
    ...  - Left Node ID: 201
    ...  - Right Node ID: 202
    [Tags]      aci-conf  aci-fabric  aci-fabric-vpc-domain
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/fabric/protpol/expgep-Leaf1_2
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=fabricNodePEp
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		vPC Domain does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].fabricExplicitGEp.attributes.name}   Leaf1_2      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricExplicitGEp.attributes.id}		1           Logical Pair ID not matching expected configuration                 values=False
    # Iterate through the fabric nodes
    Set Test Variable  ${left_node_found}		"Node not found"
    Set Test Variable  ${right_node_found}		"Node not found"
    : FOR  ${node}  IN  @{return.payload[0].fabricExplicitGEp.children}
	\  run keyword if  "${node.fabricNodePEp.attributes.id}" == "201"  run keyword
	\  ...  Set Test Variable  ${left_node_found}  "Node found"
	\  run keyword if  "${node.fabricNodePEp.attributes.id}" == "202"  run keyword
	\  ...  Set Test Variable  ${right_node_found}  "Node found"
	run keyword if  not ${left_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Fabric Node '201' not associated with vPC Domain
	run keyword if  not ${right_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Fabric Node '202' not associated with vPC Domain

Checking ACI vPC Domain for Faults - Domain Leaf1_2
    [Documentation]   Verifies ACI faults for vPC Domain (or vPC Explicit Protection Group) 'Leaf1_2'
    ...  - vPC Domain Name:  Leaf1_2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-vpc-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/fabric/protpol/expgep-Leaf1_2/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold 0)"

Verify ACI Leaf Switch Profile Configuration - Profile Leaf1_2, Switch Selector Leaf, Node block 201-202
    [Documentation]   Verifies that Leaf Switch Profile 'Leaf1_2' are configured with the expected parameters
    ...  - Profile Name:  Leaf1_2
    ...  - Switch Selector: Leaf
    ...  - Node ID (from): 201
    ...  - Node ID (to): 202
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-Leaf1_2
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].infraNodeP.attributes.name}   Leaf1_2     Failure retreiving configuration    values=False
    # Retrieve switch selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-Leaf1_2/leaves-Leaf-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraNodeBlk
	${sw_selector}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.status}		200		                                                    Failure executing API call			                            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.totalCount}    	1		                                                Switch Selector does not exist	                                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${sw_selector.payload[0].infraLeafS.attributes.name}   Leaf   Failure retreiving switch selector configuration	            values=False
    ${from_node_found} =  Set Variable  "Node not found"
    ${to_node_found} =  Set Variable  "Node not found"
    : FOR  ${block}  IN  @{sw_selector.payload[0].infraLeafS.children}
    \  ${from_node_found} =     Set Variable If   "${block.infraNodeBlk.attributes.from_}" == "201"      "Node found"
    \  ${to_node_found} =       Set Variable If   "${block.infraNodeBlk.attributes.to_}" == "202"          "Node found"
	run keyword if  not ${from_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (from) not matching expected configuration
	run keyword if  not ${to_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (to) not matching expected configuration

Verify ACI Spine Switch Profile Configuration - Profile Spine, Switch Selector spine_sel, Node block 101-101
    [Documentation]   Verifies that Spine Switch Profile 'Spine' are configured with the expected parameters
    ...  - Profile Name:  Spine
    ...  - Description: Test
    ...  - Switch Selector: spine_sel
    ...  - From Node ID: 101
    ...  - To Node ID: 101
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-Spine
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpineP.attributes.name}   Spine    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].infraSpineP.attributes.descr}"   "Test"       Description not matching expected configuration                  values=False
    # Retrieve switch selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-Spine/spines-spine_sel-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraNodeBlk
	${sw_selector}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.status}		200                                                         Failure executing API call			                            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.totalCount}    	1		                                                Switch Selector does not exist	                                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${sw_selector.payload[0].infraSpineS.attributes.name}   spine_sel  Failure retreiving switch selector configuration	            values=False
    ${from_node_found} =  Set Variable  "Node not found"
    ${to_node_found} =  Set Variable  "Node not found"
    : FOR  ${block}  IN  @{sw_selector.payload[0].infraSpineS.children}
    \  ${from_node_found} =     Set Variable If   "${block.infraNodeBlk.attributes.from_}" == "101"      "Node found"
    \  ${to_node_found} =       Set Variable If   "${block.infraNodeBlk.attributes.to_}" == "101"          "Node found"
	run keyword if  not ${from_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (from) not matching expected configuration
	run keyword if  not ${to_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (to) not matching expected configuration

Checking ACI Leaf Switch Profile for Faults - Profile Leaf1_2
    [Documentation]   Verifies ACI faults for Leaf Switch Profile 'Leaf1_2'
    ...  - Profile Name:  Leaf1_2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 2
    [Tags]      aci-faults  aci-fabric  aci-fabric-switch-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/nprof-Leaf1_2/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${minor_count} minor faults (passing threshold 2)"

Checking ACI Spine Switch Profile for Faults - Profile Spine
    [Documentation]   Verifies ACI faults for Spine Switch Profile 'Spine'
    ...  - Profile Name:  Spine
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 2
    [Tags]      aci-faults  aci-fabric  aci-fabric-switch-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/spprof-Spine/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${minor_count} minor faults (passing threshold 2)"

Verify ACI CDP Interface Policy Configuration - Policy Name cdp_enabled
    [Documentation]   Verifies that CDP Interface Policy 'cdp_enabled' are configured with the expected parameters
    ...  - Interface Policy Name: cdp_enabled
	...  - Description: 
	...  - Admin State: enabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/cdpIfP-cdp_enabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.name}		cdp_enabled     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.adminSt}	enabled     Admin State not matching expected configuration                   values=False

Verify ACI CDP Interface Policy Configuration - Policy Name cdp_disabled
    [Documentation]   Verifies that CDP Interface Policy 'cdp_disabled' are configured with the expected parameters
    ...  - Interface Policy Name: cdp_disabled
	...  - Description: 
	...  - Admin State: disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/cdpIfP-cdp_disabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.name}		cdp_disabled     Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].cdpIfPol.attributes.adminSt}	disabled     Admin State not matching expected configuration                   values=False

Verify ACI L2 Interface Policy Configuration - Policy Name global_vlan_scope
    [Documentation]   Verifies that L2 Interface Policy 'global_vlan_scope' are configured with the expected parameters
    ...  - Interface Policy Name: global_vlan_scope
	...  - VLAN Scope: global
	...  - QinQ: disabled
	...  - Reflective Relay: disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/l2IfP-global_vlan_scope
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.name}			global_vlan_scope    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vlanScope}	global   VLAN Scope not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.qinq}		disabled   	   QinQ not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vepa}		disabled   Reflective Relay not matching expected configuration                   values=False

Verify ACI L2 Interface Policy Configuration - Policy Name portlocal_vlan_scope
    [Documentation]   Verifies that L2 Interface Policy 'portlocal_vlan_scope' are configured with the expected parameters
    ...  - Interface Policy Name: portlocal_vlan_scope
	...  - VLAN Scope: portlocal
	...  - QinQ: disabled
	...  - Reflective Relay: disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/l2IfP-portlocal_vlan_scope
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.name}			portlocal_vlan_scope    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vlanScope}	portlocal   VLAN Scope not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.qinq}		disabled   	   QinQ not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2IfPol.attributes.vepa}		disabled   Reflective Relay not matching expected configuration                   values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 40gig_auto
    [Documentation]   Verifies that Link Level Channel Interface Policy '40gig_auto' are configured with the expected parameters
    ...  - Interface Policy Name: 40gig_auto
	...  - Speed: 40G
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
	...  - FEC Mode: inherit
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-40gig_auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	40gig_auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			40G         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		inherit         	FEC Mode not matching expected configuration            	values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 10gig_auto
    [Documentation]   Verifies that Link Level Channel Interface Policy '10gig_auto' are configured with the expected parameters
    ...  - Interface Policy Name: 10gig_auto
	...  - Speed: 10G
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
	...  - FEC Mode: inherit
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-10gig_auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	10gig_auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			10G         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		inherit         	FEC Mode not matching expected configuration            	values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 1gig_auto
    [Documentation]   Verifies that Link Level Channel Interface Policy '1gig_auto' are configured with the expected parameters
    ...  - Interface Policy Name: 1gig_auto
	...  - Speed: 1G
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
	...  - FEC Mode: inherit
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-1gig_auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	1gig_auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			1G         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		inherit         	FEC Mode not matching expected configuration            	values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 1gig_off
    [Documentation]   Verifies that Link Level Channel Interface Policy '1gig_off' are configured with the expected parameters
    ...  - Interface Policy Name: 1gig_off
	...  - Speed: 1G
	...  - Auto Negotiation: off
	...  - Link Debounce Interval: 100
	...  - FEC Mode: inherit
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-1gig_off
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	1gig_off      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			1G         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		off          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		inherit         	FEC Mode not matching expected configuration            	values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name 10gig_off
    [Documentation]   Verifies that Link Level Channel Interface Policy '10gig_off' are configured with the expected parameters
    ...  - Interface Policy Name: 10gig_off
	...  - Speed: 10G
	...  - Auto Negotiation: off
	...  - Link Debounce Interval: 100
	...  - FEC Mode: inherit
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-10gig_off
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	10gig_off      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			10G         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		off          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		inherit         	FEC Mode not matching expected configuration            	values=False

Verify ACI Link Level Interface Policy Configuration - Policy Name auto
    [Documentation]   Verifies that Link Level Channel Interface Policy 'auto' are configured with the expected parameters
    ...  - Interface Policy Name: auto
	...  - Speed: inherit
	...  - Auto Negotiation: on
	...  - Link Debounce Interval: 100
	...  - FEC Mode: inherit
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/hintfpol-auto
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.name}	auto      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.speed}			inherit         	Speed not matching expected configuration                   values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.autoNeg}		on          	AutoNeg not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.linkDebounce}	100         	Link Debounce not matching expected configuration           values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].fabricHIfPol.attributes.fecMode}		inherit         	FEC Mode not matching expected configuration            	values=False

Verify ACI LLDP Interface Policy Configuration - Policy Name lldp_enabled
    [Documentation]   Verifies that LLDP Interface Policy 'lldp_enabled' are configured with the expected parameters
    ...  - Interface Policy Name: lldp_enabled
	...  - Admin State (RX): enabled
	...  - Admin State (TX): enabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lldpIfP-lldp_enabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.name}		lldp_enabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminRxSt}     enabled     Admin RX State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminTxSt}     enabled     Admin TX State not matching expected configuration                 values=False
	

Verify ACI LLDP Interface Policy Configuration - Policy Name lldp_disabled
    [Documentation]   Verifies that LLDP Interface Policy 'lldp_disabled' are configured with the expected parameters
    ...  - Interface Policy Name: lldp_disabled
	...  - Admin State (RX): disabled
	...  - Admin State (TX): disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lldpIfP-lldp_disabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.name}		lldp_disabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminRxSt}     disabled     Admin RX State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lldpIfPol.attributes.adminTxSt}     disabled     Admin TX State not matching expected configuration                 values=False
	

Verify ACI MCP Interface Policy Configuration - Policy Name mcp_enabled
    [Documentation]   Verifies that LLDP Interface Policy 'mcp_enabled' are configured with the expected parameters
    ...  - Interface Policy Name: mcp_enabled	
	...  - MCP State: enabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/mcpIfP-mcp_enabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.name}		mcp_enabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.adminSt}     enabled     		Admin State not matching expected configuration                 values=False

Verify ACI MCP Interface Policy Configuration - Policy Name mcp_disabled
    [Documentation]   Verifies that LLDP Interface Policy 'mcp_disabled' are configured with the expected parameters
    ...  - Interface Policy Name: mcp_disabled	
	...  - MCP State: disabled
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/mcpIfP-mcp_disabled
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.name}		mcp_disabled    Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].mcpIfPol.attributes.adminSt}     disabled     		Admin State not matching expected configuration                 values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name lacp_active
    [Documentation]   Verifies that Port Channel Interface Policy 'lacp_active' are configured with the expected parameters
    ...  - Interface Policy Name: lacp_active
	...  - Port-Channel Mode (LACP): active
	...  - Fast Select Hot Standby: yes
	...  - Graceful Converge: yes
	...  - Load Defer: yes
	...  - Suspend Individual: yes
	...  - Symmetric Hash: yes
	...  - Hash Key: l4-src-port
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-lacp_active
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		lacp_active       Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		active                 Port Channel Mode (LACP) not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1               Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16               Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,load-defer,susp-individual,symmetric-hash    				  Control Kobs not matching expected configuration                   values=False
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-lacp_active/loadbalanceP
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
	Should Be Equal as Integers     ${return.totalCount}	1		Failure Retrieving Port Channel Hash configuration     values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2LoadBalancePol.attributes.hashFields}		l4-src-port                 Port Channel Hash Key not matching expected configuration                 values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name lacp_passive
    [Documentation]   Verifies that Port Channel Interface Policy 'lacp_passive' are configured with the expected parameters
    ...  - Interface Policy Name: lacp_passive
	...  - Port-Channel Mode (LACP): passive
	...  - Fast Select Hot Standby: yes
	...  - Graceful Converge: yes
	...  - Load Defer: yes
	...  - Suspend Individual: yes
	...  - Symmetric Hash: yes
	...  - Hash Key: l4-src-port
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-lacp_passive
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		lacp_passive       Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		passive                 Port Channel Mode (LACP) not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1               Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16               Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,load-defer,susp-individual,symmetric-hash    				  Control Kobs not matching expected configuration                   values=False
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-lacp_passive/loadbalanceP
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
	Should Be Equal as Integers     ${return.totalCount}	1		Failure Retrieving Port Channel Hash configuration     values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2LoadBalancePol.attributes.hashFields}		l4-src-port                 Port Channel Hash Key not matching expected configuration                 values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name static_on
    [Documentation]   Verifies that Port Channel Interface Policy 'static_on' are configured with the expected parameters
    ...  - Interface Policy Name: static_on
	...  - Port-Channel Mode (LACP): off
	...  - Fast Select Hot Standby: yes
	...  - Graceful Converge: yes
	...  - Load Defer: yes
	...  - Suspend Individual: yes
	...  - Symmetric Hash: yes
	...  - Hash Key: l4-src-port
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-static_on
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		static_on       Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		off                 Port Channel Mode (LACP) not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1               Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16               Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,load-defer,susp-individual,symmetric-hash    				  Control Kobs not matching expected configuration                   values=False
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-static_on/loadbalanceP
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
	Should Be Equal as Integers     ${return.totalCount}	1		Failure Retrieving Port Channel Hash configuration     values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2LoadBalancePol.attributes.hashFields}		l4-src-port                 Port Channel Hash Key not matching expected configuration                 values=False

Verify ACI Port Channel Interface Policy Configuration - Policy Name mac_pinning
    [Documentation]   Verifies that Port Channel Interface Policy 'mac_pinning' are configured with the expected parameters
    ...  - Interface Policy Name: mac_pinning
	...  - Port-Channel Mode (LACP): mac-pin
	...  - Fast Select Hot Standby: yes
	...  - Graceful Converge: yes
	...  - Load Defer: yes
	...  - Suspend Individual: yes
	...  - Symmetric Hash: yes
	...  - Hash Key: l4-src-port
	...  - Min Links: 1
	...  - Max Links: 16
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-mac_pinning
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		mac_pinning       Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		mac-pin                 Port Channel Mode (LACP) not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	1               Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	16               Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		fast-sel-hot-stdby,graceful-conv,load-defer,susp-individual,symmetric-hash    				  Control Kobs not matching expected configuration                   values=False
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-mac_pinning/loadbalanceP
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
	Should Be Equal as Integers     ${return.totalCount}	1		Failure Retrieving Port Channel Hash configuration     values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2LoadBalancePol.attributes.hashFields}		l4-src-port                 Port Channel Hash Key not matching expected configuration                 values=False

Verify ACI STP Interface Policy Configuration - Policy Name bpdu_guard
    [Documentation]   Verifies that STP Channel Interface Policy 'bpdu_guard' are configured with the expected parameters
    ...  - Interface Policy Name: bpdu_guard
	...  - STP Control: bpdu-guard
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-bpdu_guard
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		bpdu_guard      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].stpIfPol.attributes.ctrl}"		"bpdu-guard"      	STP Control not matching expected configuration                   values=False

Verify ACI STP Interface Policy Configuration - Policy Name default
    [Documentation]   Verifies that STP Channel Interface Policy 'default' are configured with the expected parameters
    ...  - Interface Policy Name: default
	...  - STP Control: 
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-default
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		default      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].stpIfPol.attributes.ctrl}"		""      	STP Control not matching expected configuration                   values=False

Verify ACI STP Interface Policy Configuration - Policy Name bpdu_filter
    [Documentation]   Verifies that STP Channel Interface Policy 'bpdu_filter' are configured with the expected parameters
    ...  - Interface Policy Name: bpdu_filter
	...  - STP Control: bpdu-filter
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-bpdu_filter
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		bpdu_filter      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].stpIfPol.attributes.ctrl}"		"bpdu-filter"      	STP Control not matching expected configuration                   values=False

Verify ACI STP Interface Policy Configuration - Policy Name bpdu_filter_guard
    [Documentation]   Verifies that STP Channel Interface Policy 'bpdu_filter_guard' are configured with the expected parameters
    ...  - Interface Policy Name: bpdu_filter_guard
	...  - STP Control: bpdu-filter,bpdu-guard
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/ifPol-bpdu_filter_guard
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].stpIfPol.attributes.name}		bpdu_filter_guard      Failure retreiving configuration    values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].stpIfPol.attributes.ctrl}"		"bpdu-filter,bpdu-guard"      	STP Control not matching expected configuration                   values=False

Verify ACI Leaf Interface Policy Group Configuration - Policy Group Name Access_Port
    [Documentation]   Verifies that Leaf Interface Policy Group 'Access_Port' are configured with the expected parameters
    ...  - Interface Policy Group Name:  Access_Port
    ...  - Policy Group Type:  Access
    ...  - LLDP Policy: 
    ...  - STP Policy: 
    ...  - L2 Interface Policy: 
    ...  - CDP Policy: 
    ...  - MCP Policy: 
    ...  - AAEP: baremetal
    ...  - Storm Control Policy: 
    ...  - Link Policy: 10gig_auto
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy-group
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/funcprof/accportgrp-Access_Port
    ${filter} =  Set Variable  	rsp-subtree=full
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy Group does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraAccPortGrp.attributes.name}		Access_Port			Failure retreiving configuration    values=False
	# Iterate through interface policies
	${lldp_found} =  Set Variable  False
	: FOR  ${if_policy}  IN  @{return.payload[0].infraAccPortGrp.children}
	\  Set Test Variable  ${policy_found}	False
		# LLDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLldpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLldpIfPol.attributes.tnLldpIfPolName}"	""		LLDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# STP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStpIfPol.attributes.tnStpIfPolName}"	""			STP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# L2 Interface policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsL2IfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsL2IfPol.attributes.tnL2IfPolName}"	""			L2 Interface Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# CDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsCdpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsCdpIfPol.attributes.tnCdpIfPolName}"	""			CDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# MCP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsMcpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsMcpIfPol.attributes.tnMcpIfPolName}"	""			MCP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# AAEP
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsAttEntP.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsAttEntP.attributes.tDn}"	"uni/infra/attentp-baremetal"		AAEP not matching expected configuration					values=False
	\  ...  AND  continue for loop
		# Storm Control Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStormctrlIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName}"	""		Storm Control Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# Link Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsHIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsHIfPol.attributes.tnFabricHIfPolName}"	"10gig_auto"		Link Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop

Verify ACI Leaf Interface Policy Group Configuration - Policy Group Name vPC_Port
    [Documentation]   Verifies that Leaf Interface Policy Group 'vPC_Port' are configured with the expected parameters
    ...  - Interface Policy Group Name:  vPC_Port
    ...  - Policy Group Type:  vPC
    ...  - Description: vPC port-channel
    ...  - LLDP Policy: lldp_enabled
    ...  - STP Policy: bpdu_guard
    ...  - L2 Interface Policy: global_vlan_scope
    ...  - CDP Policy: cdp_enabled
    ...  - MCP Policy: mcp_enabled
    ...  - AAEP: baremetal
    ...  - Storm Control Policy: 
    ...  - Link Policy: 10gig_auto
    ...  - Port Channel Policy: lacp_active
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy-group
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/funcprof/accbundle-vPC_Port
    ${filter} =  Set Variable  	rsp-subtree=full
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy Group does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraAccBndlGrp.attributes.name}		vPC_Port			Failure retreiving configuration    values=False
	Run keyword And Continue on Failure		Should Be Equal as Strings     "${return.payload[0].infraAccBndlGrp.attributes.descr}"	"vPC port-channel"		Description not matching expected configuration                 values=False
	# Iterate through interface policies
	${lldp_found} =  Set Variable  False
	: FOR  ${if_policy}  IN  @{return.payload[0].infraAccBndlGrp.children}
	\  Set Test Variable  ${policy_found}	False
		# LLDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLldpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLldpIfPol.attributes.tnLldpIfPolName}"	"lldp_enabled"		LLDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# STP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStpIfPol.attributes.tnStpIfPolName}"	"bpdu_guard"			STP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# L2 Interface policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsL2IfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsL2IfPol.attributes.tnL2IfPolName}"	"global_vlan_scope"			L2 Interface Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# CDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsCdpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsCdpIfPol.attributes.tnCdpIfPolName}"	"cdp_enabled"			CDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# MCP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsMcpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsMcpIfPol.attributes.tnMcpIfPolName}"	"mcp_enabled"			MCP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# AAEP
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsAttEntP.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsAttEntP.attributes.tDn}"	"uni/infra/attentp-baremetal"		AAEP not matching expected configuration					values=False
	\  ...  AND  continue for loop
		# Storm Control Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStormctrlIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName}"	""		Storm Control Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# Link Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsHIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsHIfPol.attributes.tnFabricHIfPolName}"	"10gig_auto"		Link Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# LACP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLacpPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLacpPol.attributes.tnLacpLagPolName}"	"lacp_active"					Port Channel Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop

Verify ACI Spine Interface Policy Group Configuration - Policy Group Name spine_pol_grp
    [Documentation]   Verifies that Spine Interface Policy Group 'spine_pol_grp' are configured with the expected parameters
    ...  - Interface Policy Group Name:  spine_pol_grp
    ...  - Description: 
    ...  - Link Policy: 
    ...  - CDP Policy: cdp_disabled
    ...  - AAEP: baremetal2
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy-group
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/funcprof/spaccportgrp-spine_pol_grp
    ${filter} =  Set Variable  	rsp-subtree=full
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy Group does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpAccPortGrp.attributes.name}		spine_pol_grp				Failure retreiving configuration    values=False
	Should Be Equal as Strings     "${return.payload[0].infraSpAccPortGrp.attributes.descr}"	""		Description not matching expected configuration                 values=False
	# Iterate through interface policies
	: FOR  ${if_policy}  IN  @{return.payload[0].infraSpAccPortGrp.children}
	\  Set Test Variable  ${policy_found}	False
		# CDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist  ${if_policy.infraRsCdpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsCdpIfPol.attributes.tnCdpIfPolName}"	"cdp_disabled"			CDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# Link Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist  ${if_policy.infraRsHIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsHIfPol.attributes.tnFabricHIfPolName}"	""		Link Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# AAEP
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist  ${if_policy.infraRsAttEntP.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsAttEntP.attributes.tDn}"	"uni/infra/attentp-baremetal2"		AAEP not matching expected configuration					values=False
	\  ...  AND  continue for loop

Verify ACI Leaf Interface Policy Group Configuration - Policy Group Name pc_Port
    [Documentation]   Verifies that Leaf Interface Policy Group 'pc_Port' are configured with the expected parameters
    ...  - Interface Policy Group Name:  pc_Port
    ...  - Policy Group Type:  PC
    ...  - LLDP Policy: 
    ...  - STP Policy: 
    ...  - L2 Interface Policy: 
    ...  - CDP Policy: cdp_enabled
    ...  - MCP Policy: 
    ...  - AAEP: baremetal
    ...  - Storm Control Policy: 
    ...  - Link Policy: 10gig_auto
    ...  - Port Channel Policy: 
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy-group
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/funcprof/accbundle-pc_Port
    ${filter} =  Set Variable  	rsp-subtree=full
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy Group does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraAccBndlGrp.attributes.name}		pc_Port			Failure retreiving configuration    values=False
	# Iterate through interface policies
	${lldp_found} =  Set Variable  False
	: FOR  ${if_policy}  IN  @{return.payload[0].infraAccBndlGrp.children}
	\  Set Test Variable  ${policy_found}	False
		# LLDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLldpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLldpIfPol.attributes.tnLldpIfPolName}"	""		LLDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# STP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStpIfPol.attributes.tnStpIfPolName}"	""			STP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# L2 Interface policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsL2IfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsL2IfPol.attributes.tnL2IfPolName}"	""			L2 Interface Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# CDP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsCdpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsCdpIfPol.attributes.tnCdpIfPolName}"	"cdp_enabled"			CDP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# MCP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsMcpIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsMcpIfPol.attributes.tnMcpIfPolName}"	""			MCP Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# AAEP
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsAttEntP.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsAttEntP.attributes.tDn}"	"uni/infra/attentp-baremetal"		AAEP not matching expected configuration					values=False
	\  ...  AND  continue for loop
		# Storm Control Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsStormctrlIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName}"	""		Storm Control Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop
		# Link Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsHIfPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsHIfPol.attributes.tnFabricHIfPolName}"	"10gig_auto"		Link Policy not matching expected configuration				values=False
	\  ...  AND  continue for loop
		# LACP Policy
	\  ${policy_found} =  Run Keyword And Return Status	Variable Should Exist	${if_policy.infraRsLacpPol.attributes.tDn}
	\  run keyword if  ${policy_found} == True  run keywords
	\  ...  Run keyword And Continue on Failure		Should Be Equal as Strings	"${if_policy.infraRsLacpPol.attributes.tnLacpLagPolName}"	""					Port Channel Policy not matching expected configuration		values=False
	\  ...  AND  continue for loop

Checking ACI Leaf Interface Policy Group for Faults - Policy Group Name Access_Port
    [Documentation]   Verifies ACI faults for Leaf Interface Policy Group 'Access_Port'
    ...  - Interface Policy Group Name:  Access_Port
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-policy-group
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/funcprof/accportgrp-Access_Port/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${minor_count} minor faults (passing threshold 0)"

Checking ACI Leaf Interface Policy Group for Faults - Policy Group Name vPC_Port
    [Documentation]   Verifies ACI faults for Leaf Interface Policy Group 'vPC_Port'
    ...  - Interface Policy Group Name:  vPC_Port
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-policy-group
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/funcprof/accbundle-vPC_Port/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${minor_count} minor faults (passing threshold 0)"

Checking ACI Spine Interface Policy Group for Faults - Policy Group Name spine_pol_grp
    [Documentation]   Verifies ACI faults for Spine Interface Policy Group 'spine_pol_grp'
    ...  - Interface Policy Group Name:  spine_pol_grp
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-policy-group
    # Retrieve Faults
    ${uri} =  Set Variable  //api/node/mo/uni/infra/funcprof/spaccportgrp-spine_pol_grp/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${minor_count} minor faults (passing threshold 0)"

Checking ACI Leaf Interface Policy Group for Faults - Policy Group Name pc_Port
    [Documentation]   Verifies ACI faults for Leaf Interface Policy Group 'pc_Port'
    ...  - Interface Policy Group Name:  pc_Port
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-policy-group
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/funcprof/accbundle-pc_Port/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${minor_count} minor faults (passing threshold 0)"

Verify ACI Leaf Interface Profile Configuration - Profile Leaf
    [Documentation]   Verifies that Leaf Interface Profile 'Leaf' are configured with the expected parameters
    ...  - Profile Name:  Leaf
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraAccPortP.attributes.name}   Leaf      Failure retreiving configuration    values=False

Verify ACI Spine Interface Profile Configuration - Profile Spine
    [Documentation]   Verifies that Spine Interface Profile 'Spine' are configured with the expected parameters
    ...  - Profile Name:  Spine
    ...  - Description: test
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-Spine
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpAccPortP.attributes.name}   Spine        Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSpAccPortP.attributes.descr}"  "test"                       Description not matching expected configuration                 values=False

Verify ACI Spine Interface Profile Configuration - Profile Spine2
    [Documentation]   Verifies that Spine Interface Profile 'Spine2' are configured with the expected parameters
    ...  - Profile Name:  Spine2
    ...  - Description: test
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-Spine2
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpAccPortP.attributes.name}   Spine2        Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSpAccPortP.attributes.descr}"  "test"                       Description not matching expected configuration                 values=False

Checking ACI Leaf Interface Profile for Faults - Profile Leaf
    [Documentation]   Verifies ACI faults for Leaf Interface Profile 'Leaf'
    ...  - Profile Name:  Leaf
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/accportprof-Leaf/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${minor_count} minor faults (passing threshold 1)"

Checking ACI Spine Interface Profile for Faults - Profile Spine
    [Documentation]   Verifies ACI faults for Spine Interface Profile 'Spine'
    ...  - Profile Name:  Spine
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/spaccportprof-Spine/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${minor_count} minor faults (passing threshold 1)"

Checking ACI Spine Interface Profile for Faults - Profile Spine2
    [Documentation]   Verifies ACI faults for Spine Interface Profile 'Spine2'
    ...  - Profile Name:  Spine2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/spaccportprof-Spine2/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${minor_count} minor faults (passing threshold 1)"

Verify ACI Leaf Interface Profile to Switch Profile Association Configuration - Switch Profile Leaf1_2, Interface Profile Leaf
    [Documentation]   Verifies that ACI Leaf Interface Profile 'Leaf' are associated with Switch Profile 'Leaf1_2'
    ...  - Switch Profile Name:  Leaf1_2
    ...  - Interface Profile: Leaf
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-Leaf1_2
	${filter} =  Set Variable	rsp-subtree=full&rsp-subtree-class=infraRsAccPortP
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraNodeP.attributes.name}   Leaf1_2       Failure retreiving configuration    values=False
	# Iterate through associated interface profiles
	Set Test Variable  ${node_block_found}   "Interface Profile not found"
    Variable Should Exist   @{return.payload[0].infraNodeP.children}       Interface Profile not associated with switch profile
    : FOR  ${if_profile}  IN  @{return.payload[0].infraNodeP.children}
	\  run keyword if  "${if_profile.infraRsAccPortP.attributes.tDn}" == "uni/infra/accportprof-Leaf"  run keywords
	\  ...  Set Test Variable  ${node_block_found}  "Interface Profile found"
    \  ...  AND  Exit For Loop
	run keyword if  not ${node_block_found} == "Interface Profile found"  run keyword
	...  Fail  Interface Profile not associated with switch profile

Verify ACI Spine Interface Profile to Switch Profile Association Configuration - Switch Profile Spine, Interface Profile Spine2
    [Documentation]   Verifies that Spine Interface Profile 'Spine2' are associated with Switch Profile 'Spine'
    ...  - Switch Profile Name:  Spine
    ...  - Interface Profile: Spine2
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-Spine
	${filter} =  Set Variable	rsp-subtree=full&rsp-subtree-class=infraRsSpAccPortP
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpineP.attributes.name}   Spine      Failure retreiving configuration    values=False
	# Iterate through associated interface profiles
	Set Test Variable  ${node_block_found}   "Interface Profile not found"
    Variable Should Exist   @{return.payload[0].infraSpineP.children}       Interface Profile not associated with switch profile
    : FOR  ${if_profile}  IN  @{return.payload[0].infraSpineP.children}
	\  run keyword if  "${if_profile.infraRsSpAccPortP.attributes.tDn}" == "uni/infra/spaccportprof-Spine2"  run keywords
	\  ...  Set Test Variable  ${node_block_found}  "Interface Profile found"
    \  ...  AND  Exit For Loop
	run keyword if  not ${node_block_found} == "Interface Profile found"  run keyword
	...  Fail  Interface Profile not associated with switch profile

Verify ACI Leaf Interface Selector Configuration - Interface Profile Leaf, Interface Selector e1
    [Documentation]   Verifies that ACI Leaf Interface Selector 'e1' under 'Leaf' are configured with the expected parameters
    ...  - Interface Profile Name:  Leaf
    ...  - Interface Selector Name:  e1
    ...  - From Slot: 1
    ...  - From Port: 1
    ...  - To Slot: 1
    ...  - To Port: 1
    ...  - Associated Interface Policy Group: Access_Port
    ...  - Associated Interface Policy Group Type: Access
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf/hports-e1-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   e1    Failure retreiving configuration    values=False
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "1"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "1"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf/hports-e1-typ-range/rsaccBaseGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/funcprof/accportgrp-Access_Port        Interface Policy Group Association not matching expected configuration	    values=False

Verify ACI Leaf Interface Selector Configuration - Interface Profile Leaf, Interface Selector e2
    [Documentation]   Verifies that ACI Leaf Interface Selector 'e2' under 'Leaf' are configured with the expected parameters
    ...  - Interface Profile Name:  Leaf
    ...  - Interface Selector Name:  e2
    ...  - From Slot: 1
    ...  - From Port: 2
    ...  - To Slot: 1
    ...  - To Port: 2
    ...  - Associated Interface Policy Group: vPC_Port
    ...  - Associated Interface Policy Group Type: vPC
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf/hports-e2-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   e2    Failure retreiving configuration    values=False
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "2"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "2"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf/hports-e2-typ-range/rsaccBaseGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/funcprof/accbundle-vPC_Port        Interface Policy Group Association not matching expected configuration	    values=False

Verify ACI Leaf Interface Selector Configuration - Interface Profile Leaf, Interface Selector e3
    [Documentation]   Verifies that ACI Leaf Interface Selector 'e3' under 'Leaf' are configured with the expected parameters
    ...  - Interface Profile Name:  Leaf
    ...  - Interface Selector Name:  e3
    ...  - From Slot: 1
    ...  - From Port: 3
    ...  - To Slot: 1
    ...  - To Port: 3
    ...  - Associated Interface Policy Group: Access_Port
    ...  - Associated Interface Policy Group Type: Access
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf/hports-e3-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   e3    Failure retreiving configuration    values=False
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "3"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "3"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-Leaf/hports-e3-typ-range/rsaccBaseGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/funcprof/accportgrp-Access_Port        Interface Policy Group Association not matching expected configuration	    values=False

Verify ACI Spine Interface Selector Configuration - Interface Profile Spine, Interface Selector e1
    [Documentation]   Verifies that ACI Spine Interface Selector 'e1' under 'Spine' are configured with the expected parameters
    ...  - Interface Profile Name:  Spine
    ...  - Interface Selector Name:  e1
    ...  - Interface Selector Description: test
    ...  - From Slot: 1
    ...  - From Port: 1
    ...  - To Slot: 1
    ...  - To Port: 1
    ...  - Port Block Description: test2
    ...  - Associated Interface Policy Group: spine_pol_grp
    ...  - Associated Interface Policy Group Type: Access
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-Spine/shports-e1-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSHPortS.attributes.name}   e1   Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSHPortS.attributes.descr}"  "test"                       Description not matching expected configuration                 values=False
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraSHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "1"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "1"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "test2"                                          Port Block Description not matching expected configuration                 values=False
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-Spine/shports-e1-typ-range/rsspAccGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsSpAccGrp.attributes.tDn}   uni/infra/funcprof/spaccportgrp-spine_pol_grp        Interface Policy Group Association not matching expected configuration	    values=False

Verify ACI Spine Interface Selector Configuration - Interface Profile Spine2, Interface Selector e1
    [Documentation]   Verifies that ACI Spine Interface Selector 'e1' under 'Spine2' are configured with the expected parameters
    ...  - Interface Profile Name:  Spine2
    ...  - Interface Selector Name:  e1
    ...  - Interface Selector Description: test
    ...  - From Slot: 1
    ...  - From Port: 1
    ...  - To Slot: 1
    ...  - To Port: 1
    ...  - Port Block Description: test2
    ...  - Associated Interface Policy Group: spine_pol_grp
    ...  - Associated Interface Policy Group Type: Access
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-Spine2/shports-e1-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSHPortS.attributes.name}   e1   Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSHPortS.attributes.descr}"  "test"                       Description not matching expected configuration                 values=False
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraSHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "1"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "1"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "1"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "test2"                                          Port Block Description not matching expected configuration                 values=False
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-Spine2/shports-e1-typ-range/rsspAccGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsSpAccGrp.attributes.tDn}   uni/infra/funcprof/spaccportgrp-spine_pol_grp        Interface Policy Group Association not matching expected configuration	    values=False

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
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.dn}     uni/tn-tenant1       Failure retreiving configuration                    values=False
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
    ...  - Minor fault count <= 1
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
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold 1)"

Checking ACI BD for Faults - Tenant tenant1, BD bd2
    [Documentation]   Verifies ACI faults for VRF 'bd2' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd2
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
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
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold 1)"

Checking ACI BD for Faults - Tenant tenant1, BD bd3
    [Documentation]   Verifies ACI faults for VRF 'bd3' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - BD Name: bd3
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 1
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
    run keyword if  not ${minor_count} <= 1  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold 1)"

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
    ...  - Major fault count <= 5
    ...  - Minor fault count <= 2
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
    run keyword if  not ${major_count} <= 5  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${major_count} major faults (passing threshold 5)"
    run keyword if  not ${minor_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${minor_count} minor faults (passing threshold 2)"

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

Verify ACI L3Out Configuration - Tenant tenant1, L3Out L3OUT-main_INT
    [Documentation]   Verifies that ACI L3Out 'L3OUT-main_INT' under tenant 'tenant1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Name Alias: 
    ...  - VRF Association: main
    ...  - OSPF Enabled: yes
    ...  - OSPF Area: 1
    ...  - OSPF Area Type: regular
    ...  - BGP Enabled: yes
    ...  - Consumer Label: 
    ...  - Provider Label: 
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.name}"   "L3OUT-main_INT"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.nameAlias}"  ""                   Name Alias not matching expected configuration                 values=False
    # VRF association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/rsectx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving VRF configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsEctx.attributes.tnFvCtxName}"  "main"                     VRF Association not matching expected configuration                 values=False
    # Domain
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/rsl3DomAtt
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving Domain configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsL3DomAtt.attributes.tDn}"  "uni/l3dom-l3out_dom"      Domain Association not matching expected configuration                 values=False
    # OSPF
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/ospfExtP
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		OSPF not enabled 		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfExtP.attributes.areaId}"  "0.0.0.1"              OSPF Area ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfExtP.attributes.areaType}"  "regular"                     OSPF Area Type not matching expected configuration                 values=False
    # BGP
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/bgpExtP
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		BGP not enabled 		values=False

Checking ACI L3Out for Faults - Tenant tenant1, L3Out L3OUT-main_INT
    [Documentation]   Verifies ACI faults for L3Out 'L3OUT-main_INT' under tenant 'tenant1'
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 2
    [Tags]      aci-faults  aci-tenant  aci-tenant-l3out
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "L3Out has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "L3Out has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "L3Out has ${minor_count} minor faults (passing threshold 2)"

Verify ACI L3Out Node Profile Configuration - Tenant tenant1, L3Out L3OUT-main_INT, Node Profile leaf1, Node pod-1/node-201
    [Documentation]   Verifies that ACI L3Out Node Profile 'leaf1' under tenant 'tenant1', L3Out 'L3OUT-main_INT' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Node Profile Name: leaf1
    ...  - Name Alias: 
    ...  - Node: pod-1/node-201
    ...  - Router ID: 172.17.8.3
    ...  - Use Router ID as Loopback: yes
    ...  - Multi-POD Enable: no
    ...  - Golf Enable: no
    ...  - Target DSCP: unspecified
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.name}"   "leaf1"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.nameAlias}"  ""                    Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.targetDscp}"  "unspecified"                  Target DSCP not matching expected configuration                 values=False
    # Node Association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/rsnodeL3OutAtt-[topology/pod-1/node-201]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Node not associated with Node Profile		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrId}"  "172.17.8.3"                         Router ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrIdLoopBack}"  "yes"     Use Router ID as Loopback not matching expected configuration                 values=False

Verify ACI L3Out Node Profile Configuration - Tenant tenant1, L3Out L3OUT-main_INT, Node Profile leaf1, Node pod-1/node-202
    [Documentation]   Verifies that ACI L3Out Node Profile 'leaf1' under tenant 'tenant1', L3Out 'L3OUT-main_INT' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Node Profile Name: leaf1
    ...  - Name Alias: 
    ...  - Node: pod-1/node-202
    ...  - Router ID: 172.17.8.4
    ...  - Use Router ID as Loopback: yes
    ...  - Multi-POD Enable: no
    ...  - Golf Enable: no
    ...  - Target DSCP: unspecified
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.name}"   "leaf1"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.nameAlias}"  ""                    Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.targetDscp}"  "unspecified"                  Target DSCP not matching expected configuration                 values=False
    # Node Association
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/rsnodeL3OutAtt-[topology/pod-1/node-202]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Node not associated with Node Profile		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrId}"  "172.17.8.4"                         Router ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrIdLoopBack}"  "yes"     Use Router ID as Loopback not matching expected configuration                 values=False

Verify ACI L3Out Node Level BGP Peer Configuration - Tenant tenant1, L3Out L3OUT-main_INT, Node Profile leaf1, Peer 10.1.1.3
    [Documentation]   Verifies that ACI L3Out Node Level BGP Peer '10.1.1.3' under tenant 'tenant1', L3Out 'L3OUT-main_INT', Node Profile 'leaf1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Node Profile Name: leaf1
    ...  - BGP Peer: 10.1.1.3
    ...  - Description: 10.1.1.3
    ...  - Local BGP AS Number: 
    ...  - Local AS Configuration: replace-as
    ...  - Remote BGP AS Number: 65555
    ...  - BGP Multihop TTL: 2
    ...  - BGP Controls: send-com,send-ext-com
    ...  - Golf / L3EVPN BGP Peer: no
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    # Regular BGP Peer (none-GOLF)
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/peerP-[10.1.1.3]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Level BGP Peer does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.addr}"   "10.1.1.3"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.descr}"  "10.1.1.3"                    Description not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.ttl}"  "2"                                TTL not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.ctrl}"  "send-com,send-ext-com"                           BGP Controls not matching expected configuration                 values=False
    # Remote AS
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/peerP-[10.1.1.3]/as
	  ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpAsP.attributes.asn}"  "65555"                        Remote BGP AS not matching expected configuration                 values=False

Checking ACI L3Out Node Level BGP Peer for Faults - Tenant tenant1, L3Out L3OUT-main_INT, Node Profile leaf1, Peer 10.1.1.3
    [Documentation]   Verifies ACI faults for L3Out Node Level BGP Peer '10.1.1.3' under tenant 'tenant1', L3Out 'L3OUT-main_INT', Node Profile 'leaf1'
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Node Profile Name: leaf1
    ...  - BGP Peer: 10.1.1.3
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 0
    [Tags]      aci-faults  aci-tenant  aci-tenant-l3out
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/peerP-[10.1.1.3]/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${minor_count} minor faults (passing threshold 0)"

Verify ACI L3Out Interface Profile Configuration - Tenant tenant1, L3Out L3OUT-main_INT, Node Profile leaf1, Interface Profile L3outInt-node1
    [Documentation]   Verifies that ACI L3Out Interface Profile 'L3outInt-node1' under tenant 'tenant1', L3Out 'L3OUT-main_INT', Node Profile 'leaf1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Node Profile Name: leaf1
    ...  - Interface Profile Name: L3outInt-node1
    ...  - Name Alias: 
    ...  - Interface Type: svi
    ...  - Interface Path Type: vPC
    ...  - POD: 1
    ...  - Node ID (side A): 201
    ...  - Node ID (side B: 202
    ...  - Interface Policy Group: vPC_Port
    ...  - Interface Type: svi
    ...  - Interface Mode: regular
    ...  - Encapsulation: vlan-200
    ...  - IP (side A): 10.1.1.1/24
    ...  - IP (side B): 10.1.1.2/24
    ...  - MTU: inherit
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/lifp-L3outInt-node1
    ${filter} =  Set Variable  rsp-subtree=full&rsp-subtree-class=l3extRsPathL3OutAtt
    ${return} =  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Interface Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.name}"   "L3outInt-node1"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.nameAlias}"  ""                  Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.tDn}"  "topology/pod-1/protpaths-201-202/pathep-[vPC_Port]"                        Interface Policy Group/Interface ID, Node(s), or POD not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.ifInstT}"  "ext-svi"                  Interface Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.encap}"  "vlan-200"                     Encapsulation not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mode}"  "regular"       Interface Mode not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mtu}"  "inherit"               MTU not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.autostate}"  "disabled"   Autostate not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.addr}"  "0.0.0.0"                        'Global' IP Address not matching expected configuration                 values=False
    : FOR  ${member}  IN  @{return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.children}
    \  run keyword if  "${member.l3extMember.attributes.side}" == "A"
    \  ...  Run keyword And Continue on Failure  Should Be Equal as Strings  "${member.l3extMember.attributes.addr}"  "10.1.1.1/24"    Side A IP Address not matching expected configuration                 values=False
    \  run keyword if  "${member.l3extMember.attributes.side}" == "B"
    \  ...  Run keyword And Continue on Failure  Should Be Equal as Strings  "${member.l3extMember.attributes.addr}"  "10.1.1.2/24"    Side B IP Address not matching expected configuration                 values=False

Verify ACI L3Out Interface Profile Configuration - Tenant tenant1, L3Out L3OUT-main_INT, Node Profile leaf1, Interface Profile L3outInt-node1-access
    [Documentation]   Verifies that ACI L3Out Interface Profile 'L3outInt-node1-access' under tenant 'tenant1', L3Out 'L3OUT-main_INT', Node Profile 'leaf1' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - Node Profile Name: leaf1
    ...  - Interface Profile Name: L3outInt-node1-access
    ...  - Name Alias: 
    ...  - Interface Type: routed_sub
    ...  - Interface Path Type: Access
    ...  - POD: 1
    ...  - Node ID: 201
    ...  - Interface ID: eth1/3
    ...  - Interface Type: routed_sub
    ...  - Interface Mode: regular
    ...  - Encapsulation: vlan-200
    ...  - IP: 11.1.1.1/24
    ...  - MTU: inherit
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/lnodep-leaf1/lifp-L3outInt-node1-access
    ${filter} =  Set Variable  rsp-subtree=full&rsp-subtree-class=l3extRsPathL3OutAtt
    ${return} =  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Interface Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.name}"   "L3outInt-node1-access"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.nameAlias}"  ""                  Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.tDn}"  "topology/pod-1/paths-201/pathep-[eth1/3]"                        Interface Policy Group/Interface ID, Node(s), or POD not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.ifInstT}"  "sub-interface"                  Interface Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.encap}"  "vlan-200"                     Encapsulation not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mode}"  "regular"       Interface Mode not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mtu}"  "inherit"               MTU not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.autostate}"  "disabled"   Autostate not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.addr}"  "11.1.1.1/24"   IP Address not matching expected configuration                 values=False

Verify ACI L3Out External EPG Configuration - Tenant tenant1, L3Out L3OUT-main_INT, External EPG external
    [Documentation]   Verifies that ACI L3Out External EPG 'external' under tenant 'tenant1', L3Out 'L3OUT-main_INT' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - External EPG: external
    ...  - Name Alias: 
    ...  - Prefered Group Member: exclude
    ...  - QoS Class: unspecified
    ...  - Target DSCP: unspecified
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/instP-external
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out External EPG does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.name}"   "external"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.nameAlias}"  ""                  Name Alias not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.prefGrMemb}"  "exclude"      Preferred Group Member not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.prio}"  "unspecified"                        QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.targetDscp}"  "unspecified"                Target DSCP not matching expected configuration                 values=False

Checking ACI L3Out External EPG for Faults - Tenant tenant1, L3Out L3OUT-main_INT, External EPG external
    [Documentation]   Verifies ACI faults for External EPG 'external' under tenant 'tenant1', L3Out 'L3OUT-main_INT'
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - External EPG: external
    ...  - Critical fault count <= 0
    ...  - Major fault count <= 0
    ...  - Minor fault count <= 2
    [Tags]      aci-faults  aci-tenant  aci-tenant-vrf
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/instP-external/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "External EPG has ${critical_count} critical faults (passing threshold 0)"
    run keyword if  not ${major_count} <= 0  Run keyword And Continue on Failure
    ...  Fail  "External EPG has ${major_count} major faults (passing threshold 0)"
    run keyword if  not ${minor_count} <= 2  Run keyword And Continue on Failure
    ...  Fail  "External EPG has ${minor_count} minor faults (passing threshold 2)"

Verify ACI L3Out External EPG Subnet Configuration - Tenant tenant1, L3Out L3OUT-main_INT, External EPG external, Subnet 0.0.0.0/0, Route Control Profile 'daf'
    [Documentation]   Verifies that ACI L3Out External EPG Subnet '' under tenant 'tenant1', L3Out 'L3OUT-main_INT', External EPG 'external' are configured with the expected parameters
    ...  - Tenant Name: tenant1
    ...  - L3Out Name: L3OUT-main_INT
    ...  - External EPG: external
    ...  - Subnet: 0.0.0.0/0
    ...  - External Subnet for External EPG: yes
    ...  - Export Route Control: no
    ...  - Shared Route Control: no
    ...  - Shared Security Import: no
    ...  - Aggregated Shared Route: no
    ...  - Route Control Profile: daf
    ...  - Route Control Profile Direction: import
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/instP-external/extsubnet-[0.0.0.0/0]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Subnet not associated with External EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extSubnet.attributes.aggregate}"  ""                     Aggregate not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extSubnet.attributes.scope}"      "import-security"               Scope not matching expected configuration                 values=False
    ${uri} =  Set Variable  /api/mo/uni/tn-tenant1/out-L3OUT-main_INT/instP-external/extsubnet-[0.0.0.0/0]/rssubnetToProfile-[daf]-import
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}   1		Route Profile or Route Profile Direction not matching expected configuration		values=False

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

Verify APIC Software Version - APIC 1
    [Documentation]   Verifies that APIC 1 in POD 1 are running the expeced software version
    ...  POD: 1
    ...  APIC ID: 1
    ...  Software Version: 3.2(1m)
    ...  Software Running Mode: normal
    [Tags]      aci-operations  aci-software-version
    ${uri} =  Set Variable  /api/mo/topology/pod-1/node-1/sys/ctrlrfwstatuscont/ctrlrrunning
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving controller software information		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareCtrlrRunning.attributes.version}   3.2(1m)         APIC controller not running expected software version                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareCtrlrRunning.attributes.mode}      normal          Software running mode not matching expected configration                    values=False

Verify ACI Login
    [Documentation]   Verifies ACI user login
    [Tags]      aci-operations  aci-fabric-aaa
    ${auth_cookie}=  ACI REST login on ${apic}
    log  "Authentication successful, received authentication token '${auth_cookie}"

Verify ACI Fabric Infrastructure VLAN Configuration - APIC1
    [Documentation]   Verifies that ACI Fabric Infrastructure VLAN Configuration on APIC1
    ...  - APIC Hostname: apic1
    ...  - Fabric ID: 1
    ...  - POD ID: 1
    ...  - Infrastructure VLAN ID: 4
    [Tags]      aci-conf  aci-fabric-infra-vlan
    ${return}=  via ACI REST API retrieve "/api/node/mo/topology/pod-1/node-1/sys/inst-bond0.json?query-target=subtree&target-subtree-class=l3EncRtdIf" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200                                                                  Failure executing API call		                                    values=False
    should be equal as strings      ${return.totalCount}  1                                                                 APIC does not exist within fabric		                            values=False
    should be equal as strings      ${return.payload[0].l3EncRtdIf.attributes.encap}  vlan-4         Fabric Infrastructure VLAN matching expected configuration          values=False


Verify ACI Fabric Infrastructure VLAN Configuration - Node 201
    [Documentation]   Verifies that ACI Fabric Infrastructure VLAN Configuration on Node 201
    ...  - Node Hostname: leaf1
    ...  - Fabric ID: 201
    ...  - POD ID: 1
    ...  - Infrastructure VLAN ID: 4
    [Tags]      aci-conf  aci-fabric-infra-vlan
    ${return}=  via ACI REST API retrieve "/api/node/mo/topology/pod-1/node-201/sys/lldp/inst" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200                                                                  Failure executing API call		                                    values=False
    should be equal as strings      ${return.totalCount}  1                                                                 Node does not exist within fabric		                            values=False
    should be equal as Integers     ${return.payload[0].lldpInst.attributes.infraVlan}  4            Fabric Infrastructure VLAN matching expected configuration          values=False


Verify ACI Fabric Infrastructure VLAN Configuration - Node 202
    [Documentation]   Verifies that ACI Fabric Infrastructure VLAN Configuration on Node 202
    ...  - Node Hostname: leaf2
    ...  - Fabric ID: 202
    ...  - POD ID: 1
    ...  - Infrastructure VLAN ID: 4
    [Tags]      aci-conf  aci-fabric-infra-vlan
    ${return}=  via ACI REST API retrieve "/api/node/mo/topology/pod-1/node-202/sys/lldp/inst" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200                                                                  Failure executing API call		                                    values=False
    should be equal as strings      ${return.totalCount}  1                                                                 Node does not exist within fabric		                            values=False
    should be equal as Integers     ${return.payload[0].lldpInst.attributes.infraVlan}  4            Fabric Infrastructure VLAN matching expected configuration          values=False


Verify ACI Fabric Infrastructure VLAN Configuration - Node 101
    [Documentation]   Verifies that ACI Fabric Infrastructure VLAN Configuration on Node 101
    ...  - Node Hostname: spine1
    ...  - Fabric ID: 101
    ...  - POD ID: 1
    ...  - Infrastructure VLAN ID: 4
    [Tags]      aci-conf  aci-fabric-infra-vlan
    ${return}=  via ACI REST API retrieve "/api/node/mo/topology/pod-1/node-101/sys/lldp/inst" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200                                                                  Failure executing API call		                                    values=False
    should be equal as strings      ${return.totalCount}  1                                                                 Node does not exist within fabric		                            values=False
    should be equal as Integers     ${return.payload[0].lldpInst.attributes.infraVlan}  4            Fabric Infrastructure VLAN matching expected configuration          values=False


Verify ACI TEP Pool Configuration - POD 1
    [Documentation]   Verifies that ACI TEP Pool Configuration for POD 1
    ...  - POD ID: 1
    ...  - TEP Pool: 10.0.0.0/16
    [Tags]      aci-conf  aci-fabric-tep-pool
    ${return}=  via ACI REST API retrieve "/api/mo/uni/controller/setuppol/setupp-1" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200      Failure executing API call		values=False
    should be equal as strings      ${return.totalCount}  1     Fabric POD does not exist	values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fabricSetupP.attributes.tepPool}   10.0.0.0/16        TEP Pool not matching expected configuration	            values=False



Verify ACI APIC Provisioning Configuration - APIC 1
    [Documentation]  Verifies that APIC 1 are provisioned with the expected parameters
    ...  - Hostname: apic1
    ...  - POD ID: 1
    ...  - Node ID: 1
    ...  - Role: controller
    ...  - OOB Address (IPv4): 10.49.96.69/28
    ...  - OOB Gateway (IPv4): 10.49.96.65
    ...  - OOB Address (IPv6): 
    ...  - OOB Gateway (IPv6): 
    ...  - Inband Address (IPv4): 
    ...  - Inband Gateway (IPv4): 
    ...  - Inband Address (IPv6): 
    ...  - Inband Gateway (IPv6): 
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-1/node-1/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  apic1                 Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  1                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  1                         Node ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  controller                                  Node Role not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr}  10.49.96.69                       OOB Management Address (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddrMask}  28                   OOB Management Address Mask (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtGateway}  10.49.96.65         OOB Management Gateway (IPv4) not matching expected configuration              values=False

Verify ACI Node Provisioning Configuration - Node 201
    [Documentation]  Verifies that Node 201 are provisioned with the expected parameters
    ...  - Hostname: leaf1
    ...  - POD ID: 1
    ...  - Node ID: 201
    ...  - Serial Number: TEP-1-102
    ...  - Role: leaf
    ...  - OOB Address (IPv4): 1.1.1.1/24
    ...  - OOB Gateway (IPv4): 1.1.1.254
    ...  - OOB Address (IPv6): 
    ...  - OOB Gateway (IPv6): 
    ...  - Inband Address (IPv4): 
    ...  - Inband Gateway (IPv4): 
    ...  - Inband Address (IPv6): 
    ...  - Inband Gateway (IPv6): 
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-1/node-201/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  leaf1                          Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  1                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  201                         Node ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.serial}  TEP-1-102               Serial Number not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  leaf                          Node Role not matching expected configuration              values=False
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-201]
    ${oob}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${oob.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${oob.totalCount}	1		Out-of-Band Management not configured   values=False
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.addr}  1.1.1.1/24                   OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.gw}  1.1.1.254             OOB Management Gateway (IPv4) not matching expected configuration              values=False

Verify ACI Node Provisioning Configuration - Node 202
    [Documentation]  Verifies that Node 202 are provisioned with the expected parameters
    ...  - Hostname: leaf2
    ...  - POD ID: 1
    ...  - Node ID: 202
    ...  - Serial Number: TEP-1-101
    ...  - Role: leaf
    ...  - OOB Address (IPv4): 1.1.1.2/24
    ...  - OOB Gateway (IPv4): 1.1.1.254
    ...  - OOB Address (IPv6): 
    ...  - OOB Gateway (IPv6): 
    ...  - Inband Address (IPv4): 
    ...  - Inband Gateway (IPv4): 
    ...  - Inband Address (IPv6): 
    ...  - Inband Gateway (IPv6): 
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-1/node-202/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  leaf2                          Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  1                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  202                         Node ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.serial}  TEP-1-101               Serial Number not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  leaf                          Node Role not matching expected configuration              values=False
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-202]
    ${oob}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${oob.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${oob.totalCount}	1		Out-of-Band Management not configured   values=False
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.addr}  1.1.1.2/24                   OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.gw}  1.1.1.254             OOB Management Gateway (IPv4) not matching expected configuration              values=False

Verify ACI Node Provisioning Configuration - Node 101
    [Documentation]  Verifies that Node 101 are provisioned with the expected parameters
    ...  - Hostname: spine1
    ...  - POD ID: 1
    ...  - Node ID: 101
    ...  - Serial Number: TEP-1-103
    ...  - Role: spine
    ...  - OOB Address (IPv4): 1.1.1.3/24
    ...  - OOB Gateway (IPv4): 1.1.1.254
    ...  - OOB Address (IPv6): 
    ...  - OOB Gateway (IPv6): 
    ...  - Inband Address (IPv4): 
    ...  - Inband Gateway (IPv4): 
    ...  - Inband Address (IPv6): 
    ...  - Inband Gateway (IPv6): 
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-1/node-101/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  spine1                          Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  1                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  101                         Node ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.serial}  TEP-1-103               Serial Number not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  spine                          Node Role not matching expected configuration              values=False
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-1/node-101]
    ${oob}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${oob.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${oob.totalCount}	1		Out-of-Band Management not configured   values=False
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.addr}  1.1.1.3/24                   OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.gw}  1.1.1.254             OOB Management Gateway (IPv4) not matching expected configuration              values=False

Verify ACI Fabric Connectivity - Node 201 (eth1/49) to Node 101 (eth5/2)
    [Documentation]   Verifies that ACI Fabric Connectivity from node 201 (eth1/49) to node 101 (eth5/2) are connected and operates as expected
    ...  - From POD ID: 1
    ...  - From Node: leaf1
    ...  - From Node ID: 201
    ...  - From Port: eth1/49
    ...  - To Node: spine1
    ...  - To Node ID: 101
    ...  - To Port: eth5/2
    [Tags]      aci-operations  aci-fabric-connectivity
    # LLDP
    ${uri} =  Set Variable  /api/node/mo/topology/pod-1/node-201/sys/lldp/inst/if-[eth1/49]
    ${filter} =  Set Variable  query-target=children&target-subtree-class=lldpAdjEp&query-target=subtree
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		No LLDP neighbor found		values=False
	run keyword if  "${return.totalCount}" == "1"  run keywords
    ...  Run keyword And Continue on Failure       Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.sysDesc}      topology/pod-1/node-101                                   LLDP neighbor not matching expected system name (sysDesc)   values=False
    ...  AND  Run keyword And Continue on Failure   Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.portDesc}     topology/pod-1/paths-101/pathep-[eth5/2]     LLDP neighbor not matching expected port (portDesc)         values=False
    # Link Mode (Fabric)
    ${uri} =  Set Variable  /api/node/mo/topology/pod-1/lnkcnt-101/lnk-201-1-49-to-101-5-2
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		Port usage is not "Fabric" as expected		values=False

Verify ACI Fabric Connectivity - Node 202 (eth1/49) to Node 101 (eth5/1)
    [Documentation]   Verifies that ACI Fabric Connectivity from node 202 (eth1/49) to node 101 (eth5/1) are connected and operates as expected
    ...  - From POD ID: 1
    ...  - From Node: leaf2
    ...  - From Node ID: 202
    ...  - From Port: eth1/49
    ...  - To Node: spine1
    ...  - To Node ID: 101
    ...  - To Port: eth5/1
    [Tags]      aci-operations  aci-fabric-connectivity
    # LLDP
    ${uri} =  Set Variable  /api/node/mo/topology/pod-1/node-202/sys/lldp/inst/if-[eth1/49]
    ${filter} =  Set Variable  query-target=children&target-subtree-class=lldpAdjEp&query-target=subtree
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		No LLDP neighbor found		values=False
	run keyword if  "${return.totalCount}" == "1"  run keywords
    ...  Run keyword And Continue on Failure       Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.sysDesc}      topology/pod-1/node-101                                   LLDP neighbor not matching expected system name (sysDesc)   values=False
    ...  AND  Run keyword And Continue on Failure   Should Be Equal As Strings       ${return.payload[0].lldpAdjEp.attributes.portDesc}     topology/pod-1/paths-101/pathep-[eth5/1]     LLDP neighbor not matching expected port (portDesc)         values=False
    # Link Mode (Fabric)
    ${uri} =  Set Variable  /api/node/mo/topology/pod-1/lnkcnt-101/lnk-202-1-49-to-101-5-1
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}    1		Port usage is not "Fabric" as expected		values=False


