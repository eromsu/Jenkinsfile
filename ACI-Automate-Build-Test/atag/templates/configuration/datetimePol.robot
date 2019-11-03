{#
Verifies Datatime / NTP Profile configuration.
#}
Verify ACI Datetime Profile Configuration - Profile '{{config['name']}}'
    [Documentation]   Verifies that ACI Datetime Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name: {{config['name']}}
    ...  - Description: {{config['description']}}
    ...  - Admin State: {{config['admin_state']}}
    ...  - Authentication State: {{config['authentication_state']}}
    ...  - Server State: {{config['server_state']}}
    ...  - Master Mode: {{config['master_mode']}}
    ...  - Stratum Value: {{config['stratum_value']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-ntp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/time-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Datetime Profile not defined		values=False
    {% if config['description'] and config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.descr}"   "{{config['description']}}"                                            Description not matching expected configuration                 values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.adminSt}"   "{{config['admin_state']}}"                                          Admin State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.authSt}"   "{{config['authentication_state']}}"                                  Authentication State not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.serverState}"   "{{config['server_state']}}"                                     Server State not matching expected configuration                 values=False
    {% if config['server_state'] == "enabled" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.masterMode}"   "{{config['master_mode']}}"                                       Master Mode not matching expected configuration                 values=False
    {% endif %}
    {% if config['server_state'] == "enabled" and config['master_mode'] == "enabled"%}
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimePol.attributes.StratumValue}"   "{{config['stratum_value']}}"                                   Stratum Value not matching expected configuration                 values=False
    {% endif %}

