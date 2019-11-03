{#
Verifies Leaf/Spine Interface Profile configuration

> Interface Selector and associated interface policy group are not verified by this template.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if config['profile_type'] == "leaf" %}
Verify ACI Leaf Interface Profile Configuration - Profile {{config['name']}}
    [Documentation]   Verifies that Leaf Interface Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraAccPortP.attributes.name}   {{config['name']}}      Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAccPortP.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAccPortP.attributes.nameAlias}"  "{{config['name_alias']}}"                    Name Alias not matching expected configuration                 values=False
    {% endif %}
{% elif config['profile_type'] == "spine" %}
Verify ACI Spine Interface Profile Configuration - Profile {{config['name']}}
    [Documentation]   Verifies that Spine Interface Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Profile does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpAccPortP.attributes.name}   {{config['name']}}        Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSpAccPortP.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSpAccPortP.attributes.nameAlias}"  "{{config['name_alias']}}"                    Name Alias not matching expected configuration                 values=False
    {% endif %}
{% endif %}

