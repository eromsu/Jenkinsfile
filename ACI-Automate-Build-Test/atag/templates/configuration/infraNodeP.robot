{#
Verifies Leaf/Spine Switch Profile configuration.

> The configuration of the Fabric Access Switch Policy Group are not verified by this template.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'switch_policy_group' not in config %}
  {% set x=config.__setitem__('switch_policy_group', '') %}
{% endif %}
{% if config['switch_profile_type'] == "leaf" %}
Verify ACI Leaf Switch Profile Configuration - Profile {{config['name']}}, Switch Selector {{config['switch_selector']}}, Node block {{config['from_node_id']}}-{{config['to_node_id']}}
    [Documentation]   Verifies that Leaf Switch Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Switch Selector: {{config['switch_selector']}}
    ...  - Node ID (from): {{config['from_node_id']}}
    ...  - Node ID (to): {{config['to_node_id']}}
    {% if config['switch_policy_group'] != "" %}
    ...  - Switch Policy Group: {{config['switch_policy_group']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].infraNodeP.attributes.name}   {{config['name']}}     Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].infraNodeP.attributes.descr}"   "{{config['description']}}"           Description not matching expected configuration              values=False
    {% endif %}
    # Retrieve switch selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/nprof-{{config['name']}}/leaves-{{config['switch_selector']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraNodeBlk
	${sw_selector}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.status}		200		                                                    Failure executing API call			                            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.totalCount}    	1		                                                Switch Selector does not exist	                                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${sw_selector.payload[0].infraLeafS.attributes.name}   {{config['switch_selector']}}   Failure retreiving switch selector configuration	            values=False
    ${from_node_found} =  Set Variable  "Node not found"
    ${to_node_found} =  Set Variable  "Node not found"
    : FOR  ${block}  IN  @{sw_selector.payload[0].infraLeafS.children}
    \  ${from_node_found} =     Set Variable If   "${block.infraNodeBlk.attributes.from_}" == "{{config['from_node_id']}}"      "Node found"
    \  ${to_node_found} =       Set Variable If   "${block.infraNodeBlk.attributes.to_}" == "{{config['to_node_id']}}"          "Node found"
	run keyword if  not ${from_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (from) not matching expected configuration
	run keyword if  not ${to_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (to) not matching expected configuration
{% elif config['switch_profile_type'] == "spine" %}
Verify ACI Spine Switch Profile Configuration - Profile {{config['name']}}, Switch Selector {{config['switch_selector']}}, Node block {{config['from_node_id']}}-{{config['to_node_id']}}
    [Documentation]   Verifies that Spine Switch Profile '{{config['name']}}' are configured with the expected parameters
    ...  - Profile Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Switch Selector: {{config['switch_selector']}}
    ...  - From Node ID: {{config['from_node_id']}}
    ...  - To Node ID: {{config['to_node_id']}}
    {% if config['switch_policy_group'] != "" %}
    ...  - Switch Policy Group: {{config['switch_policy_group']}}
    {% endif %}
    [Tags]      aci-conf  aci-fabric  aci-fabric-switch-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Switch Profile does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].infraSpineP.attributes.name}   {{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].infraSpineP.attributes.descr}"   "{{config['description']}}"       Description not matching expected configuration                  values=False
    {% endif %}
    # Retrieve switch selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spprof-{{config['name']}}/spines-{{config['switch_selector']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraNodeBlk
	${sw_selector}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.status}		200                                                         Failure executing API call			                            values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${sw_selector.totalCount}    	1		                                                Switch Selector does not exist	                                values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${sw_selector.payload[0].infraSpineS.attributes.name}   {{config['switch_selector']}}  Failure retreiving switch selector configuration	            values=False
    ${from_node_found} =  Set Variable  "Node not found"
    ${to_node_found} =  Set Variable  "Node not found"
    : FOR  ${block}  IN  @{sw_selector.payload[0].infraSpineS.children}
    \  ${from_node_found} =     Set Variable If   "${block.infraNodeBlk.attributes.from_}" == "{{config['from_node_id']}}"      "Node found"
    \  ${to_node_found} =       Set Variable If   "${block.infraNodeBlk.attributes.to_}" == "{{config['to_node_id']}}"          "Node found"
	run keyword if  not ${from_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (from) not matching expected configuration
	run keyword if  not ${to_node_found} == "Node found"  Run keyword And Continue on Failure
	...  Fail  Node ID (to) not matching expected configuration
{% endif %}

