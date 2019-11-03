{#
Verifies DNS Provider configuration.

* The DNS Profile must pre exist.
#}
Verify ACI DNS Profile Configuration - Profile '{{config['dns_profile_name']}}', DNS Server '{{config['dns_server_address']}}'
    [Documentation]   Verifies that ACI DNS Provider '{{config['dns_server_address']}}' under Profile '{{config['dns_profile_name']}}' are configured with the expected parameters
    ...  - DNS Profile Name: {{config['dns_profile_name']}}
    ...  - DNS Server Name: {{config['dns_server_name']}}
    ...  - DNS Server Address: {{config['dns_server_address']}}
    ...  - Preferred DNS Server: {{config['is_preferred_dns']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-{{config['dns_profile_name']}}/prov-[{{config['dns_server_address']}}]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.preferred}"     "{{config['is_preferred_dns']}}"       Preferred DNS Server Setting not matching expected configuration              values=False
    {% if config['dns_server_name'] and config['dns_server_name'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProv.attributes.name}"          "{{config['dns_server_name']}}"        DNS Server Name not matching expected configuration                 values=False
    {% endif %}

