{#
Verifies Contract Filter Entry configuration

> The Contract Filter must pre-exist.
#}
{%- set port_dictionary = {
                              '25': 'smtp',
                              '20': 'ftp-data',
                              '53': 'dns',
                              '80': 'http',
                              '110': 'pop3',
                              '443': 'https',
                              '554': 'rtsp'
                          }
-%}
{% if 'from_source_port' not in config or config['from_source_port'] == ""%}
  {% set x=config.__setitem__('from_source_port', 'unspecified') %}
  {% set from_source_port = 'unspecified' %}
{% elif config['from_source_port'] == 'unspecified' %}
  {% set from_source_port = config['from_source_port'] %}
{% elif config['from_source_port'] in port_dictionary %}
  {% set from_source_port = port_dictionary[config['from_source_port']] %}
{% else %}
  {% set from_source_port = config['from_source_port'] %}
{% endif %}
{% if 'to_source_port' not in config or config['to_source_port'] == "" %}
  {% set x=config.__setitem__('to_source_port', 'unspecified') %}
  {% set to_source_port = 'unspecified' %}
{% elif config['to_source_port'] == 'unspecified' %}
  {% set to_source_port = config['to_source_port'] %}
{% elif config['to_source_port'] in port_dictionary %}
  {% set to_source_port = port_dictionary[config['to_source_port']] %}
{% else %}
  {% set to_source_port = config['to_source_port'] %}
{% endif %}
{% if 'from_destination_port' not in config or config['from_destination_port'] == ""%}
  {% set x=config.__setitem__('from_destination_port', 'unspecified') %}
  {% set from_destination_port = 'unspecified' %}
{% elif config['from_destination_port'] == 'unspecified' %}
  {% set from_destination_port = config['from_destination_port'] %}
{% elif config['from_destination_port'] in port_dictionary %}
  {% set from_destination_port = port_dictionary[config['from_destination_port']] %}
{% else %}
  {% set from_destination_port = config['from_destination_port'] %}
{% endif %}
{% if 'to_destination_port' not in config or config['to_destination_port'] == "" %}
  {% set x=config.__setitem__('to_destination_port', 'unspecified') %}
  {% set to_destination_port = 'unspecified' %}
{% elif config['to_destination_port'] == 'unspecified' %}
  {% set to_destination_port = config['to_destination_port'] %}
{% elif config['to_destination_port'] in port_dictionary %}
  {% set to_destination_port = port_dictionary[config['to_destination_port']] %}
{% else %}
  {% set to_destination_port = config['to_destination_port'] %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'ether_type' not in config or config['ether_type'] == ""%}
  {% set x=config.__setitem__('ether_type', 'unspecified') %}
{% endif %}
{% if 'IP_protocol' not in config or config['IP_protocol'] == ""%}
  {% set x=config.__setitem__('IP_protocol', 'unspecified') %}
{% endif %}
{% if 'tcp_flags' not in config %}
  {% set x=config.__setitem__('tcp_flags', '') %}
{% endif %}
{% if 'match_only_fragments' not in config %}
  {% set x=config.__setitem__('match_only_fragments', 'no') %}
{% elif config['match_only_fragments'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('match_only_fragments', 'no') %}
{% endif %}
{% if 'stateful' not in config %}
  {% set x=config.__setitem__('stateful', 'no') %}
{% elif config['stateful'] not in ['no', 'yes'] %}
  {% set x=config.__setitem__('stateful', 'no') %}
{% endif %}
{% if 'arp_flag' not in config %}
  {% set x=config.__setitem__('arp_flag', 'unspecified') %}
{% elif config['arp_flag'] not in ['unspecified', 'reply', 'request'] %}
  {% set x=config.__setitem__('arp_flag', 'unspecified') %}
{% endif %}
Verify ACI Contract Filter Entry Configuration - Tenant {{config['tenant']}}, Filter {{config['filter']}}, Entry {{config['name']}}
    [Documentation]   Verifies that ACI Contract Filter Entry '{{config['name']}}' are configured under tenant '{{config['tenant']}}', Filter '{{config['filter']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Filter Name: {{config['filter']}}
    ...  - Filter Entry Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['name_alias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Ether Type: {{config['ether_type']}}
	{% if (config['ether_type'] == "ip") and (config['IP_protocol'] == "tcp") %}
	...  - IP Protocol: {{config['IP_protocol']}}
	...  - Source Port (from): {{config['from_source_port']}}
	...  - Source Port (to): {{config['to_source_port']}}
	...  - Destination Port (from): {{config['from_destination_port']}}
    ...  - Destination Port (to): {{config['to_destination_port']}}
    ...  - TCP Flags: {{config['tcp_flags']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    ...  - Stateful: {{config['stateful']}}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "udp")  %}
	...  - IP Protocol: {{config['IP_protocol']}}
	...  - Source Port (from): {{config['from_source_port']}}
	...  - Source Port (to): {{config['to_source_port']}}
	...  - Destination Port (from): {{config['from_destination_port']}}
    ...  - Destination Port (to): {{config['to_destination_port']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmp")  %}
	...  - IP Protocol: {{config['IP_protocol']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    {% if config['icmp_message'] != "" %}
    ...  - ICMPv4 Type: {{config['icmp_message']}}
    {% endif %}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmpv6")  %}
	...  - IP Protocol: {{config['IP_protocol']}}
    ...  - Apply to Fragments: {{config['match_only_fragments']}}
    {% if config['icmpv6_message'] != "" %}
    ...  - ICMPv6 Type: {{config['icmpv6_message']}}
    {% endif %}
    {% elif config['ether_type'] == "ip"  %}
	...  - IP Protocol: {{config['IP_protocol']}}
    {% elif config['ether_type'] == "arp" %}
    ...  - ARP Flag: {{config['arp_flag']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-contract
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/flt-{{config['filter']}}/e-{{config['name']}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	# Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Filter Entry does not exist		values=False
    Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.name}"   "{{config['name']}}"    Failure retreiving configuration    values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.nameAlias}"  "{{config['name_alias']}}"                 Name Alias not matching expected configuration                 values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                 values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.etherT}"  "{{config['ether_type']}}"                    Ether Type not matching expected configuration                 values=False
    {% if (config['ether_type'] == "ip") and (config['IP_protocol'] == "tcp")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sFromPort}"  "{{from_source_port}}"                     Start Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sToPort}"  "{{to_source_port}}"                         End Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dFromPort}"  "{{from_destination_port}}"                Start Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{to_destination_port}}"                    End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.tcpRules}"  "{{config['tcp_flags']}}"                   TCP Flags not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.stateful}"  "{{config['stateful']}}"                    Stateful not matching expected configuration                 values=False
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "udp")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sFromPort}"  "{{from_source_port}}"                     Start Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.sToPort}"  "{{to_source_port}}"                         End Source Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dFromPort}"  "{{from_destination_port}}"                Start Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{to_destination_port}}"                    End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmp")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{config['to_destination_port']}}"          End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    {% if config['icmp_message'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.icmpv4T}"  "{{config['icmp_message']}}"                 ICMPv4 Message Type not matching expected configuration                 values=False
    {% endif %}
    {% elif (config['ether_type'] == "ip") and (config['IP_protocol'] == "icmpv6")  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.dToPort}"  "{{config['to_destination_port']}}"          End Destination Port Block not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.applyToFrag}"  "{{config['match_only_fragments']}}"     Match Only Fragments not matching expected configuration                 values=False
    {% if config['icmpv6_message'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.icmpv6T}"  "{{config['icmpv6_message']}}"               ICMPv6 Message Type not matching expected configuration                 values=False
    {% endif %}
    {% elif config['ether_type'] == "ip"  %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.prot}"  "{{config['IP_protocol']}}"                     IP Protocol not matching expected configuration                 values=False
    {% elif config['ether_type'] == "arp" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].vzEntry.attributes.arpOpc}"  "{{config['arp_flag']}}"                     ARP Flags not matching expected configuration                 values=False
    {% endif %}

