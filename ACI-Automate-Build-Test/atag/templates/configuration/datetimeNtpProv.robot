{#
Verifies Datetime NTP Provider configuration.
#}
{% if 'min_poll' not in config or config['min_poll'] == "" %}
  {% set x=config.__setitem__('min_poll', '4') %}
{% endif %}
{% if 'max_poll' not in config or config['max_poll'] == "" %}
  {% set x=config.__setitem__('max_poll', '6') %}
{% endif %}
Verify ACI Datetime NTP Provider Configuration - Provider '{{config['name']}}'
    [Documentation]   Verifies that ACI NTP Provider '{{config['name']}}' are configured with the expected parameters
    ...  - Datetime Profile Name: {{config['datetime_pol_name']}}
    ...  - NTP Provider: {{config['name']}}
    ...  - Minimum Poll Interval: {{config['min_poll']}}
    ...  - Maximum Poll Interval: {{config['max_poll']}}
    ...  - Preferred: {{config['is_preferred']}}
    ...  - Management EPG: {{config['management_epg']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-ntp
    # Retrieve configuration
	${uri} =  Set Variable  	/api/mo/uni/fabric/time-{{config['datetime_pol_name']}}/ntpprov-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		NTP Provider not defined		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.minPoll}"       "{{config['min_poll']}}"                                    Minimum Poll Interval not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.maxPoll}"       "{{config['max_poll']}}"                                    Maximum Poll Interval not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.preferred}"     "{{config['is_preferred']}}"                                Preferred setting not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings		"${return.payload[0].datetimeNtpProv.attributes.epgDn}"         "uni/tn-mgmt/mgmtp-default/{{config['management_epg']}}-default"            Management EPG not matching expected configuration                 values=False

