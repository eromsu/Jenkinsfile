{#
Verifies L3Out Interface Profile configuration

> The Tenant, L3Out, and Node Profile must pre-exist.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'right_node_id' not in config %}
  {% set x=config.__setitem__('right_node_id', '') %}
{% endif %}
{% if 'int_pol_group' not in config %}
  {% set x=config.__setitem__('int_pol_group', '') %}
{% endif %}
{% if 'port_id' not in config %}
  {% set x=config.__setitem__('port_id', '') %}
{% endif %}
{% if 'ip_addr_side_b' not in config %}
  {% set x=config.__setitem__('ip_addr_side_b', '') %}
{% endif %}
{% if 'ospf_interface_policy' not in config %}
  {% set x=config.__setitem__('ospf_interface_policy', '') %}
{% endif %}
{% if 'mtu' not in config or config['mtu'] == "" %}
  {% set x=config.__setitem__('mtu', 'inherit') %}
{% endif %}
{% if 'autostate' not in config %}
  {% set x=config.__setitem__('autostate', 'disabled') %}
{% elif config['autostate'] not in ['enabled', 'disabled'] %}
  {% set x=config.__setitem__('autostate', 'disabled') %}
{% endif %}
{% if config['path_type'] == 'vPC' %}
  {% set path = "topology/pod-" + config['pod_id'] + "/protpaths-" + config['left_node_id'] + "-" + config['right_node_id'] + "/pathep-[" + config['int_pol_group'] + "]" %}
{% elif config['path_type'] == 'PC' %}
  {% set path = "topology/pod-" + config['pod_id'] + "/paths-" + config['left_node_id'] + "/pathep-[" + config['int_pol_group'] + "]" %}
{% else %}
  {% set path = "topology/pod-" + config['pod_id'] + "/paths-" + config['left_node_id'] + "/pathep-[eth" + config['port_id'] + "]" %}
{% endif %}
{% if config['interface_type'] == 'svi' %}
  {% set iftype = "ext-svi" %}
  {% set encap = "vlan-" + config['vlan_encap_id'] %}
{% elif config['interface_type'] == 'routed_sub' %}
  {% set iftype = "sub-interface" %}
  {% set encap = "vlan-" + config['vlan_encap_id'] %}
{% else %}
  {% set iftype = "l3-port" %}
  {% set encap = "unknown" %}
{% endif %}
Verify ACI L3Out Interface Profile Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['l3out_node_profile']}}, Interface Profile {{config['name']}}
    [Documentation]   Verifies that ACI L3Out Interface Profile '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}', Node Profile '{{config['l3out_node_profile']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - Interface Profile Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Interface Type: {{config['interface_type']}}
    ...  - Interface Path Type: {{config['path_type']}}
    {% if config['path_type'] == 'vPC' %}
    ...  - POD: {{config['pod_id']}}
    ...  - Node ID (side A): {{config['left_node_id']}}
    ...  - Node ID (side B: {{config['right_node_id']}}
    ...  - Interface Policy Group: {{config['int_pol_group']}}
    {% elif config['path_type'] == 'PC' %}
    ...  - POD: {{config['pod_id']}}
    ...  - Node ID: {{config['left_node_id']}}
    ...  - Interface Policy Group: {{config['int_pol_group']}}
    {% else %}
    ...  - POD: {{config['pod_id']}}
    ...  - Node ID: {{config['left_node_id']}}
    ...  - Interface ID: eth{{config['port_id']}}
    {% endif %}
    ...  - Interface Type: {{config['interface_type']}}
    {% if config['interface_type'] == 'svi' %}
    ...  - Interface Mode: {{config['trunk_mode']}}
    ...  - Encapsulation: vlan-{{config['vlan_encap_id']}}
    ...  - IP (side A): {{config['ip_addr_side_a']}}
    ...  - IP (side B): {{config['ip_addr_side_b']}}
    ...  - MTU: {{config['mtu']}}
    {% elif config['interface_type'] == 'routed_sub' %}
    ...  - Interface Mode: {{config['trunk_mode']}}
    ...  - Encapsulation: vlan-{{config['vlan_encap_id']}}
    ...  - IP: {{config['ip_addr_side_a']}}
    ...  - MTU: {{config['mtu']}}
    {% else %}
    ...  - Interface Mode: {{config['trunk_mode']}}
    ...  - Encapsulation: unknown
    ...  - IP: {{config['ip_addr_side_a']}}
    ...  - MTU: {{config['mtu']}}
    {% endif %}
    {% if config['ospf_interface_policy'] != "" %}
    ...  - OSPF Interface Policy: {{config['ospf_interface_policy']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/lifp-{{config['name']}}
    ${filter} =  Set Variable  rsp-subtree=full&rsp-subtree-class=l3extRsPathL3OutAtt
    ${return} =  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Interface Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.nameAlias}"  "{{config['name_alias']}}"                  Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.attributes.descr}"  "{{config['description']}}"                     Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.tDn}"  "{{path}}"                        Interface Policy Group/Interface ID, Node(s), or POD not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.ifInstT}"  "{{iftype}}"                  Interface Type not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.encap}"  "{{encap}}"                     Encapsulation not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mode}"  "{{config['trunk_mode']}}"       Interface Mode not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.mtu}"  "{{config['mtu']}}"               MTU not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.autostate}"  "{{config['autostate']}}"   Autostate not matching expected configuration                 values=False
    {% if config['path_type'] == 'vPC' %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.addr}"  "0.0.0.0"                        'Global' IP Address not matching expected configuration                 values=False
    : FOR  ${member}  IN  @{return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.children}
    \  run keyword if  "${member.l3extMember.attributes.side}" == "A"
    \  ...  Run keyword And Continue on Failure  Should Be Equal as Strings  "${member.l3extMember.attributes.addr}"  "{{config['ip_addr_side_a']}}"    Side A IP Address not matching expected configuration                 values=False
    \  run keyword if  "${member.l3extMember.attributes.side}" == "B"
    \  ...  Run keyword And Continue on Failure  Should Be Equal as Strings  "${member.l3extMember.attributes.addr}"  "{{config['ip_addr_side_b']}}"    Side B IP Address not matching expected configuration                 values=False
    {% else %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLIfP.children[0].l3extRsPathL3OutAtt.attributes.addr}"  "{{config['ip_addr_side_a']}}"   IP Address not matching expected configuration                 values=False
    {% endif %}
    {% if config['ospf_interface_policy'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/lifp-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retrieving associated OSPF Interface Profile		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfIfP.attributes.name}"  "{{config['ospf_interface_policy']}}"      Router ID not matching expected configuration                 values=False
    {% endif %}

