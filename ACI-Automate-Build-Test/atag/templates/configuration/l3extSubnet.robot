{#
Verifies L3Out External EPG Subnet configuration

> The Tenant, L3Out, and Node Profile must pre-exist.
#}
{% if config['aggregate_shared_routes'] == "yes" and config['aggregate_shared_routes'] == "yes" %}
    {% set aggregate = 'shared-rtctrl' %}
{% else %}
    {% set aggregate = '' %}
{% endif %}
{% set scope = [] %}
{% if config['external_subnet_for_external_epg'] == "yes" %}{% set scope = scope + [("import-security")] %}{% endif %}
{% if config['export_route_control'] == "yes" %}{% set scope = scope + [("export-rtctrl")] %}{% endif %}
{% if config['shared_route_control'] == "yes" %}{% set scope = scope+ [("shared-rtctrl")] %}{% endif %}
{% if config['shared_security'] == "yes" %}{% set scope = scope + [("shared-security")] %}{% endif %}
{% if config['route_control_profile'] != "" %}
Verify ACI L3Out External EPG Subnet Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['external_epg']}}, Subnet {{config['external_subnet']}}, Route Control Profile '{{config['route_control_profile']}}'
{% else %}
Verify ACI L3Out External EPG Subnet Configuration - Tenant {{config['tenant']}}, L3Out {{config['l3_out']}}, External EPG {{config['external_epg']}}, Subnet {{config['external_subnet']}}
{% endif %}
    [Documentation]   Verifies that ACI L3Out External EPG Subnet '{{config['subnet']}}' under tenant '{{config['tenant']}}', L3Out '{{config['l3_out']}}', External EPG '{{config['external_epg']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - L3Out Name: {{config['l3_out']}}
    ...  - External EPG: {{config['external_epg']}}
    ...  - Subnet: {{config['external_subnet']}}
    ...  - External Subnet for External EPG: {{config['external_subnet_for_external_epg']}}
    ...  - Export Route Control: {{config['export_route_control']}}
    ...  - Shared Route Control: {{config['shared_route_control']}}
    ...  - Shared Security Import: {{config['shared_security']}}
    ...  - Aggregated Shared Route: {{config['aggregate_shared_routes']}}
    ...  - Route Control Profile: {{config['route_control_profile']}}
    ...  - Route Control Profile Direction: {{config['route_control_profile_direction']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-l3out
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['external_epg']}}/extsubnet-[{{config['external_subnet']}}]
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
    Should Be Equal as Integers     ${return.totalCount}  1		Subnet not associated with External EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extSubnet.attributes.aggregate}"  "{{aggregate}}"                     Aggregate not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].l3extSubnet.attributes.scope}"      "{{scope|join(',')}}"               Scope not matching expected configuration                 values=False
    {% if config['route_control_profile'] != "" %}
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/out-{{config['l3_out']}}/instP-{{config['external_epg']}}/extsubnet-[{{config['external_subnet']}}]/rssubnetToProfile-[{{config['route_control_profile']}}]-{{config['route_control_profile_direction']|default('import',True)}}
    ${return} =  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}   1		Route Profile or Route Profile Direction not matching expected configuration		values=False
    {% endif %}
