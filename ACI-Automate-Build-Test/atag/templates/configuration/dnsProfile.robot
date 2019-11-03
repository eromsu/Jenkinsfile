{#
Verifies DNS Profile configuration including association to management EPG.
Optionally are DNS domain name verified by this template.
#}
{% if config['domain_name'] and config['domain_name'] != "" %}
Verify ACI DNS Profile Configuration - Profile '{{config['name']}}', Domain Name '{{config['domain_name']}}'
{% else %}
Verify ACI DNS Profile Configuration - Profile '{{config['name']}}'
{% endif %}
    [Documentation]   Verifies that ACI DNS Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name: {{config['name']}}
    ...  - Description: {{config['description']}}
    ...  - Management EPG: {{config['management_epg']}}
    {% if config['domain_name'] and config['domain_name'] != "" %}
    ...  - Domain Name: {{config['domain_name']}}
    ...  - Default Domain Name: {{config['is_default_domain']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-dns
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (DNS Profile)		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		DNS Profile not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProfile.attributes.epgDn}"   "uni/tn-mgmt/mgmtp-default/{{config['management_epg']}}-default"       Management EPG not matching expected configuration              values=False
    {% if config['description'] and config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].dnsProfile.attributes.descr}"   "{{config['description']}}"                                            Description not matching expected configuration                 values=False
    {% endif %}
    {% if config['domain_name'] and config['domain_name'] != "" %}
	${uri} =  Set Variable  	/api/mo/uni/fabric/dnsp-{{config['name']}}/dom-{{config['domain_name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Domain Name)		values=False
	Should Be Equal as Integers     ${return.totalCount}  1            Domain Name not associated with DNS Profile	            values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].dnsDomain.attributes.isDefault}"  "{{config['is_default_domain']}}"	Default Domain Name Setting not matching expected configuration		        values=False
    {% endif %}

