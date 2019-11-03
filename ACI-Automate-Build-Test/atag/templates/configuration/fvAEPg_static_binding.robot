{#
Verified EPG static binding to either
* A Switch Access Port
* A Switch Port-Channel
* A Switch pair virtual Port-Channel

Binding mode can be:
* regular = Trunk mode
* native = Access mode with 802.1p
* untagged = Access mode untagged

> The Tenant, Application Profile and EPG must pre-exist.
#}
{% if 'deployImedcy' not in config %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% elif config['deployImedcy'] not in ['immediate', 'lazy'] %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% endif %}
{% if config['static_binding_type'] == "vPC" %}
    {% set tDn %}topology/pod-{{config['pod_id']}}/protpaths-{{config['left_node_id']}}-{{config['right_node_id']}}/pathep-[{{config['interface_policy_group']}}]{% endset %}
{% elif config['static_binding_type'] == "PC" %}
    {% set tDn %}topology/pod-{{config['pod_id']}}/paths-{{config['left_node_id']}}/pathep-[{{config['interface_policy_group']}}]{% endset %}
{% elif config['static_binding_type'] == "Access" %}
    {% set tDn %}topology/pod-{{config['pod_id']}}/paths-{{config['left_node_id']}}/pathep-[eth{{config['access_port_id']}}]{% endset %}
{% endif %}
{% if config['static_binding_type'] == "vPC" %}
Verify ACI EPG Binding Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}, Interface Policy Group {{config['interface_policy_group']}}
{% elif config['static_binding_type'] == "PC" %}
Verify ACI EPG Binding Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}, Interface Policy Group {{config['interface_policy_group']}}
{% elif config['static_binding_type'] == "Access" %}
Verify ACI EPG Binding Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}, Node {{config['left_node_id']}}, Interface eth{{config['access_port_id']}}
{% endif %}
    [Documentation]   Verifies that ACI EPG Binding for '{{config['name']}}' are configured under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  with the parameters defined in the NIP
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    ...  - POD ID: {{config['pod_id']}}
	{% if config['static_binding_type'] == "vPC" %}
    ...  - Node (left): {{config['left_node_id']}}
    ...  - Node (right): {{config['right_node_id']}}
	...  - Interface Policy Group: {{config['interface_policy_group']}}
	{% elif config['static_binding_type'] == "PC" %}
	...  - Node: {{config['left_node_id']}}
	...  - Interface Policy Group: {{config['interface_policy_group']}}
	{% elif config['static_binding_type'] == "Access" %}
	...  - Node: {{config['left_node_id']}}
 	...  - Interface: eth{{config['access_port_id']}}
    {% endif %}
	...  - Encapsulation: vlan-{{config['encap_vlan_id']}}
    ...  - Deployment Immediacy: {{config['deployImedcy']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rspathAtt-[{{tDn}}]
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}  1		Interface not having a static binding for the EPG		values=False
	Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.tDn}"   "{{tDn}}"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.mode}"  "{{config['mode']}}"               Binding Mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.instrImedcy}"  "{{config['deployImedcy']}}"               Deployment Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsPathAtt.attributes.encap}"  "vlan-{{config['encap_vlan_id']}}"               VLAN Encapsulation not matching expected configuration                values=False

