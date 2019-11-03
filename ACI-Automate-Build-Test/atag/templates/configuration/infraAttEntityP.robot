{#
Verifies Access Attachable Entity Profile configuration including enabling of infra VLAN.

> The configuration of domain association are not verified in this test case template.
#}
{% if 'enable_infra_vlan' not in config %}
  {% set x=config.__setitem__('enable_infra_vlan', '') %}
{% endif %}
{% if 'infra_vlan' not in config %}
  {% set x=config.__setitem__('infra_vlan', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
Verify ACI AAEP Configuration - AAEP {{config['name']}}
    [Documentation]   Verifies that AAEP '{{config['name']}}' are configured with the expected parameters:
	...  - AAEP Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
	...  - AAEP Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
	...  - Description: {{config['description']}}
    {% endif %}
    {% if config['enable_infra_vlan'] != "" %}
	...  - Enable Infrastructure VLAN: {{config['enable_infra_vlan']}}
    {% endif %}
    {% if config['enable_infra_vlan'] == "yes" %}
	...  - Infrastructure VLAN: {{config['infra_vlan']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-aaep
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/attentp-{{config['name']}}
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraRsFuncToEpg
    ${return}  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	Should Be Equal as Strings      ${return.payload[0].infraAttEntityP.attributes.name}   {{config['name']}}                            Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAttEntityP.attributes.nameAlias}"  "{{config['nameAlias']}}"               	Name alias not matching expected configuration                values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraAttEntityP.attributes.descr}"  "{{config['description']}}"					Description not matching expected configuration               values=False
	{% endif %}
	{% if config['enable_infra_vlan'] == 'yes' %}
	# Check Infra VLAN
	Variable Should Exist  ${return.payload[0].infraAttEntityP.children}   Infrastructure VLAN not enabled, which are not matching expected configuration
	Should Be Equal as Strings  ${return.payload[0].infraAttEntityP.children[0].infraProvAcc.children[0].infraRsFuncToEpg.attributes.encap}  vlan-{{config['infra_vlan']}}	Infrastructure VLAN not matching expected configuration			values=False
	{% else %}
	Variable Should Not Exist  ${return.payload[0].infraAttEntityP.children}   Infrastructure VLAN enabled, which are not matching expected configuration
	{% endif %}

