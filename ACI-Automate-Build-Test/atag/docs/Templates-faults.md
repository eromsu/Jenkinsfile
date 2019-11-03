# Overview
These tests checkes verfies the number of critical, major, and minor faults present in the fabric for against the "expected" baseline. These tests typically focus on individual components of the configuration. 

## anyDomP.robot
### Template Description:
Checks Physical, External Bridged, External Routed, and VMware VMM domain for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
type | Domain type | True |   | DAFE Excel Sheet
name | Domain Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
{% if config['type'] == 'physical' %} 
Checking ACI Physical Domain for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for Physical Domain '{{config['name']}}'
	...  - Domain Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/phys-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% elif config['type'] == 'external_l3' %}
Checking ACI L3 External Domain for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for L3 External Domain '{{config['name']}}'
	...  - Domain Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/l3dom-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% elif config['type'] == 'external_l2' %}
Checking ACI L2 External Domain for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for L2 External Domain '{{config['name']}}'
	...  - Domain Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/l2dom-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% elif config['type'] == 'vmm_vmware' %}
Checking ACI VMware VMM VLAN Pool Association for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for VMware VMM Domain '{{config['name']}}'
	...  - Domain Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% endif %}


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'type': {'descr': 'Domain type',
          'enum': ['physical', 'external_l3', 'external_l2', 'vmm_vmware'],
          'mandatory': True,
          'source': 'workbook'}}
