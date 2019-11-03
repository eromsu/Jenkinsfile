{#
Checks VMware VMM Domain for faults.

> This test case template looks at the total number of faults regardless whether they are acknowledged or not.
#}
{% if 'vmm_type' not in config %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% elif config['target_dscp'] not in ['vmware'] %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% endif %}
{% if config['vmm_type'] == "vmware" %}
Checking VMware VMM Domain for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for VMware VMM Domain '{{config['name']}}'
    ...  - VMM Domain Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-vmm  aci-vmm-vmware
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% endif %}

