{#
Verifies EPG contract association.

> The Tenant, Application Profile and EPG must pre-exist.
> The configuration of the contract are not verified by this template
#}
{% if 'consumed_ctr' not in config %}
  {% set x=config.__setitem__('consumed_ctr', 'no') %}
{% elif config['consumed_ctr'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('consumed_ctr', 'no') %}
{% endif %}
{% if 'provided_ctr' not in config %}
  {% set x=config.__setitem__('provided_ctr', 'no') %}
{% elif config['provided_ctr'] not in ['yes', 'no'] %}
  {% set x=config.__setitem__('provided_ctr', 'no') %}
{% endif %}
Verify ACI EPG Contract Configuration - App Profile {{config['app_profile']}}, EPG {{config['name']}}, Contract {{config['contract']}}
    [Documentation]   Verifies that ACI EPG Contract association for '{{config['contract']}}' are configured under tenant '{{config['tenant']}}'are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    ...  - Contract name: {{config['contract']}}
    ...  - Consume Contract: {{config['consumed_ctr']}}
    ...  - Provide Contract: {{config['provided_ctr']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
    {% if config['consumed_ctr'] == "yes" %}
    # Retrieve Configuration (consume contract)
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rscons-{{config['contract']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure      Should Be Equal as Integers     ${return.totalCount}  1		Contract not consumed by EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings         "${return.payload[0].fvRsCons.attributes.tnVzBrCPName}"  "{{config['contract']}}"               Consumed Contract not matching expected configuration                values=False
    {% endif %}
    {% if config['provided_ctr'] == "yes" %}
    # Retrieve Configuration (provide contract)
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rsprov-{{config['contract']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    Run keyword And Continue on Failure      Should Be Equal as Integers     ${return.totalCount}  1		Contract not provided by EPG		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings         "${return.payload[0].fvRsProv.attributes.tnVzBrCPName}"  "{{config['contract']}}"               Provided Contract not matching expected configuration                values=False
    {% endif %}

