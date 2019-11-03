{#
Checks within a specivfied VRF the presense of a particular prefix within the routing table of all leafs,
where the VRF have been deployed.

> This testcase template only works for external routes, as ACI internal routes may intentionally not be programmed on all leafs.
> This testcase template only works for IPv4 prefixes.
#}
{% set prefix_config_parameter = config['tenant'] + "|" + config['name'] + "|routes" %}
{% if config[prefix_config_parameter] %}
{% for prefix in config[prefix_config_parameter] %}
Verify ACI IPv4 Route - Tenant {{config['tenant']}}, VRF {{config['name']}}, Prefix {{prefix}}
    ${apic} =  Set Variable  apic3
    [Documentation]   Verifies a route towards IPv4 prefix '{{prefix}}' is present on at least one leaf within Tenant '{{config['tenant']}}', VRF '{{config['name']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['name']}}
    ...  - Prefix: {{prefix}}
    [Tags]      aci-operational-state  aci-tenant  aci-tenant-vrf  aci-tenant-vrf-route
    # Retrieve list of nodes with VRF deployed
    log  Retrieving host with VRF deployed
    ${uri} =  Set Variable  /api/node/class/uribv4Dom
    ${filter} =  Set Variable  rsp-subtree-class=uribv4Route&query-target-filter=eq(uribv4Dom.name,"{{config['tenant']}}:{{config['name']}}")
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200      Failure executing API call		values=False
    # Verify if VRF are deployed on any node
    run keyword if  ${return.totalCount} == 0  run keyword
    ...  Fail  VRF '{{config['name']}}' under Tenant '{{config['tenant']}}' are not deployed on any fabric node
    # Iterate through the nodes with VRF deployed and check if prefix is present in urib
    log  Iterate through the nodes with VRF deployed and check if prefix is present in urib
    : FOR   ${node}  IN  @{return.payload}
    \  # Extract node id from dn
    \  ${matches} =  Get Regexp Matches  ${node.uribv4Dom.attributes.dn}  pod-\\d+\/node-\\d+
    \  ${node_id} =  Set Variable  ${matches[0]}
    \  log  Inspecting uribv4 on node '${node_id}'
    \  # Retrieve uribv4 from node
    \  ${uri} =   Set Variable  /api/mo/topology/${node_id}/sys/uribv4/dom-{{config['tenant']}}:{{config['name']}}/db-rt
    \  ${filter} =  Set Variable  rsp-subtree=children
    \  ${urib}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    \  Should Be Equal as Integers     ${urib.status}   200     Failure executing API call		values=False
    \  ${urib_entries} =  Set Variable  ${urib.payload[0].uribv4Db.children}
    \  ${match_count} =  Get ACI uribv4 Prefix Match Count  ${urib_entries}  {{prefix}}
    \  log  Prefix matched ${match_count} time within the urib of tenant '{{config['tenant']}}', vrf '{{config['name']}}' on node '${node_id}'
    \  run keyword if  ${match_count} == 0  run keyword
    \  ...  run keyword And Continue on Failure    Fail    Prefix '{{prefix}}' are not present in the routing table of node '${node_id}' under tenant '{{config['tenant']}}', vrf '{{config['name']}}'

{% endfor %}
{% endif %}
