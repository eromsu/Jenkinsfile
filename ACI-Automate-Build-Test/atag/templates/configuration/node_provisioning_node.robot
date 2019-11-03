{#
Verifies Spine/Leaf Node Provisioning.

#}
{% if 'oob_ip' not in config %}
  {% set x=config.__setitem__('oob_ip', '') %}
{% endif %}
{% if 'oob_gw' not in config %}
  {% set x=config.__setitem__('oob_gw', '') %}
{% endif %}
{% if 'inband_ip' not in config %}
  {% set x=config.__setitem__('inband_ip', '') %}
{% endif %}
{% if 'inband_gw' not in config %}
  {% set x=config.__setitem__('inband_gw', '') %}
{% endif %}
{% if 'oob_ipv4' not in config %}
  {% set x=config.__setitem__('oob_ipv4', config['oob_ip']) %}
{% endif %}
{% if 'oob_ipv4_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv4_gw', config['oob_gw']) %}
{% endif %}
{% if 'oob_ipv6' not in config %}
  {% set x=config.__setitem__('oob_ipv6', '') %}
{% endif %}
{% if 'oob_ipv6_gw' not in config %}
  {% set x=config.__setitem__('oob_ipv6_gw', '') %}
{% endif %}
{% if 'inband_ipv4' not in config %}
  {% set x=config.__setitem__('inband_ipv4', config['inband_ip']) %}
{% endif %}
{% if 'inband_ipv4_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv4_gw', config['inband_gw']) %}
{% endif %}
{% if 'inband_ipv6' not in config %}
  {% set x=config.__setitem__('inband_ipv6', '') %}
{% endif %}
{% if 'inband_ipv6_gw' not in config %}
  {% set x=config.__setitem__('inband_ipv6_gw', '') %}
{% endif %}
Verify ACI Node Provisioning Configuration - Node {{config['node_id']}}
    [Documentation]  Verifies that Node {{config['node_id']}} are provisioned with the expected parameters
    ...  - Hostname: {{config['name']}}
    ...  - POD ID: {{config['pod_id']}}
    ...  - Node ID: {{config['node_id']}}
    ...  - Serial Number: {{config['serial_number']}}
    ...  - Role: {{config['role']}}
    ...  - OOB Address (IPv4): {{config['oob_ipv4']}}
    ...  - OOB Gateway (IPv4): {{config['oob_ipv4_gw']}}
    ...  - OOB Address (IPv6): {{config['oob_ipv6']}}
    ...  - OOB Gateway (IPv6): {{config['oob_ipv6_gw']}}
    ...  - Inband Address (IPv4): {{config['inband_ipv4']}}
    ...  - Inband Gateway (IPv4): {{config['inband_ipv4_gw']}}
    ...  - Inband Address (IPv6): {{config['inband_ipv6']}}
    ...  - Inband Gateway (IPv6): {{config['inband_ipv6_gw']}}
    [Tags]      aci-conf  aci-fabric  aci-fabric-node-provisioning
    ${url}=     Set Variable  /api/node/mo/topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}/sys
    ${return}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}	1		APIC does not exist	values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.name}  {{config['name']}}                          Hostname not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.podId}  {{config['pod_id']}}                       POD ID not matching expected configuration              values=False
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.id}  {{config['node_id']}}                         Node ID not matching expected configuration              values=False
    {% if config['serial_number'] != "" %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.serial}  {{config['serial_number']}}               Serial Number not matching expected configuration              values=False
    {% endif %}
    Run keyword And Continue on Failure     Should Be Equal as Strings      ${return.payload[0].topSystem.attributes.role}  {{config['role']}}                          Node Role not matching expected configuration              values=False
    {% if config['oob_ipv4'] != "" or config['oob_ipv6'] != "" %}
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/oob-default/rsooBStNode-[topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}]
    ${oob}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${oob.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${oob.totalCount}	1		Out-of-Band Management not configured   values=False
    {% if config['oob_ipv4'] != "" %}
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.addr}  {{config['oob_ipv4']}}                   OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.gw}  {{config['oob_ipv4_gw']}}             OOB Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['oob_ipv6'] != "" %}
    run keyword if  ${oob.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.v6Addr}  {{config['oob_ipv6']}}                 OOB Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${oob.payload[0].mgmtRsOoBStNode.attributes.v6Gw}  {{config['oob_ipv6_gw']}}           OOB Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% endif %}
    {% if config['inband_ipv4'] != "" or config['inband_ipv6'] != "" %}
    ${url}=     Set Variable  /api/node/mo/uni/tn-mgmt/mgmtp-default/inb-default/rsinBStNode-[topology/pod-{{config['pod_id']}}/node-{{config['node_id']}}]
    ${inb}=  via ACI REST API retrieve "${url}" from "${apic}" as "object"
    Should Be Equal as Integers     ${inb.status}		200		Failure executing API call			values=False
    Run keyword And Continue on Failure     Should Be Equal as Integers     ${inb.totalCount} 	1		Inband Management not configured   values=False
    {% if config['inband_ipv4'] != "" %}
    run keyword if  ${inb.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.addr}  {{config['inband_ipv4']}}                Inband Management Address (IPv4) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.gw}  {{config['inband_ipv4_gw']}}          Inband Management Gateway (IPv4) not matching expected configuration              values=False
    {% endif %}
    {% if config['inband_ipv6'] != "" %}
    run keyword if  ${inb.totalCount} == 1  run keywords
    ...  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.v6Addr}  {{config['inband_ipv6']}}              Inband Management Address (IPv6) not matching expected configuration              values=False
    ...  AND  Run keyword And Continue on Failure     Should Be Equal as Strings      ${inb.payload[0].mgmtRsInBStNode.attributes.v6Gw}  {{config['inband_ipv6_gw']}}        Inband Management Gateway (IPv6) not matching expected configuration              values=False
    {% endif %}
    {% endif %}

