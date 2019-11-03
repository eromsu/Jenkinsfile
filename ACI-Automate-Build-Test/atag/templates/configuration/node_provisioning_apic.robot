{#
Verifies APIC Node Provisioning.

#}
{% if 'oob_ipv4' not in config %}
  {% set x=config.__setitem__('oob_ipv4', '') %}
{% endif %}
{% if 'oob_ipv4_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv4_gw', '') %}
{% endif %}
{% if 'oob_ipv6' not in config %}
  {% set x=config.__setitem__('oob_ipv6', '') %}
{% endif %}
{% if 'oob_ipv6_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv6_gw', '') %}
{% endif %}
{% if 'inband_ipv4' not in config %}
  {% set x=config.__setitem__('inband_ipv4', '') %}
{% endif %}
{% if 'inband_ipv4_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv4_gw', '') %}
{% endif %}
{% if 'inband_ipv6' not in config %}
  {% set x=config.__setitem__('inband_ipv6', '') %}
{% endif %}
{% if 'inband_ipv6_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv6_gw', '') %}
{% endif %}
Verify ACI APIC Provisioning Configuration - APIC {{config['apic_id']}}
    [Documentation]  Verifies that APIC {{config['apic_id']}} are provisioned with the expected parameters
    ...  - Hostname: {{config['apic_hostname']}}
    ...  - POD ID: {{config['pod_id']}}
    ...  - Node ID: {{config['apic_id']}}
    ...  - Role: controller
    ...  - OOB Address (IPv4): {{config['oob_ipv4']}}
    ...  - OOB Gateway (IPv4): {{config['oob_ipv4_gw']}}
    ...  - OOB Address (IPv6): {{config['oob_ipv6']}}
    ...  - OOB Gateway (IPv6): {{config['oob_ipv6_gw']}}
    ...  - Inband Address (IPv4): {{config['inband_ipv4']}}
    ...  - Inband Gateway (IPv4): {{config['inband_ipv4_gw']}}
    ...  - Inband Address (IPv6): {{config['inband_ipv6']}}
    ...  - Inband Gateway (IPv6): {{config['inband_ipv6_gw']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['apic_id']}}/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  {{config['apic_hostname']}}                 Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  {{config['pod_id']}}                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  {{config['apic_id']}}                         Node ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  controller                                  Node Role not matching expected configuration              values=False
    {% if config['oob_ipv4'] != "" %}
    {% set address = config['oob_ipv4'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr}  {{address[0]}}                       OOB Management Address (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddrMask}  {{address[1]}}                   OOB Management Address Mask (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtGateway}  {{config['oob_ipv4_gw']}}         OOB Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['oob_ipv6'] != "" %}
    {% set address = config['oob_ipv6'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr6}  {{address[0]}}                      OOB Management Address (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtAddr6Mask}  {{address[1]}}                  OOB Management Address Mask (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.oobMgmtGateway6}  {{config['oob_ipv6_gw']}}        OOB Management Gateway (IPv6) not matching expected configuration              values=False
    {% endif %}
    {% if config['inband_ipv4'] != "" %}
    {% set address = config['inband_ipv4'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddr}  {{address[0]}}                       Inband Management Address (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddrMask}  {{address[1]}}                   Inband Management Address Mask (IPv4) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtGateway}  {{config['inband_ipv4_gw']}}      Inband Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['inband_ipv6'] != "" %}
    {% set address = config['inband_ipv6'].split('/') %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddr6}  {{address[0]}}                      Inband Management Address (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtAddr6Mask}  {{address[1]}}                  Inband Management Address Mask (IPv6) not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.inbMgmtGateway6}  {{config['inband_ipv6_gw']}}     Inband Management Gateway (IPv6) not matching expected configuration              values=False
    {% endif %}

