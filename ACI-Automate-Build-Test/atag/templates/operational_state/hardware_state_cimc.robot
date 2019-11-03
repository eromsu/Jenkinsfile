{#
Checks APIC hardware status LEDs

The following status LEDs are verified:
- PSU
- Temperature
- FAN
- Overall Health
- DIMM (memory)

> Verfification are done through the CIMC (SSH connection).
> The tests fails if the LEDs are not green
#}
{% set cimc_ip = config['cimc_ip'].split('/') %}
Verify APIC Hardware State - APIC {{config['apic_id']}}
    [Documentation]  Verifies the APIC hardware health through the CIMC interface.
    ...  APIC Node ID: {{config['apic_id']}}
    ...  APIC Hostname: {{config['apic_hostname']}}
    ...  CIMC IP: {{ cimc_ip[0] }}
    [Tags]      aci-operations  aci-operations-hardware
    # Login
    connect to device "{{config['apic_hostname']}}_cimc" via "cli"
    # Get Env LED status
    execute command "scope chassis" on device "{{config['apic_hostname']}}_cimc"
    ${output}=  execute command "show led" on device "{{config['apic_hostname']}}_cimc"
    # Analyse output
    @{table_headers} =  Create List    LED Name   LED State   LED Color
    ${result}=  parse table output "${output}" using headers "${table_headers}" and delimiter ""
    #@{status}=   Get Value From Json   ${result}   $[?(@.'LED Name'=='LED_PSU_STATUS')]['LED State','LED Color']
    ${psu_led_status}=     Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_PSU_STATUS"
    ${psu_led_color}=      Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_PSU_STATUS"
    ${temp_led_status}=    Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_TEMP_STATUS"
    ${temp_led_color}=     Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_TEMP_STATUS"
    ${fan_led_status}=     Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_FAN_STATUS"
    ${fan_led_color}=      Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_FAN_STATUS"
    ${hlth_led_status}=    Get Value From JSON "${result}" for key "LED State" where "LED Name" is "LED_HLTH_STATUS"
    ${hlth_led_color}=     Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "LED_HLTH_STATUS"
    ${dimm_led_status}=    Get Value From JSON "${result}" for key "LED State" where "LED Name" is "OVERALL_DIMM_STATUS"
    ${dimm_led_color}=     Get Value From JSON "${result}" for key "LED Color" where "LED Name" is "OVERALL_DIMM_STATUS"
    Run keyword And Continue on Failure     Should be Equal     ${psu_led_status}   ON      PSU LED not turned on       values=False
    Run keyword And Continue on Failure     Should be Equal     ${psu_led_color}    GREEN   PSU LED not green           values=False
    Run keyword And Continue on Failure     Should be Equal     ${temp_led_status}  ON      TEMP LED not turned on      values=False
    Run keyword And Continue on Failure     Should be Equal     ${temp_led_color}   GREEN   TEMP LED not green          values=False
    Run keyword And Continue on Failure     Should be Equal     ${fan_led_status}   ON      FAN LED not turned on       values=False
    Run keyword And Continue on Failure     Should be Equal     ${fan_led_color}    GREEN   FAN LED not green           values=False
    Run keyword And Continue on Failure     Should be Equal     ${hlth_led_status}  ON      Health LED not turned on    values=False
    Run keyword And Continue on Failure     Should be Equal     ${hlth_led_color}   GREEN   Health LED not green        values=False
    Run keyword And Continue on Failure     Should be Equal     ${dimm_led_status}  ON      DIMM LED not turned on      values=False
    Run keyword And Continue on Failure     Should be Equal     ${dimm_led_color}   GREEN   DIMM LED not green          values=False



