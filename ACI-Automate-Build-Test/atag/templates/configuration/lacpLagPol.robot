{#
Verifies Port Channel Fabric Access Interface Policy configuration.
#}
{% set ctrl = [] %}
{% if config['fast_select_hot_stdby'] == "yes" %}{% set ctrl = ctrl + [("fast-sel-hot-stdby")] %}{% endif %}
{% if config['gracefull_converge'] == "yes" %}{% set ctrl = ctrl + [("graceful-conv")] %}{% endif %}
{% if config['load_defer'] == "yes" %}{% set ctrl = ctrl + [("load-defer")] %}{% endif %}
{% if config['suspend_individual'] == "yes" %}{% set ctrl = ctrl + [("susp-individual")] %}{% endif %}
{% if config['symmetrical_hash'] == "yes" %}{% set ctrl = ctrl + [("symmetric-hash")] %}{% endif %}
Verify ACI Port Channel Interface Policy Configuration - Policy Name {{config['name']}}
    [Documentation]   Verifies that Port Channel Interface Policy '{{config['name']}}' are configured with the expected parameters
    ...  - Interface Policy Name: {{config['name']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
	...  - Port-Channel Mode (LACP): {{config['pc_mode']}}
	...  - Fast Select Hot Standby: {{config['fast_select_hot_stdby']}}
	...  - Graceful Converge: {{config['gracefull_converge']}}
	...  - Load Defer: {{config['load_defer']}}
	...  - Suspend Individual: {{config['suspend_individual']}}
	...  - Symmetric Hash: {{config['symmetrical_hash']}}
	...  - Hash Key: {{config['hash_key']}}
	...  - Min Links: {{config['min_links']}}
	...  - Max Links: {{config['max_links']}}
	...  - Control: fast-sel-hot-stdby,graceful-conv,susp-individual
    [Tags]      aci-conf  aci-fabric  aci-fabric-interface-policy
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		Interface Policy does not exist     values=False
	Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.name}		{{config['name']}}       Failure retreiving configuration    values=False
    {% if config['description'] != "" %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].lacpLagPol.attributes.descr}"   "{{config['description']}}"          Description not matching expected configuration              values=False
    {% endif %}
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.mode}		{{config['pc_mode']}}                 Port Channel Mode (LACP) not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.minLinks}	{{config['min_links']}}               Min Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.maxLinks}	{{config['max_links']}}               Max Links not matching expected configuration                 values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].lacpLagPol.attributes.ctrl}		{{ctrl|join(',')}}    				  Control Kobs not matching expected configuration                   values=False
	{% if config['symmetrical_hash'] == "yes" and config['hash_key'] %}
	${uri} =  Set Variable  	/api/node/mo/uni/infra/lacplagp-{{config['name']}}/loadbalanceP
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
	Should Be Equal as Integers     ${return.totalCount}	1		Failure Retrieving Port Channel Hash configuration     values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     ${return.payload[0].l2LoadBalancePol.attributes.hashFields}		{{config['hash_key']}}                 Port Channel Hash Key not matching expected configuration                 values=False
	{% endif %}

