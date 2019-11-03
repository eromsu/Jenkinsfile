{#
Checks VRF for faults.

> This test case template looks at the total number of faults regardless whether they are acknowledged or not.
#}
Checking ACI VRF for Faults - Tenant {{config['tenant']}}, VRF {{config['name']}}
    [Documentation]   Verifies ACI faults for VRF '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-vrf
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${minor_count} minor faults (passing threshold {{config['minor']}})"

