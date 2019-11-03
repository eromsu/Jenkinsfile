{#
Verifies Application Profile configuration.

> The configuration of child objects like EPGs, etc. are not verified in this test case template.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['unspecified', 'level1', 'level2', 'level3'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
Verify ACI Application Profile Configuration - Tenant {{config['tenant']}}, App Profile {{config['name']}}
    [Documentation]   Verifies that ACI Application Profile '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Application Profile Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - QoS Class: {{config['qos_class']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-ap
    # Retrieve AP
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	Should Be Equal as Strings      ${return.payload[0].fvAp.attributes.name}   {{config['name']}}      Failure retreiving configuration		                          values=False
  {% if config['nameAlias'] != "" %}
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.nameAlias}"  "{{config['nameAlias']}}"             Name alias not matching expected configuration                       values=False
  {% endif %}
  {% if config['description'] != "" %}
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.descr}"  "{{config['description']}}"               Description not matching expected configuration                       values=False
  {% endif %}
  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAp.attributes.prio}"  "{{config['qos_class']}}"                  QoS Class not matching expected configuration                       values=False

