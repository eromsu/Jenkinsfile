{#
Verifies Contract Subject configuration

If not specified:
* Target DSCP assumed to be configured as unspecified
* QoS Priority assumed to be configured as unspecified
* Apply Both Directions to be enabled
* Reverse Filer Ports to be enabled

> The Tenant and Contract must pre-exist.
> Action, Priority, and Directives of associated Contract Filters are not verified by this template
> Filters no applied in both directions are not verified by this template. If this happes scenario occurs will it be highlighted with a warning.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['level1', 'level2', 'level3', 'unspecified'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
{% if 'apply_both_direction' not in config %}
  {% set x=config.__setitem__('apply_both_direction', 'yes') %}
{% elif config['apply_both_direction'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('apply_both_direction', 'yes') %}
{% endif %}
{% if 'reverse_filter_port' not in config %}
  {% set x=config.__setitem__('reverse_filter_port', 'yes') %}
{% elif config['reverse_filter_port'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('reverse_filter_port', 'yes') %}
{% endif %}
{% if 'target_dscp' not in config %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% elif config['target_dscp'] not in ['unspecified', 'CS0', 'CS1', 'AF11', 'AF12', 'AF13', 'CS2', 'AF21', 'AF22', 'AF23', 'CS3', 'AF31', 'AF32', 'AF33', 'CS4', 'AF41', 'AF42', 'AF43', 'VA', 'CS5', 'EF', 'CS6', 'CS7'] %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
{% if config['filter'] != "" %}
Verify ACI Contract Subject Configuration Tenant {{config['tenant']}}, Contract {{config['contract']}}, Subject {{config['name']}}, Filter {{config['filter']}}
{% else %}
Verify ACI Contract Subject Configuration Tenant {{config['tenant']}}, Contract {{config['contract']}}, Subject {{config['name']}}
{% endif %}
    [Documentation]   Verifies that ACI Contract Subject '{{config['name']}}' under tenant '{{config['tenant']}}', contract '{{config['contract']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Contract Name: {{config['contract']}}
    ...  - Subject Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    ...  - Priority / QoS Class: {{config['qos_class']}}
    ...  - Apply Both Directions: {{config['apply_both_direction']}}
    ...  - Reverse Filter Ports: {{config['reverse_filter_port']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    {% if config['filter'] != "" %}
    ...  - Associated Filter: {{config['filter']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['contract']}}/subj-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract Subject does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                values=False
    {% endif %}
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.prio}"  "{{config['qos_class']}}"                       Priority / QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzSubj.attributes.revFltPorts}"  "{{config['reverse_filter_port']}}"      Reverse Filter Ports not matching expected configuration                 values=False
    # Verify associated filter
    {% if config['filter'] != "" and config['apply_both_direction'] == "yes" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['contract']}}/subj-{{config['name']}}/rssubjFiltAtt-{{config['filter']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Filter not associated with Contract Subject		values=False
    {% else %}
    log  Configuration of Filter Association for Tenant '{{config['tenant']}}', Contract '{{config['contract']}}', Subject '{{config['name']}}' not verfied as config verfication of filter association are only supported for filters applied in both directions by the test case           WARN
    {% endif %}

