{#
Verifies APIC software version and running software mode
#}
{% if 'sw_running_mode' not in config %}
  {% set x=config.__setitem__('sw_running_mode', 'normal') %}
{% endif %}
Verify APIC Software Version - APIC {{config['apic_id']}}
    [Documentation]   Verifies that APIC {{config['apic_id']}} in POD {{config['pod_id']}} are running the expeced software version
    ...  POD: {{config['pod_id']}}
    ...  APIC ID: {{config['apic_id']}}
    ...  Software Version: {{config['software_version']}}
    ...  Software Running Mode: {{config['sw_running_mode']}}
    [Tags]      aci-operations  aci-software-version
    ${uri} =  Set Variable  /api/mo/topology/pod-{{config['pod_id']}}/node-{{config['apic_id']}}/sys/ctrlrfwstatuscont/ctrlrrunning
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving controller software information		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareCtrlrRunning.attributes.version}   {{config['software_version']}}         APIC controller not running expected software version                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].firmwareCtrlrRunning.attributes.mode}      {{config['sw_running_mode']}}          Software running mode not matching expected configration                    values=False

