{#
Verifies Contract Filter configuration

> The configuration of filter entries are not verified in this test case template.

#}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
Verify ACI Contract Filter Configuration - Tenant {{config['tenant']}}, Filter {{config['name']}}
    [Documentation]   Verifies that ACI Contract Filter '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/flt-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzFilter.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                 values=False
    {% endif %}

