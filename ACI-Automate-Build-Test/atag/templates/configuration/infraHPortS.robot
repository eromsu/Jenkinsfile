{#
Verifies Interface Selector configuration

> Parent Interface Profile must exist.
> The template supports Leaf, Spine, and FEX parent interface profiles
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'port_block_description' not in config %}
  {% set x=config.__setitem__('port_block_description', '') %}
{% endif %}
{% if config['interface_polgroup_type'] == 'Access'%}
    {% set port_type = 'accportgrp' %}
{% elif config['interface_polgroup_type'] == 'vPC' or config['interface_polgroup_type'] == 'PC' %}
    {% set port_type = 'accbundle' %}
{% endif %}
{% if not config['fex_id'] or config['fex_id'] == "" %}
    {% set fex_id = '101' %}
{% endif %}
{% if config['interface_profile_type'] == "leaf" %}
Verify ACI Leaf Interface Selector Configuration - Interface Profile {{config['interface_profile']}}, Interface Selector {{config['name']}}
    [Documentation]   Verifies that ACI Leaf Interface Selector '{{config['name']}}' under '{{config['interface_profile']}}' are configured with the expected parameters
    ...  - Interface Profile Name:  {{config['interface_profile']}}
    ...  - Interface Selector Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Interface Selector Description: {{config['description']}}
    {% endif %}
    ...  - From Slot: {{config['from_slot']}}
    ...  - From Port: {{config['from_port']}}
    ...  - To Slot: {{config['to_slot']}}
    ...  - To Port: {{config['to_port']}}
    {% if config['port_block_description'] != "" %}
    ...  - Port Block Description: {{config['port_block_description']}}
    {% endif %}
    ...  - Associated Interface Policy Group: {{config['interface_policy_group']}}
    ...  - Associated Interface Policy Group Type: {{config['interface_polgroup_type']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   {{config['name']}}    Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraHPortS.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "{{config['to_port']}}"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "{{config['from_port']}}"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    {% if config['port_block_description'] != "" %}
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "{{config['port_block_description']}}"                                          Port Block Description not matching expected configuration                 values=False
    {% endif %}
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    {% if config['interface_policy_group'] != "" %}
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range/rsaccBaseGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/funcprof/{{port_type}}-{{config['interface_policy_group']}}        Interface Policy Group Association not matching expected configuration	    values=False
    {% endif %}
{% elif config['interface_profile_type'] == "fex" %}
Verify ACI FEX Interface Selector Configuration - Interface Profile {{config['interface_profile']}}, Interface Selector {{config['name']}}
    [Documentation]   Verifies that ACI FEX Interface Selector '{{config['name']}}' under '{{config['interface_profile']}}' are configured with the expected parameters
    ...  - Interface Profile Name:  {{config['interface_profile']}}
    ...  - Interface Selector Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Interface Selector Description: {{config['description']}}
    {% endif %}
    ...  - From Slot: {{config['from_slot']}}
    ...  - From Port: {{config['from_port']}}
    ...  - To Slot: {{config['to_slot']}}
    ...  - To Port: {{config['to_port']}}
    {% if config['port_block_description'] != "" %}
    ...  - Port Block Description: {{config['port_block_description']}}
    {% endif %}
    ...  - Associated FEX Profile: {{config['interface_policy_group']}}
    ...  - Associated FEX ID: {{fex_id}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraHPortS.attributes.name}   {{config['name']}}    Failure retreiving configuration    values=False
    {% if config['port_block_description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraHPortS.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "{{config['to_port']}}"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "{{config['from_port']}}"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    {% if config['port_block_description'] != "" %}
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "{{config['port_block_description']}}"                                          Port Block Description not matching expected configuration                 values=False
    {% endif %}
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    {% if config['interface_policy_group'] != "" %}
    # Verify FEX Profile associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/accportprof-{{config['interface_profile']}}/hports-{{config['name']}}-typ-range/rsaccBaseGrp
	${fex_pol}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${fex_pol.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${fex_pol.totalCount}    	1		Failure retreiving FEX Profile association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${fex_pol.payload[0].infraRsAccBaseGrp.attributes.tDn}   uni/infra/fexprof-{{config['interface_policy_group']}}/fexbundle-{{config['interface_policy_group']}}      FEX Profile Association not matching expected configuration	    values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${fex_pol.payload[0].infraRsAccBaseGrp.attributes.fexId}    	{{fex_id}}         FEX ID not matching expected configuration	    values=False
    {% endif %}
{% elif config['interface_profile_type'] == "spine" %}
Verify ACI Spine Interface Selector Configuration - Interface Profile {{config['interface_profile']}}, Interface Selector {{config['name']}}
    [Documentation]   Verifies that ACI Spine Interface Selector '{{config['name']}}' under '{{config['interface_profile']}}' are configured with the expected parameters
    ...  - Interface Profile Name:  {{config['interface_profile']}}
    ...  - Interface Selector Name:  {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Interface Selector Description: {{config['description']}}
    {% endif %}
    ...  - From Slot: {{config['from_slot']}}
    ...  - From Port: {{config['from_port']}}
    ...  - To Slot: {{config['to_slot']}}
    ...  - To Port: {{config['to_port']}}
    {% if config['port_block_description'] != "" %}
    ...  - Port Block Description: {{config['port_block_description']}}
    {% endif %}
    ...  - Associated Interface Policy Group: {{config['interface_policy_group']}}
    ...  - Associated Interface Policy Group Type: {{config['interface_polgroup_type']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-profile
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-{{config['interface_profile']}}/shports-{{config['name']}}-typ-range
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=infraPortBlk
	${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Selector does not exist		values=False
	Should Be Equal as Strings     ${return.payload[0].infraSHPortS.attributes.name}   {{config['name']}}   Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].infraSHPortS.attributes.descr}"  "{{config['description']}}"                       Description not matching expected configuration                 values=False
    {% endif %}
    # Iterate through the port blocks
    : FOR  ${block}  IN  @{return.payload[0].infraSHPortS.children}
    \  ${port_block_found} =    Set Variable      "False"
	\  Set Test Variable  ${port_block_found}	"False"
    \  ${toPort_found} =        Set Variable If   "${block.infraPortBlk.attributes.toPort}" == "{{config['to_port']}}"          True
    \  ${toCard_found} =        Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${fromPort_found} =      Set Variable If   "${block.infraPortBlk.attributes.fromPort}" == "{{config['from_port']}}"      True
    \  ${fromSlotfound} =       Set Variable If   "${block.infraPortBlk.attributes.toCard}" == "{{config['from_slot']}}"        True
    \  ${port_block_found} =    Set Variable If   ${toPort_found} == True and ${toCard_found} == True and ${fromPort_found} == True        True
    {% if config['port_block_description'] != "" %}
    \  run keyword if   ${port_block_found} == True  Run keyword And Continue on Failure
    \  ...  Should Be Equal as Strings     "${block.infraPortBlk.attributes.descr}"        "{{config['port_block_description']}}"                                          Port Block Description not matching expected configuration                 values=False
    {% endif %}
    run keyword if  not ${port_block_found} == True  Run keyword And Continue on Failure
    ...  Fail   Port block (to/from card and port) not matching expected configuration	
    {% if config['interface_policy_group'] != "" %}
    # Verify Interface Policy Group associated with interface selector
	${uri} =  Set Variable  	/api/node/mo/uni/infra/spaccportprof-{{config['interface_profile']}}/shports-{{config['name']}}-typ-range/rsspAccGrp
	${if_polgrp}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${if_polgrp.status}		    200		Failure executing API call			values=False
	Run keyword And Continue on Failure  Should Be Equal as Integers     ${if_polgrp.totalCount}    	1		Failure retreiving interface policy group association	values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings      ${if_polgrp.payload[0].infraRsSpAccGrp.attributes.tDn}   uni/infra/funcprof/spaccportgrp-{{config['interface_policy_group']}}        Interface Policy Group Association not matching expected configuration	    values=False
    {% endif %}
{% endif %}