```
## bgpInstP.robot
### Template Description:
Checks Fabric BGP configuration for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI Fabric BGP Configuration for Faults
    [Documentation]   Verifies ACI faults for Fabric BGP Configuration
    ...  - Policy Name: default
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-bgp
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/fabric/bgpInstP-default/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'}}
```
## bgpPeerP.robot
### Template Description:
Checks L3 Node Level BGP Peer for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
l3out | Parent L3 Out Name | True |   | DAFE Excel Sheet
bgp_peer_ip | BGP Peer IP Address | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
tenant | Parent tenant name | True |   | DAFE Excel Sheet
l3out_node_profile | L3Out Node Profile Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI L3Out Node Level BGP Peer for Faults - Tenant {{config['tenant']}}, L3Out {{config['l3out']}}, Node Profile {{config['l3out_node_profile']}}, Peer {{config['bgp_peer_ip']}}
    [Documentation]   Verifies ACI faults for L3Out Node Level BGP Peer '{{config['bgp_peer_ip']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3out']}}', Node Profile '{{config['l3out_node_profile']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3out']}}
    ...  - Node Profile Name: {{config['l3out_node_profile']}}
    ...  - BGP Peer: {{config['bgp_peer_ip']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-l3out
    # Retrieve Faults
    {% if config['tenant'] == "infra" and config['isGolfPeer'] == "yes" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/infraPeerP--[{{config['bgp_peer_ip']}}]/fltCnts
    {% else %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3out']}}/lnodep-{{config['l3out_node_profile']}}/peerP-[{{config['bgp_peer_ip']}}]/fltCnts
    {% endif %}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "BGP Peer has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'bgp_peer_ip': {'descr': 'BGP Peer IP Address',
                 'mandatory': True,
                 'source': 'workbook',
                 'type': 'str'},
 'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'l3out': {'descr': 'Parent L3 Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'l3out_node_profile': {'descr': 'L3Out Node Profile Name',
                        'length': [1, 64],
                        'mandatory': True,
                        'regex': {'exact_match': False,
                                  'pattern': '[a-zA-Z0-9_.:-]+'},
                        'source': 'workbook',
                        'type': 'str'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'tenant': {'descr': 'Parent tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## datetimeNtpProv.robot
### Template Description:
Checks Datetime NTP Provider configuration for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
datetime_pol_name | NTP Profile Name | True | None | wordbook
critical | Critical fault threshold | True |   | ATAG config file
name | NTP FQDN or IP | True | None | wordbook
minor | Minor fault threshold | True |   | ATAG config file
major | Major fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI Datetime NTP Provider Configuration for Faults - Provider '{{config['name']}}'
    [Documentation]   Verifies ACI faults for Datetime Profile Configuration
    ...  - Datetime Profile Name: {{config['datetime_pol_name']}}
    ...  - NTP Provider: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-ntp
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/fabric/time-{{config['datetime_pol_name']}}/ntpprov-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'datetime_pol_name': {'default': 'None',
                       'descr': 'NTP Profile Name',
                       'length': [1, 64],
                       'mandatory': True,
                       'regex': {'exact_match': False,
                                 'pattern': '[a-zA-Z0-9_.:-]+'},
                       'source': 'wordbook',
                       'type': 'str'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'default': 'None',
          'descr': 'NTP FQDN or IP',
          'mandatory': True,
          'source': 'wordbook',
          'type': 'str'}}
```
## datetimePol.robot
### Template Description:
Checks Datatime / NTP Profile configuration for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | NTP Profile Name | False | default | wordbook
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI Datetime Profile Configuration for Faults - Profile '{{config['name']}}'
    [Documentation]   Verifies ACI faults for Datetime Profile Configuration
    ...  - Profile Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-ntp
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/fabric/time-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'default': 'default',
          'descr': 'NTP Profile Name',
          'length': [1, 64],
          'mandatory': False,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'wordbook',
          'type': 'str'}}
```
## fvAEPg.robot
### Template Description:
Checks EPG for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | EPG name | True | None | DAFE Excel Sheet
app_profile | EPG parent Application Profile Name | True | None | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file
tenant | EPG parent Tenant Name | True | None | DAFE Excel Sheet


### Template Body:
```
Checking ACI EPG for Faults - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}
    [Documentation]   Verifies ACI faults for EPG '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-epg
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "EPG has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'app_profile': {'default': 'None',
                 'descr': 'EPG parent Application Profile Name',
                 'length': [1, 64],
                 'mandatory': True,
                 'regex': {'exact_match': False,
                           'pattern': '[a-zA-Z0-9_.:-]+'},
                 'source': 'workbook',
                 'type': 'str'},
 'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'default': 'None',
          'descr': 'EPG name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'default': 'None',
            'descr': 'EPG parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvBD.robot
### Template Description:
Checks Bridge Domain for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | BD parent Tenant Name | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | Bridge Domain Name | True |   |  
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI BD for Faults - Tenant {{config['tenant']}}, BD {{config['name']}}
    [Documentation]   Verifies ACI faults for VRF '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-bd
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "BD has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "BD has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "BD has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'Bridge Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'type': 'str'},
 'tenant': {'descr': 'BD parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvCtx.robot
### Template Description:
Checks VRF for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | VRF parent Tenant Name | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | VRF Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI VRF for Faults - Tenant {{config['tenant']}}, VRF {{config['name']}}
    [Documentation]   Verifies ACI faults for VRF '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - VRF Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-vrf
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ctx-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "VRF has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'VRF Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'descr': 'VRF parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## fvnsVlanInstP.robot

### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
alloc_mode | VLAN Pool Allocation Mode | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file
name | VLAN Pool Name | True |   | DAFE Excel Sheet


### Template Body:
```
Checking ACI VLAN Pool for Faults - VLAN Pool {{config['name']}}
    [Documentation]   Verifies ACI faults for VLAN Pool '{{config['name']}}'
    ...  - VLAN Pool Name: {{config['tenant']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-vlan-pool
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/vlanns-[{{config['name']}}]-{{config['alloc_mode']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "VLAN Pool has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'alloc_mode': {'descr': 'VLAN Pool Allocation Mode',
                'enum': ['static', 'dynamic'],
                'mandatory': True,
                'source': 'workbook'},
 'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'VLAN Pool Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## infraAccBndlGrp.robot
### Template Description:
Checks Leaf/Spine Interface Policy Group for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | Name of the Interface Policy-Group | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
{% if config['switch_type'] == "leaf" %}
	{% if config['interface_policy_group_type'] == "vPC" %}
		{% set uri_tag = 'accbundle' %}
	{% elif config['interface_policy_group_type'] == "PC" %}
		{% set uri_tag = 'accbundle' %}
	{% elif config['interface_policy_group_type'] == "Access" %}
		{% set uri_tag = 'accportgrp' %}
	{% endif %}
{% endif %}
{% if config['switch_type'] == "leaf" %}
Checking ACI Leaf Interface Policy Group for Faults - Policy Group Name {{config['name']}}
    [Documentation]   Verifies ACI faults for Leaf Interface Policy Group '{{config['name']}}'
    ...  - Interface Policy Group Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-policy-group
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/funcprof/{{uri_tag}}-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% elif config['switch_type'] == "spine" %}
Checking ACI Spine Interface Policy Group for Faults - Policy Group Name {{config['name']}}
    [Documentation]   Verifies ACI faults for Spine Interface Policy Group '{{config['name']}}'
    ...  - Interface Policy Group Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-policy-group
    # Retrieve Faults
    ${uri} =  Set Variable  //api/node/mo/uni/infra/funcprof/spaccportgrp-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Policy Group has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% endif %}


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'Name of the Interface Policy-Group',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## infraAccPortP.robot
### Template Description:
Checks Leaf/Spine Interface Profile for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
profile_type | Interface profile type | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | Interface profile name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
{% if config['profile_type'] == "leaf" %}
Checking ACI Leaf Interface Profile for Faults - Profile {{config['name']}}
    [Documentation]   Verifies ACI faults for Leaf Interface Profile '{{config['name']}}'
    ...  - Profile Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/accportprof-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% elif config['profile_type'] == "spine" %}
Checking ACI Spine Interface Profile for Faults - Profile {{config['name']}}
    [Documentation]   Verifies ACI faults for Spine Interface Profile '{{config['name']}}'
    ...  - Profile Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-interface-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/spaccportprof-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Interface Profile has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% endif %}


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'Interface profile name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'profile_type': {'descr': 'Interface profile type',
                  'enum': ['leaf', 'spine'],
                  'mandatory': True,
                  'source': 'workbook'}}
```
## infraAttEntityP.robot
### Template Description:
Checks Access Attachable Entity Profile for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | Name of the Access Attachable Entity Profile (AAEP)  | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI AAEP for Faults - AAEP {{config['name']}}
    [Documentation]   Verifies ACI faults for AAEP '{{config['name']}}'
	...  - AAEP Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-aaep
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/attentp-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "AAEP has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'Name of the Access Attachable Entity Profile (AAEP) ',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## infraNodeP.robot
### Template Description:
Checks Leaf/Spine Switch Profiles for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name |   | True | None | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
{% if config['switch_profile_type'] == "leaf" %}
Checking ACI Leaf Switch Profile for Faults - Profile {{config['name']}}
    [Documentation]   Verifies ACI faults for Leaf Switch Profile '{{config['name']}}'
    ...  - Profile Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-switch-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/nprof-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% elif config['switch_profile_type'] == "spine" %}
Checking ACI Spine Switch Profile for Faults - Profile {{config['name']}}
    [Documentation]   Verifies ACI faults for Spine Switch Profile '{{config['name']}}'
    ...  - Profile Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-switch-profile
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/infra/spprof-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Switch Profile has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% endif %}


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'default': 'None',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## instP.robot
### Template Description:
Checks L3Out External EPG for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
l3out | L3Out Name | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | External EPG Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet


### Template Body:
```
Checking ACI L3Out External EPG for Faults - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['name']}}
    [Documentation]   Verifies ACI faults for External EPG '{{config['name']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3_out']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3_out']}}
    ...  - External EPG: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-vrf
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "External EPG has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "External EPG has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "External EPG has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'l3out': {'descr': 'L3Out Name',
           'length': [1, 64],
           'mandatory': True,
           'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
           'source': 'workbook',
           'type': 'str'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'External EPG Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## l3extOut.robot
### Template Description:
Checks L3Out for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | Parent Tenant Name | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | L3 Out Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI L3Out for Faults - Tenant {{config['tenant']}}, L3Out {{config['name']}}
    [Documentation]   Verifies ACI faults for L3Out '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-l3out
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "L3Out has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "L3Out has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "L3Out has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'L3 Out Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'descr': 'Parent Tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## vmmDomP.robot
### Template Description:
Checks VMware VMM Domain for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | VMM Domain Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
{% if 'vmm_type' not in config %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% elif config['target_dscp'] not in ['vmware'] %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% endif %}
{% if config['vmm_type'] == "vmware" %}
Checking VMware VMM Domain for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for VMware VMM Domain '{{config['name']}}'
    ...  - VMM Domain Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-vmm  aci-vmm-vmware
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "VMM Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"
{% endif %}


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'VMM Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## vpcDom.robot
### Template Description:
Checks vPC Domain (also called vPC explicit protection group) for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | vPC Domain Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI vPC Domain for Faults - Domain {{config['name']}}
    [Documentation]   Verifies ACI faults for vPC Domain (or vPC Explicit Protection Group) '{{config['name']}}'
    ...  - vPC Domain Name:  {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-fabric  aci-fabric-vpc-domain
    # Retrieve Faults
    ${uri} =  Set Variable  /api/node/mo/uni/fabric/protpol/expgep-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "vPC Domain has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'vPC Domain Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'}}
```
## vzBrCp.robot
### Template Description:
Checks Contract for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant | Parent tenant Name | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | Contract Name | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI Contract for Faults - Tenant {{config['tenant']}}, Contract {{config['name']}}
    [Documentation]   Verifies ACI faults for Contract '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Contract Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/brc-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'descr': 'Contract Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'descr': 'Parent tenant Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## vzEntry.robot
### Template Description:
Checks Contract Filter Entry for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
filter | Filter Name | True | None | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name | Filter Entry Name | True | None | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file
tenant | Tenant name | True |   | DAFE Excel Sheet


### Template Body:
```
Checking ACI Contract Filter Entry for Faults - Tenant {{config['tenant']}}, Filter {{config['filter']}}, Entry {{config['name']}}
    [Documentation]   Verifies ACI faults for Contract Filter Entry '{{config['name']}}' under tenant '{{config['tenant']}}', filter '{{config['filter']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Filter Name: {{config['filter']}}
    ...  - Filter Entry Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/flt-{{config['filter']}}/e-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter Entry has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'filter': {'default': 'None',
            'descr': 'Filter Name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'default': 'None',
          'descr': 'Filter Entry Name',
          'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'descr': 'Tenant name',
            'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
## vzFilter.robot
### Template Description:
Checks Contract Filter for faults.


### Templates Variables:
Variable | Description | Mandatory | Default Value | Data Source
 --- | --- | --- | --- | ---
tenant |   | True |   | DAFE Excel Sheet
major | Major fault threshold | True |   | ATAG config file
critical | Critical fault threshold | True |   | ATAG config file
name |   | True |   | DAFE Excel Sheet
minor | Minor fault threshold | True |   | ATAG config file


### Template Body:
```
Checking ACI Contract Filter for Faults - Tenant {{config['tenant']}}, Filter {{config['name']}}
    [Documentation]   Verifies ACI faults for Contract Filter '{{config['name']}}' under tenant '{{config['tenant']}}'
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Filter Name: {{config['name']}}
    ...  - Critical fault count <= {{config['critical']}}
    ...  - Major fault count <= {{config['major']}}
    ...  - Minor fault count <= {{config['minor']}}
    [Tags]      aci-faults  aci-tenant  aci-tenant-contract
    # Retrieve Faults
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/flt-{{config['name']}}/fltCnts
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}        200		Failure executing API call		values=False
    # Verify Fault Count
	Should Be Equal as Integers     ${return.totalCount}    1		Failure retreiving faults		values=False
    ${critical_count} =     Set Variable   ${return.payload[0].faultCounts.attributes.crit}
    ${major_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.maj}
    ${minor_count} =        Set Variable   ${return.payload[0].faultCounts.attributes.minor}
    run keyword if  not ${critical_count} <= {{config['critical']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${critical_count} critical faults (passing threshold {{config['critical']}})"
    run keyword if  not ${major_count} <= {{config['major']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${major_count} major faults (passing threshold {{config['major']}})"
    run keyword if  not ${minor_count} <= {{config['minor']}}  Run keyword And Continue on Failure
    ...  Fail  "Contract Filter has ${minor_count} minor faults (passing threshold {{config['minor']}})"


```
### Template Data Validation Model:
```json
{'critical': {'descr': 'Critical fault threshold',
              'mandatory': True,
              'range': [0, 9999],
              'source': 'config',
              'type': 'int'},
 'major': {'descr': 'Major fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'minor': {'descr': 'Minor fault threshold',
           'mandatory': True,
           'range': [0, 9999],
           'source': 'config',
           'type': 'int'},
 'name': {'length': [1, 64],
          'mandatory': True,
          'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
          'source': 'workbook',
          'type': 'str'},
 'tenant': {'length': [1, 64],
            'mandatory': True,
            'regex': {'exact_match': False, 'pattern': '[a-zA-Z0-9_.:-]+'},
            'source': 'workbook',
            'type': 'str'}}
```
