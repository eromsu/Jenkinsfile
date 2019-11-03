{#
Verifies external routed network (or L3OUT) configuration

The L3out can be associated to a consumer_label or a provider_label
Consumer Label and Provider Label can't be configured on the same L3Out, this is verified by this template

> The Tenant must pre-exist.
> OSPF Control knobs are not verified by this template
> EIGRP and Route Profile for Interleak configuration are not verified by this template
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'name_alias' not in config %}
  {% set x=config.__setitem__('name_alias', '') %}
{% endif %}
{% if 'enable_bgp' not in config %}
  {% set x=config.__setitem__('enable_bgp', 'no') %}
{% elif config['enable_bgp'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_bgp', 'no') %}
{% endif %}
{% if 'enable_ospf' not in config %}
  {% set x=config.__setitem__('enable_ospf', 'no') %}
{% elif config['enable_ospf'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('enable_ospf', 'no') %}
{% endif %}
{% if 'ospf_area_id' not in config %}
  {% set x=config.__setitem__('ospf_area_id', '') %}
{% endif %}
{% if 'ospf_area_type' not in config %}
  {% set x=config.__setitem__('ospf_area_type', 'nssa') %}
{% elif config['ospf_area_type'] not in ['nssa', 'regular', 'stub'] %}
  {% set x=config.__setitem__('ospf_area_type', 'nssa') %}
{% endif %}
{% if 'consumer_label' not in config %}
  {% set x=config.__setitem__('consumer_label', '') %}
{% endif %}
{% if 'provider_label' not in config %}
  {% set x=config.__setitem__('provider_label', '') %}
{% endif %}
Verify ACI L3Out Configuration - Tenant {{config['tenant']}}, L3Out {{config['name']}}
    [Documentation]   Verifies that ACI L3Out '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - VRF Association: {{config['vrf']}}
    ...  - OSPF Enabled: {{config['enable_ospf']}}
    {% if config['enable_ospf'] == "yes" %}
    ...  - OSPF Area: {{config['ospf_area_id']}}
    ...  - OSPF Area Type: {{config['ospf_area_type']}}
    {% endif %}
    ...  - BGP Enabled: {{config['enable_bgp']}}
    ...  - Consumer Label: {{config['consumer_label']}}
    ...  - Provider Label: {{config['provider_label']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.nameAlias}"  "{{config['name_alias']}}"                   Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extOut.attributes.descr}"  "{{config['description']}}"                      Description not matching expected configuration                 values=False
    {% endif %}
    # VRF association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/rsectx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving VRF configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsEctx.attributes.tnFvCtxName}"  "{{config['vrf']}}"                     VRF Association not matching expected configuration                 values=False
    # Domain
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/rsl3DomAtt
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving Domain configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extRsL3DomAtt.attributes.tDn}"  "uni/l3dom-{{config['l3out_domain']}}"      Domain Association not matching expected configuration                 values=False
    {% if config['enable_ospf'] == "yes" %}
    # OSPF
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/ospfExtP
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		OSPF not enabled 		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfExtP.attributes.areaId}"  "0.0.0.{{config['ospf_area_id']}}"              OSPF Area ID not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].ospfExtP.attributes.areaType}"  "{{config['ospf_area_type']}}"                     OSPF Area Type not matching expected configuration                 values=False
    {% endif %}
    {% if config['enable_bgp'] == "yes" %}
    # BGP
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/bgpExtP
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		BGP not enabled 		values=False
    {% endif %}
    {% if config['consumer_label'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}//conslbl-{{config['consumer_label']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Consumer Label not matching expected configuration		values=False
    {% endif %}
    {% if config['provider_label'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}//provlbl-{{config['provider_label']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${return.totalCount}  1		Consumer Label not matching expected configuration		values=False
    {% endif %}

