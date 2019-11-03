{#
Checks that ACI user login

> This test case template verifies user login though the REST API.
#}
Verify ACI Login
    [Documentation]   Verifies ACI user login
    [Tags]      aci-operations  aci-fabric-aaa
    ${auth_cookie}=  ACI REST login on ${apic}
    log  "Authentication successful, received authentication token '${auth_cookie}"

