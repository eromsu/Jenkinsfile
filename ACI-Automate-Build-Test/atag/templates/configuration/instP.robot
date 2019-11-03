{#
Verifies L3Out External EPG configuration

> The Tenant, L3Out, and Node Profile must pre-exist.
> The External EPG subnet are not verified as part of this template
> The contract consume/provide relationship for the EPG is not verified as part of this template
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'prefered_group_member' not in config or config['prefered_group_member'] == "" %}
  {% set x=config.__setitem__('prefered_group_member', 'exclude') %}
{% endif %}
{% if 'qos_class' not in config or config['qos_class'] == "" %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
{% if 'target_dscp' not in config or config['target_dscp'] == "" %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
Verify ACI L3Out External EPG Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['name']}}
    [Documentation]   Verifies that ACI L3Out External EPG '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3_out']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3_out']}}
    ...  - External EPG: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Prefered Group Member: {{config['prefered_group_member']}}
    ...  - QoS Class: {{config['qos_class']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out External EPG does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.nameAlias}"  "{{config['name_alias']}}"                  Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.descr}"  "{{config['description']}}"                     Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.prefGrMemb}"  "{{config['prefered_group_member']}}"      Preferred Group Member not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.prio}"  "{{config['qos_class']}}"                        QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extInstP.attributes.targetDscp}"  "{{config['target_dscp']}}"                Target DSCP not matching expected configuration                 values=False

