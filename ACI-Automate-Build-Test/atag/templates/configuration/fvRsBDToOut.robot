{# 
Verifies Bridge Domain L3Out Association configuration

> The BD and L3out them itself are not verified in this test case template.
#}
Verify ACI BD L3Out Configuration - Tenant {{config['tenant']}}, BD {{config['bd_name']}}, L3Out {{config['l3out_name']}}
    [Documentation]   Verifies that ACI BD L3Out '{{config['l3out_name']}}' under tenant '{{config['tenant']}}', BD '{{config['bridge_domain']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['bd_name']}}
    ...  - Associated L3Out: {{config['l3out_name']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bd_name']}}/rsBDToOut-{{config['l3out_name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		L3Out not associated with BD		values=False
	Should Be Equal as Strings      ${return.payload[0].fvRsBDToOut.attributes.tnL3extOutName}   {{config['l3out_name']}}      Failure retreiving configuration		                          values=False

