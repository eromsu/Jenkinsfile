{#
Verifies Contract configuration

If not specified:
* QoS Class assumed to be configured as unspecified
* targetDscp assumed to be configured as unspecified

> The Tenant must pre-exist.
#}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['level1', 'level2', 'level3', 'unspecified'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
{% if 'target_dscp' not in config %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% elif config['target_dscp'] not in ['unspecified', 'CS0', 'CS1', 'AF11', 'AF12', 'AF13', 'CS2', 'AF21', 'AF22', 'AF23', 'CS3', 'AF31', 'AF32', 'AF33', 'CS4', 'AF41', 'AF42', 'AF43', 'VA', 'CS5', 'EF', 'CS6', 'CS7'] %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
{% if 'tag' not in config %}
  {% set x=config.__setitem__('tag', '') %}
{% endif %}
Verify ACI Contract Configuration - Tenant {{config['tenant']}}, Contract {{config['name']}}
    [Documentation]   Verifies that ACI Contract '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Contract Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Scope: {{config['scope']}}
    ...  - Priority / QoS Class: {{config['qos_class']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    {% if config['tag'] != "" %}
    ...  - Tag: {{config['tag']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
	# Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Contract does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.scope}"  "{{config['scope']}}"                          Scope not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.prio}"  "{{config['qos_class']}}"                       Priority / QoS Class not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzBrCP.attributes.targetDscp}"  "{{config['target_dscp']}}"               Target DSCP not matching expected configuration                values=False
    {% if config['tag'] != '' %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['name']}}/tag-{{config['tag']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Tag not matching expected configuration		values=False
    {% endif %}

