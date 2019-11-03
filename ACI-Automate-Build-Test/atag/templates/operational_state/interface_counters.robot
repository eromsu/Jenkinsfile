{#
Collects interface counters (CRC, input errors and discards, output errors and discards) from all interfaces within the fabric twice.

After collection of counters are the two compared to see if any of them have increased.

#}
Collect ACI Interface Counters
    [Documentation]  Collect interfaces error counters twice with an interval
    ...  - Interval between counter collection: {{config['counter_collection_interval']}}
    [Tags]      aci-operations  aci-fabric-counters
    # Gather interface list
    ${uri}=     Set Variable  /api/node/class/l1PhysIf
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200          Failure retrieving interface list		values=False
    Should Not Be Equal As Integers    ${return.totalCount}  0      No interfaces found in Fabric           values=False
    Set Suite Variable  ${fabric_interfaces}  ${return.payload}
    # Prepare dictionaries to store interface counters
    ${dn_crc_one}=      Create Dictionary
    ${dn_rxerr_one}=    Create Dictionary
    ${dn_rxdsc_one}=    Create Dictionary
    ${dn_txerr_one}=    Create Dictionary
    ${dn_txdsc_one}=    Create Dictionary
    ${dn_crc_two}=      Create Dictionary
    ${dn_rxerr_two}=    Create Dictionary
    ${dn_rxdsc_two}=    Create Dictionary
    ${dn_txerr_two}=    Create Dictionary
    ${dn_txdsc_two}=    Create Dictionary
    # For each interface pull five error counters and add them to a respective dictionary first time
    :FOR  ${intf}  IN  @{fabric_interfaces}
    \  # Collect and store CRC errors
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgEtherStats
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  run keyword And Continue on Failure  Should Be Equal as Integers     ${return_dn.status}   200       Error retrieving dbgEtherStats object for interface with DN "${dn}" (1st collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving CRC errors for interface with DN "${dn}" (1st collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  ${crc_err} =   Convert to Integer  ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  Set To Dictionary    ${dn_crc_one}  ${dn}  ${crc_err}
    \  # Collect and store ingress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfIn
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfIn object for interface with DN "${dn}" (1st collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving ingress errors and discards for interface with DN "${dn}" (1st collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  Set To Dictionary    ${dn_rxerr_one}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_rxdsc_one}  ${dn}  ${dsc_err}
    \  # Collect and store egress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfOut
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfOut object for interface with DN "${dn}" (1st collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving egress errors and discards for interface with DN "${dn}" (1st collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  Set To Dictionary    ${dn_txerr_one}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_txdsc_one}  ${dn}  ${dsc_err}
    # Wait for some time before collecting the counters again
    Log to console  \nPausing execution for {{config['counter_collection_interval']}} before resume collecting interface counters (2nd time)
    Sleep  {{config['counter_collection_interval']}}
    # Temporarily refresh login on APIC to address BUG in RASTA (https://wwwin-github.cisco.com/AS-Community/RASTA/pull/237)
    ACI REST login on ${apic}
    # For each interface pull five error counters and add them to a respective dictionary second time
    :FOR  ${intf}  IN  @{fabric_interfaces}
    \  # Collect and store CRC errors
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgEtherStats
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  run keyword And Continue on Failure  Should Be Equal as Integers     ${return_dn.status}   200       Error retrieving dbgEtherStats object for interface with DN "${dn}" (2nd collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving CRC errors for interface with DN "${dn}" (2nd collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  ${crc_err} =   Convert to Integer  ${return_dn.payload[0].rmonEtherStats.attributes.cRCAlignErrors}
    \  Set To Dictionary    ${dn_crc_two}  ${dn}  ${crc_err}
    \  # Collect and store ingress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfIn
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfIn object for interface with DN "${dn}" (2nd collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving ingress errors and discards for interface with DN "${dn}" (2nd collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfIn.attributes.discards}
    \  Set To Dictionary    ${dn_rxerr_two}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_rxdsc_two}  ${dn}  ${dsc_err}
    \  # Collect and store egress errors and discards
    \  ${dn}=         Set Variable  ${intf.l1PhysIf.attributes.dn}
    \  ${uri_dn}=     Set Variable  /api/node/mo/${dn}/dbgIfOut
    \  ${return_dn}=  via ACI REST API retrieve "${uri_dn}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${return_dn.status}   200            Error retrieving dbgIfOut object for interface with DN "${dn}" (2nd collection)      values=False
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword And Continue on Failure
    \  ...  Fail  Error retrieving egress errors and discards for interface with DN "${dn}" (2nd collection)
	\  run keyword if  "${return_dn.totalCount}" == "0"  run keyword
    \  ...  Continue For Loop 
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  ${err_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.errors}
    \  Should Be String      ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  ${dsc_err} =   Convert to Integer  ${return_dn.payload[0].rmonIfOut.attributes.discards}
    \  Set To Dictionary    ${dn_txerr_two}  ${dn}  ${err_err}
    \  Set To Dictionary    ${dn_txdsc_two}  ${dn}  ${dsc_err}
    # Make dictionaries available for the counter comparison tests
    Set Suite Variable  ${dn_crc_one}
    Set Suite Variable  ${dn_rxerr_one}
    Set Suite Variable  ${dn_rxdsc_one}
    Set Suite Variable  ${dn_txerr_one}
    Set Suite Variable  ${dn_txdsc_one}
    Set Suite Variable  ${dn_crc_two}
    Set Suite Variable  ${dn_rxerr_two}
    Set Suite Variable  ${dn_rxdsc_two}
    Set Suite Variable  ${dn_txerr_two}
    Set Suite Variable  ${dn_txdsc_two}
    
Verify ACI Interface Counters (CRC error)
    [Documentation]  Verify that interface CRC error counters are not incrementing on any node/interface
    [Tags]      aci-operations  aci-fabric-counters
    Variable Should Exist  ${dn_crc_one}  Collection of interface CRC counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_crc_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected CRC counter 1st database does not contain any entries                values=False
    Variable Should Exist  ${dn_crc_two}  Collection of interface CRC counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_crc_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected CRC counter 2nd database does not contain any entries                values=False
    # Compare two respective dictionaries for counter increment
    :FOR  ${key}  IN  @{dn_crc_one}
    \  ${crc_one}=    Get From Dictionary    ${dn_crc_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_crc_two}  ${key}
    \  ${crc_two}=    Get From Dictionary    ${dn_crc_two}  ${key}
    \  Run keyword if  ${crc_two} > ${crc_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has CRC errors incrementing

Verify ACI Interface Counters (input error and discard)
    [Documentation]  Verify that interface input error and discard counters are not incrementing on any node/interface
    [Tags]      aci-operations  aci-fabric-counters
    Variable Should Exist  ${dn_rxerr_one}  Collection of interface RX error counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_rxerr_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX error counter 1st database does not contain any entries                   values=False
    Variable Should Exist  ${dn_rxerr_two}  Collection of interface RX error counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_rxerr_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX error counter 2nd database does not contain any entries                   values=False
    Variable Should Exist  ${dn_rxdsc_one}  Collection of interface RX discard counter failed 1st time, see previous test case for details
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX discard counter 1st database does not contain any entries                 values=False
    Variable Should Exist  ${dn_rxdsc_two}  Collection of interface RX discard counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_rxdsc_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected RX discard counter 2nd database does not contain any entries                 values=False
    # Compare two respective dictionaries for counter increment
    :FOR  ${key}  IN  @{dn_rxerr_one}
    \  ${err_one}=    Get From Dictionary    ${dn_rxerr_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_rxerr_two}  ${key}
    \  ${err_two}=    Get From Dictionary    ${dn_rxerr_two}  ${key}
    \  Run keyword if  ${err_two} > ${err_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has input errors incrementing
    \  Dictionary Should Contain Key    ${dn_rxdsc_one}  ${key}
    \  ${dsc_one}=    Get From Dictionary    ${dn_rxdsc_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_rxdsc_two}  ${key}
    \  ${dsc_two}=    Get From Dictionary    ${dn_rxdsc_two}  ${key}
    \  Run keyword if  ${dsc_two} > ${dsc_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has input discards incrementing

Verify ACI Interface Counters (output error and discard)
    [Documentation]  Verify that interface output error and discard counters are not incrementing on any node/interface
    [Tags]      aci-operations  aci-fabric-counters
    Variable Should Exist  ${dn_txerr_one}  Collection of interface TX error counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txerr_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX error counter 1st database does not contain any entries                   values=False
    Variable Should Exist  ${dn_txerr_two}  Collection of interface TX error counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txerr_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX error counter 2nd database does not contain any entries                   values=False
    Variable Should Exist  ${dn_txdsc_one}  Collection of interface TX discard counter failed 1st time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txdsc_one}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX discard counter 1st database does not contain any entries                 values=False
    Variable Should Exist  ${dn_txdsc_two}  Collection of interface TX discard counter failed 2nd time, see previous test case for details
    ${dn_len}=  Get Length  ${dn_txdsc_two}
    Should Not Be Equal As Integers    ${dn_len}  0  Collected TX discard counter 2nd database does not contain any entries                 values=False
    # Compare two respective dictionaries for counter increment
    :FOR  ${key}  IN  @{dn_txerr_one}
    \  ${err_one}=    Get From Dictionary    ${dn_txerr_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_txerr_two}  ${key}
    \  ${err_two}=    Get From Dictionary    ${dn_txerr_two}  ${key}
    \  Run keyword if  ${err_two} > ${err_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has output errors incrementing
    \  Dictionary Should Contain Key    ${dn_txdsc_one}  ${key}
    \  ${dsc_one}=    Get From Dictionary    ${dn_txdsc_one}  ${key}
    \  Dictionary Should Contain Key    ${dn_txdsc_two}  ${key}
    \  ${dsc_two}=    Get From Dictionary    ${dn_txdsc_two}  ${key}
    \  Run keyword if  ${dsc_two} > ${dsc_one}  Run keyword And Continue on Failure
    \  ...  Fail  Interface with DN "${key}" has output discards incrementing

