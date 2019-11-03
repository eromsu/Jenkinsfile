{#
Verifies EPG configuration

If not specified:
* QoS Class assumed to be configured as unspecified
* Intra-EPG Isolation assumed to be configured as disabled
* Preferred Group Member assumed to be configured as exclude
* Flood on Encapsulation assumed to be configured as disabled

> The Tenant and Bridge Domain must pre-exist.
> The configuration of child objects like domain association, static bindings, etc. are not verified in this test case.
#}
{% if 'description' not in config %}
  {% set x=config.__setitem__('description', '') %}
{% endif %}
{% if 'custom_qos_pol' not in config %}
  {% set x=config.__setitem__('custom_qos_pol', '') %}
{% endif %}
{% if 'intra_epg_isolation' not in config %}
  {% set x=config.__setitem__('intra_epg_isolation', 'unenforced') %}
{% elif config['intra_epg_isolation'] not in ['unenforced', 'enforced'] %}
  {% set x=config.__setitem__('intra_epg_isolation', 'unenforced') %}
{% endif %}
{% if 'dataPlanePolicer' not in config %}
  {% set x=config.__setitem__('dataPlanePolicer', '') %}
{% endif %}
{% if 'prefGrMemb' not in config %}
  {% set x=config.__setitem__('prefGrMemb', 'exclude') %}
{% elif config['prefGrMemb'] not in ['exclude', 'include'] %}
  {% set x=config.__setitem__('prefGrMemb', 'exclude') %}
{% endif %}
{% if 'floodOnEncap' not in config %}
  {% set x=config.__setitem__('floodOnEncap', 'disabled') %}
{% elif config['floodOnEncap'] not in ['disabled', 'enabled'] %}
  {% set x=config.__setitem__('floodOnEncap', 'disabled') %}
{% endif %}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'qos_class' not in config %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% elif config['qos_class'] not in ['unspecified', 'level1', 'level2', 'level3'] %}
  {% set x=config.__setitem__('qos_class', 'unspecified') %}
{% endif %}
Verify ACI EPG Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['name']}}
    [Documentation]   Verifies that ACI EPG '{{config['name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG Name: {{config['name']}}
    {% if config['nameAlias'] != "" %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if config['description'] != "" %}
    ...  - Description: {{config['description']}}
    {% endif %}
    ...  - Associated to BD: {{config['bridge_domain']}}
    {% if config['custom_qos_pol'] != "" %}
    ...  - Custom QoS Policy: {{config['custom_qos_pol']}}
    {% endif %}
    ...  - QoS Class: {{config['qos_class']}}
    ...  - Intra EPG Isolation: {{config['intra_epg_isolation']}}
    {% if config['dataPlanePolicer'] != "" %}
    ...  - Data-Plane Policer: {{config['dataPlanePolicer']}}
    {% endif %}
    ...  - Preferred Group Member: {{config['prefGrMemb']}}
    ...  - Flood on Encapsulation: {{config['floodOnEncap']}}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Should Be Equal as Strings      ${return.payload[0].fvAEPg.attributes.name}   {{config['name']}}                            Failure retreiving configuration		                          values=False
    {% if config['nameAlias'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.nameAlias}"  "{{config['nameAlias']}}"               Name alias not matching expected configuration                values=False
    {% endif %}
    {% if config['description'] != "" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.descr}"  "{{config['description']}}"                 Description not matching expected configuration               values=False
    {% endif %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.prio}"  "{{config['qos_class']}}"                    QoS Class not matching expected configuration                 values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.prefGrMemb}"  "{{config['prefGrMemb']}}"             Preferred Group Member not matching expected configuration    values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.pcEnfPref}"  "{{config['intra_epg_isolation']}}"     Intra EPG Isolation not matching expected configuration       values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvAEPg.attributes.floodOnEncap}"  "{{config['floodOnEncap']}}"         Flood on Encapsulation not matching expected configuration    values=False
    # Verify BD association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rsbd
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvRsBd.attributes.tnFvBDName}   {{config['bridge_domain']}}   Associated Bridge Domain not matching expected configuration		values=False
    {% if config['custom_qos_pol'] != "" %}
    # Verify Custom QoS Policy
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rscustQosPol
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsCustQosPol.attributes.tnQosCustomPolName}"   "{{config['custom_qos_pol']}}"   Custom QoS Policy not matching expected configuration		values=False
    {% endif %}
    # Verify Data-Plane Policer
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['name']}}/rsdppPol
    ${return}  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    {% if config['dataPlanePolicer'] == "" %}
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  0		Data-Plane Policer not matching expected configuration		values=False
    {% else %}
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fvRsDppPol.attributes.tnQosDppPolName}   {{config['dataPlanePolicer']}}   Data-Plane Policer not matching expected configuration		values=True
    {% endif %}

