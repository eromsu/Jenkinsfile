{#
Verifies IPv4 and IPv6 BGP Route-Target Profile configuration under a VRF.

> The configuration the VRF itself are not verified in this test case template.
#}
Verify ACI VRF BGP Route-Target Configuration - Tenant {{config['tenant']}}, VRF {{config['vrfName']}}, Address-Family {{config['addressFamily']}}, Route-Target: {{config['routeTarget']}}
    [Documentation]   Verifies that ACI BGP Route-Target Profile for VRF '{{config['vrfName']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['vrfName']}}
    ...  - Address-Family: {{config['addressFamily']}}
    ...  - BGP Route-Target: {{config['routeTarget']}}
    ...  - BGP Route-Target Type: {{config['routeTargetType']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve BGP Route Target
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['vrfName']}}/rtp-{{config['addressFamily']}}/rt-[{{config['routeTarget']}}]-{{config['routeTargetType']}}
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}    1		BGP Route-Target not configured with expected parameters        values=False

