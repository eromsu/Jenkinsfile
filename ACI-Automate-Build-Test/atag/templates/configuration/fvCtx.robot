{#
Verifies VRF configuration.

> The configuration of child objects like bgp_timers, ospf_timers, route_tag_policy, endpoint_retention policies
> BGP Context and OSPF Context Policies, etc. are not verified in this test case template.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'policy_enforcement' not in config %}
  {% set x=config.__setitem__('policy_enforcement', 'enforced') %}
{% elif config['policy_enforcement'] not in ['enforced', 'unenforced'] %}
  {% set x=config.__setitem__('policy_enforcement', 'enforced') %}
{% endif %}
{% if 'policy_enforcement_direction' not in config %}
  {% set x=config.__setitem__('policy_enforcement_direction', 'ingress') %}
{% elif config['policy_enforcement_direction'] not in ['ingress', 'egress'] %}
  {% set x=config.__setitem__('policy_enforcement_direction', 'ingress') %}
{% endif %}
{% if 'bgp_timers' not in config %}
  {% set x=config.__setitem__('bgp_timers', '') %}
{% endif %}
{% if 'ospf_timers' not in config %}
  {% set x=config.__setitem__('ospf_timers', '') %}
{% endif %}
{% if 'route_tag_policy' not in config %}
  {% set x=config.__setitem__('route_tag_policy', '') %}
{% endif %}
{% if 'monitoring_policy' not in config %}
  {% set x=config.__setitem__('monitoring_policy', '') %}
{% endif %}
{% if 'endpoint_retention_policy' not in config %}
  {% set x=config.__setitem__('endpoint_retention_policy', '') %}
{% endif %}
{% if 'dns_label' not in config %}
  {% set x=config.__setitem__('dns_label', '') %}
{% endif %}
{% if 'golf_vrf_name' not in config %}
  {% set x=config.__setitem__('golf_vrf_name', '') %}
{% endif %}
{% if 'bgp_context_ipv4' not in config %}
  {% set x=config.__setitem__('bgp_context_ipv4', '') %}
{% endif %}
{% if 'bgp_context_ipv6' not in config %}
  {% set x=config.__setitem__('bgp_context_ipv6', '') %}
{% endif %}
{% if 'ospf_context_af' not in config %}
  {% set x=config.__setitem__('ospf_context_af', '') %}
{% endif %}
{% if 'golf_opflex_mode' not in config %}
  {% set x=config.__setitem__('golf_opflex_mode', '') %}
{% endif %}
{% if 'golf_vrf_name' not in config %}
  {% set x=config.__setitem__('golf_vrf_name', '') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
Verify ACI VRF Configuration - Tenant {{config['tenant']}}, VRF {{config['name']}}
    [Documentation]   Verifies that ACI VRF '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - VRF Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Policy Enforcement: {{config['policy_enforcement']}}
    ...  - Policy Enforcement Direction: {{config['policy_enforcement_direction']}}
    {% if config['bgp_timers'] != "" %}
    ...  - BGP Timers: {{config['bgp_timers']}}
    {% endif %}
    {% if config['ospf_timers'] != "" %}
    ...  - OSPF Timers: {{config['ospf_timers']}}
    {% endif %}
    {% if config['route_tag_policy'] != "" %}
    ...  - Route Tag Policy: {{config['route_tag_policy']}}
    {% endif %}
    ...  - Monitoring Policy: {{config['monitoring_policy']}}
    {% if config['endpoint_retention_policy'] != "" %}
    ...  - Endpoint Retention Policy: {{config['endpoint_retention_policy']}}
    {% endif %}
    {% if config['dns_label'] != "" %}
    ...  - DNS Label: {{config['dns_label']}}
    {% endif %}
    {% if config['bgp_context_ipv4'] != "" %}
    ...  - BGP IPv4 Context Policy Name: {{config['bgp_context_ipv4']}}
    {% endif %}
    {% if config['bgp_context_ipv6'] != "" %}
    ...  - BGP IPv6 Context Policy Name: {{config['bgp_context_ipv6']}}
    {% endif %}
    ...  - GOLF Opflex Mode: {{config['golf_opflex_mode']}}
    ...  - GOLF VRF Name: {{config['golf_vrf_name']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-vrf
    # Retrieve VRF
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		VRF not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvCtx.attributes.name}   {{config['name']}}      Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.nameAlias}"  "{{config['nameAlias']}}"             Name alias not matching expected configuration                       values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.descr}"  "{{config['description']}}"               Description not matching expected configuration                values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfPref}"  "{{config['policy_enforcement']}}"     Policy Control Enforcement Preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvCtx.attributes.pcEnfDir}"  "{{config['policy_enforcement_direction']}}"     Policy Control Enforcement Direction not matching expected configuration                values=False
    {% if config['bgp_timers'] != "" %}
    # BGP Timers
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsbgpCtxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP Timer)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP Timer)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBgpCtxPol.attributes.tnBgpCtxPolName}"  "{{config['bgp_timers']}}"             BGP Timer not matching expected configuration                       values=False
    {% endif %}
    {% if config['ospf_timers'] != "" %}
    # OSPF Timers
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsospfCtxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (OSPF Timer)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (OSPF Timer)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsOspfCtxPol.attributes.tnOspfCtxPolName}"  "{{config['ospf_timers']}}"             OSPF Timer not matching expected configuration                       values=False
    {% endif %}
    {% if config['route_tag_policy'] != "" %}
    # Route Tag Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToExtRouteTagPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Route Tag Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Route Tag Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToExtRouteTagPol.attributes.tnL3extRouteTagPolName}"  "{{config['route_tag_policy']}}"             Route Tag Policy not matching expected configuration                       values=False
    {% endif %}
    # Monitoring Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsCtxMonPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Monitoring Policy)		values=False
    {% if config['monitoring_policy'] != "" %}
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Monitoring Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxMonPol.attributes.tnMonEPGPolName}"  "{{config['monitoring_policy']}}"             Monitoring Policy not matching expected configuration                       values=False
    {% else %}
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Monitoring Policy not matching expected configuration		values=False
    {% endif %}
    {% if config['endpoint_retention_policy'] != "" %}
    # Endpoint Retention Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToEpRet
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Endpoint Retention Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Endpoint Retention Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToEpRet.attributes.tnFvEpRetPolName}"  "{{config['endpoint_retention_policy']}}"             Endpoint Retention Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['dns_label'] != "" %}
    # DNS Label
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/dnslbl-{{config['dns_label']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (DNS Label)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (DNS Label)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].dnsLbl.attributes.name}"  "{{config['dns_label']}}"             DNS Label not matching expected configuration                       values=False
    {% endif %}
    {% if config['bgp_context_ipv4'] != "" %}
    # BGP IPv4 Context Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToBgpCtxAfPol-[{{config['bgp_context_ipv4']}}]-ipv4-ucast
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP IPv4 Context Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP IPv4 Context Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToBgpCtxAfPol.attributes.tnBgpCtxAfPolName}"  "{{config['bgp_context_ipv4']}}"             BGP IPv4 Context Policy Name not matching expected configuration                       values=False
    {% endif %}
    {% if config['bgp_context_ipv6'] != "" %}
    # BGP IPv6 Context Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/rsctxToBgpCtxAfPol-[{{config['bgp_context_ipv6']}}]-ipv6-ucast
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (BGP IPv6 Context Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (BGP IPv6 Context Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtxToBgpCtxAfPol.attributes.tnBgpCtxAfPolName}"  "{{config['bgp_context_ipv6']}}"             BGP IPv6 Context Policy Name not matching expected configuration                       values=False
    {% endif %}
    {% if config['golf_opflex_mode'] == "yes" %}
    # Golf 
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/globalctxname
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (GOLF VRF name)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (GOLF VRF name)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extGlobalCtxName.attributes.name}"  "{{config['golf_vrf_name']}}"             Golf VRF Name not matching expected configuration                       values=False
    {% endif %}

