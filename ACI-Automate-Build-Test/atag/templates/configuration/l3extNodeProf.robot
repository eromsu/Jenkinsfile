{#
Verifies L3Out Node Profile configuration

> The Tenant and L3Out must pre-exist.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'enable_golf' not in config %}
  {% set x=config.__setitem__('enable_golf', 'no') %}
{% elif config['enable_golf'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_golf', 'no') %}
{% endif %}
{% if 'enable_mpod' not in config %}
  {% set x=config.__setitem__('enable_mpod', 'no') %}
{% elif config['enable_mpod'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_mpod', 'no') %}
{% endif %}
{% if 'target_dscp' not in config %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% elif config['target_dscp'] not in ['unspecified', 'CS0', 'CS1', 'AF11', 'AF12', 'AF13', 'CS2', 'AF21', 'AF22', 'AF23', 'CS3', 'AF31', 'AF32', 'AF33', 'CS4', 'AF41', 'AF42', 'AF43', 'VA', 'CS5', 'EF', 'CS6', 'CS7'] %}
  {% set x=config.__setitem__('target_dscp', 'unspecified') %}
{% endif %}
Verify ACI L3Out Node Profile Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['name']}}, Node pod-{{config['pod_id']}}/node-{{config['node_id']}}
    [Documentation]   Verifies that ACI L3Out Node Profile '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Node: pod-{{config['pod_id']}}/node-{{config['node_id']}}
    ...  - Router ID: {{config['router_id']}}
    ...  - Use Router ID as Loopback: {{config['router_id_as_loopback']}}
    ...  - Multi-POD Enable: {{config['enable_mpod']}}
    ...  - Golf Enable: {{config['enable_golf']}}
    ...  - Target DSCP: {{config['target_dscp']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Profile does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.nameAlias}"  "{{config['name_alias']}}"                    Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extLNodeP.attributes.targetDscp}"  "{{config['target_dscp']}}"                  Target DSCP not matching expected configuration                 values=False
    # Node Association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['name']}}/rsnodeL3OutAtt-[topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Node not associated with Node Profile		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrId}"  "{{config['router_id']}}"                         Router ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsNodeL3OutAtt.attributes.rtrIdLoopBack}"  "{{config['router_id_as_loopback']}}"     Use Router ID as Loopback not matching expected configuration                 values=False
    {% if config['tenant'] == "infra" and (config['enable_golf'] == "yes" or config['enable_mpod'] == "yes") %}
    # Golf or Multi-POD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/instP-l3extInstPName{{config['l3out']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Multi-POD / GOLF External EPG not defined		values=False
    {% endif %}

