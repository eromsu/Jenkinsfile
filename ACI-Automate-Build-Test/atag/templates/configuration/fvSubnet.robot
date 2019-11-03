{# 
Verifies Bridge Domain Subnet configuration

> The BD itself are not verified in this test case template.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'is_primary_address' not in config %}
  {% set x=config.__setitem__('is_primary_address', 'no') %}
{% elif config['is_primary_address'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('is_primary_address', 'no') %}
{% endif %}
{% if 'is_virtual_ip' not in config %}
  {% set x=config.__setitem__('is_virtual_ip', 'no') %}
{% elif config['is_virtual_ip'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('is_virtual_ip', 'no') %}
{% endif %}
{% if 'l3out_for_route_control' not in config %}
  {% set x=config.__setitem__('l3out_for_route_control', '') %}
{% endif %}
{% if 'route_control_profile' not in config %}
  {% set x=config.__setitem__('route_control_profile', '') %}
{% endif %}
{% if 'ndRAprefixPolicy' not in config %}
  {% set x=config.__setitem__('ndRAprefixPolicy', '') %}
{% endif %}
Verify ACI BD Subnet Configuration - Tenant {{config['tenant']}}, BD {{config['bridge_domain']}}, Subnet {{config['bd_subnet']}}
    [Documentation]   Verifies that ACI BD Subnet '{{config['bd_subnet']}}' under tenant '{{config['tenant']}}', BD '{{config['bridge_domain']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['tenant']}}
    ...  - BD Name: {{config['bridge_domain']}}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
  	...  - Subnet: {{config['bd_subnet']}}
    ...  - Subnet Scope: {{config['subnet_scope']}}
    ...  - Primary IP Address: {{config['is_primary_address']}}
    ...  - Virtual IP Address: {{config['is_virtual_ip']}}
    ...  - Subnet Control: {{config['subnet_control']}}
    {% if config['route_control_profile'] != "" %}
    ...  - Route Profile: {{config['route_control_profile']}}
    ...  - L3Out for Route Profile: {{config['l3out_for_route_control']}}
    {% endif %}
  	...  - ND RA Prefix Policy Name: {{config['ndRAprefixPolicy']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-bd
    # Retrieve BD
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bridge_domain']}}/subnet-[{{config['bd_subnet']}}]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		BD Subnet not configured		values=False
    Should Be Equal as Strings      ${return.payload[0].fvSubnet.attributes.ip}   {{config['bd_subnet']}}      Failure retreiving configuration		                          values=False
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.descr}"  "{{config['description']}}"                    Description not matching expected configuration                       values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.scope}"  "{{config['subnet_scope']}}"                   Subnet Scope not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.preferred}"  "{{config['is_primary_address']}}"         Primary IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.virtual}"  "{{config['is_virtual_ip']}}"                Virtual IP Address not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvSubnet.attributes.ctrl}"  "{{config['subnet_control']}}"                  Subnet Control not matching expected configuration                       values=False
    {% if config['route_control_profile'] != "" %}
    # Route Profile
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bridge_domain']}}/subnet-[{{config['bd_subnet']}}]/rsBDSubnetToProfile
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (Route Profile)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (Route Profile)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDSubnetToProfile.attributes.tnL3extOutName}"  "{{config['l3out_for_route_control']}}"                    L3Out for Route Profile not matching expected configuration                       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsBDSubnetToProfile.attributes.tnRtctrlProfileName}"  "{{config['route_control_profile']}}"                 Route Profile not matching expected configuration                       values=False
    {% endif %}
    {% if config['ndRAprefixPolicy'] != "" %}
    # ND RA Prefix Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/BD-{{config['bridge_domain']}}/subnet-[{{config['bd_subnet']}}]/rsNdPfxPol
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call (ND RA Prefix Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration (ND RA Prefix Policy)		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsNdPfxPol.attributes.tnNdPfxPolName}"  "{{config['ndRAprefixPolicy']}}"                    ND RA Prefix Policy not matching expected configuration                       values=False
    {% endif %}

