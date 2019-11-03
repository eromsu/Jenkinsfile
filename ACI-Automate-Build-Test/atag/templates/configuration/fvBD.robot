{# 
Verifies Bridge Domain configuration

> The association of BD subnet's are not verified in this test case template.

#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'enablePim' not in config %}
  {% set x=config.__setitem__('enablePim', 'no') %}
{% elif config['enablePim'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('enablePim', 'no') %}
{% endif %}
{% if 'limit_ip_learning_to_subnet' not in config %}
  {% set x=config.__setitem__('limit_ip_learning_to_subnet', 'yes') %}
{% elif config['limit_ip_learning_to_subnet'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('limit_ip_learning_to_subnet', 'yes') %}
{% endif %}
{% if 'endpoint_data_plane_learning' not in config %}
  {% set x=config.__setitem__('endpoint_data_plane_learning', 'yes') %}
{% elif config['endpoint_data_plane_learning'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('endpoint_data_plane_learning', 'yes') %}
{% endif %}
{% if 'igmp_snoop_policy' not in config %}
  {% set x=config.__setitem__('igmp_snoop_policy', '') %}
{% endif %}
{% if 'endpoint_retention_policy' not in config %}
  {% set x=config.__setitem__('endpoint_retention_policy', '') %}
{% endif %}
{% if 'igmpInterfacePolicy' not in config %}
  {% set x=config.__setitem__('igmpInterfacePolicy', '') %}
{% endif %}
{% if 'is_bd_legacy' not in config %}
  {% set x=config.__setitem__('is_bd_legacy', 'no') %}
{% elif config['is_bd_legacy'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('is_bd_legacy', 'no') %}
{% endif %}
{% if 'legacy_bd_vlan' not in config %}
  {% set x=config.__setitem__('legacy_bd_vlan', '') %}
{% endif %}
{% if 'route_control_profile' not in config %}
  {% set x=config.__setitem__('route_control_profile', '') %}
{% endif %}
{% if 'l3out_for_route_profile' not in config %}
  {% set x=config.__setitem__('l3out_for_route_profile', '') %}
{% endif %}
Verify ACI BD Configuration - Tenant {{config['tenant']}}, BD {{config['name']}}
    [Documentation]   Verifies that ACI BD '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - BD Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Associated to VRF: {{config['vrf']}}
    ...  - L2 Unknown Unicast Flooding: {{config['l2_unknown_unicast']}}
    ...  - L3 Unknown Multicast Flooding: {{config['l3_unknown_multicast']}}
    ...  - Multi Destination Flooding: {{config['multi_dest_flood']}}
    ...  - Enable PIM: {{config['enablePim']}}
    ...  - ARP Flooding: {{config['arp_flood']}}
    ...  - Unicast Routing: {{config['unicast_routing']}}
    ...  - Limit IP Learning to Subnet: {{config['limit_ip_learning_to_subnet']}}
    ...  - Endpoint Dataplane Learning: {{config['endpoint_data_plane_learning']}}
    ...  - Endpoint Move Detection Mode: {{config['endpoint_move_detect_mode']}}
    {% if config['endpoint_retention_policy'] != "" %}
    ...  - Endpoint Retention Policy: {{config['endpoint_retention_policy']}}
    {% endif %}
    {% if config['igmp_snoop'] != "" %}
    ...  - IGMP Snooping Policy: {{config['igmp_snoop']}}
    {% endif %}
    {% if config['igmpInterfacePolicy'] != "" %}
    ...  - IGMP Interface Policy: {{config['igmpInterfacePolicy']}}
    {% endif %}
    ...  - Legacy Mode: {{config['is_bd_legacy']}}
    {% if config['is_bd_legacy'] == "yes" %}
    ...  - Legacy Encapsulation VLAN: {{config['legacy_bd_vlan']}}
    {% endif %}
    {% if config['route_control_profile'] == "yes" %}
    ...  - Route Profile: {{config['route_control_profile']}}
    {% endif %}
    {% if config['l3out_for_route_profile'] == "yes" %}
    ...  - L3Out for Route Profile: {{config['l3out_for_route_profile']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		BD not configured		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvBD.attributes.name}   {{config['name']}}      Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.nameAlias}"  "{{config['nameAlias']}}"                    Name alias not matching expected configuration                       values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.descr}"  "{{config['description']}}"                      Description not matching expected configuration                values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMacUcastAct}"  "{{config['l2_unknown_unicast']}}"      L2 Unknown Unicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unkMcastAct}"  "{{config['l3_unknown_multicast']}}"       L3 Unknown Multicast Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.multiDstPktAct}"  "{{config['multi_dest_flood']}}"        Multi Destination Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.arpFlood}"  "{{config['arp_flood']}}"                     ARP Flooding not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.unicastRoute}"  "{{config['unicast_routing']}}"           Unicast Routing not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.limitIpLearnToSubnets}"  "{{config['limit_ip_learning_to_subnet']}}"           Limit IP Learning to Subnet not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.ipLearning}"  "{{config['endpoint_data_plane_learning']}}"           Endpoint Dataplane Learning not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.mcastAllow}"  "{{config['enablePim']}}"                   PIM not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvBD.attributes.epMoveDetectMode}"  "{{config['endpoint_move_detect_mode']}}"                   Endpoint Move Detection Mode not matching expected configuration                values=False
    # VRF Association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsctx
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (VRF)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (VRF)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCtx.attributes.tnFvCtxName}"  "{{config['vrf']}}"                    Associated VRF not matching expected configuration                       values=False
    {% if config['endpoint_retention_policy'] != "" %}
    # Endpoint Retention Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsbdToEpRet
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Endpoint Retention Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Endpoint Retention Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBdToEpRet.attributes.tnFvEpRetPolName}"  "{{config['endpoint_retention_policy']}}"                    Endpoint Retention Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['igmp_snoop'] != "" %}
    # IGMP Snooping
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsigmpsn
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Snooping)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Snooping)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsIgmpsn.attributes.tnIgmpSnoopPolName}"  "{{config['igmp_snoop']}}"                    IGMP Snooping Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['igmpInterfacePolicy'] != "" %}
    # IGMP Interface Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/igmpIfP/rsIfPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (IGMP Interface Policy)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (IGMP Interface Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].igmpRsIfPol.attributes.tDn}"  "uni/tn-{{config['tenant']}}/igmpIfPol-{{config['igmpInterfacePolicy']}}"                    IGMP Interface Policy not matching expected configuration                       values=False
    {% endif %}
    {% if config['route_control_profile'] != "" %}
    # Route Profile
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/rsBDToProfile
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Route Profile)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Route Profile)		values=False
    {% if config['l3out_for_route_profile'] == "yes" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDToProfile.attributes.tnL3extOutName}"  "{{config['l3out_for_route_profile']}}"                    L3Out for Route Profile not matching expected configuration                       values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDToProfile.attributes.tnRtctrlProfileName}"  "{{config['route_control_profile']}}"                 Route Profile not matching expected configuration                       values=False
    {% endif %}
    {% if config['is_bd_legacy'] == "yes" %}
    # Legacy Mode
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/accp
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Legacy Mode)		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Legacy Mode)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAccP.attributes.encap}"  "vlan-{{config['legacy_bd_vlan']}}"                    Legacy Mode Encapsulation not matching expected configuration                       values=False
    {% endif %}

