{#
Verifies L3 Node Level BGP Peer configuration

If not specified:
* BGP Control knobs 'send community' and 'send extended community' assumed to be configured as enabled
* Local BGP AS Configuration assumed to be configued as replace-as

> The Tenant, L3Out, and Node Profile must pre-exist.
#}
{% if 'bgp_peer_name' not in config %}
  {% set x=config.__setitem__('bgp_peer_name', '') %}
{% endif %}
{% if 'isGolfPeer' not in config %}
  {% set x=config.__setitem__('isGolfPeer', 'no') %}
{% elif config['isGolfPeer'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('isGolfPeer', 'no') %}
{% endif %}
{% if 'control' not in config %}
  {% set x=config.__setitem__('control', 'send-com,send-ext-com') %}
{% endif %}
{% if 'local_bgp_as' not in config %}
  {% set x=config.__setitem__('local_bgp_as', '') %}
{% endif %}
{% if 'local_bgp_as_config' not in config %}
  {% set x=config.__setitem__('local_bgp_as_config', 'replace-as') %}
{% endif %}
Verify ACI L3Out Node Level BGP Peer Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['l3out_node_profile']}}, Peer {{config['bgp_peer_ip']}}
    [Documentation]   Verifies that ACI L3Out Node Level BGP Peer '{{config['bgp_peer_ip']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}', Node Profile '{{config['l3out_node_profile']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - BGP Peer: {{config['bgp_peer_ip']}}
    {% if config['bgp_peer_name'] != "" %}
    ...  - Description: {{config['bgp_peer_name']}}
    {% endif %}
    ...  - Local BGP AS Number: {{config['local_bgp_as']}}
    ...  - Local AS Configuration: {{config['local_bgp_as_config']}}
    ...  - Remote BGP AS Number: {{config['remote_bgp_as']}}
    ...  - BGP Multihop TTL: {{config['ttl']}}
    ...  - BGP Controls: {{config['control']}}
    ...  - Golf / L3EVPN BGP Peer: {{config['isGolfPeer']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    {% if config['tenant'] == "infra" and config['isGolfPeer'] == "yes" %}
    # GOLF BGP Peer
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/infraPeerP--[{{config['bgp_peer_ip']}}]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Level BGP Peer does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.addr}"   "{{config['bgp_peer_ip']}}"    Failure retreiving configuration    values=False
    {% if config['bgp_peer_name'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.descr}"  "{{config['bgp_peer_name']}}"               Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.ttl}"  "{{config['ttl']}}"                           TTL not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpInfraPeerP.attributes.ctrl}"  "{{config['control']}}"                      BGP Controls not matching expected configuration                 values=False
    # Remote AS
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/infraPeerP-[{{config['bgp_peer_ip']}}]/as
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpAsP.attributes.asn}"  "{{config['remote_bgp_as']}}"                        Remote BGP AS not matching expected configuration                 values=False
    {% else %}
    # Regular BGP Peer (none-GOLF)
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		L3Out Node Level BGP Peer does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.addr}"   "{{config['bgp_peer_ip']}}"    Failure retreiving configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.descr}"  "{{config['bgp_peer_name']}}"                    Description not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.ttl}"  "{{config['ttl']}}"                                TTL not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpPeerP.attributes.ctrl}"  "{{config['control']}}"                           BGP Controls not matching expected configuration                 values=False
    # Remote AS
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]/as
	  ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpAsP.attributes.asn}"  "{{config['remote_bgp_as']}}"                        Remote BGP AS not matching expected configuration                 values=False
    {% if config['local_bgp_as'] != "" %}
    # Local AS
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]/localasn
	  ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpLocalAsnP.attributes.localAsn}"  "{{config['local_bgp_as']}}"                    Local BGP AS not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].bgpLocalAsnP.attributes.asnPropagate}"  "{{config['local_bgp_as_config']}}"         Local BGP AS Configuration not matching expected configuration                 values=False
    {% endif %}
    {% endif %}

