{# 
Verifies EPG association of Physical or VMware VMM Domain

If not specified the deployment immediacy will default to "on-demand"
If not specified the resolution immediacy will default to "on-demand" (not applicable for physical domain)

> The Tenant, Application Profile and EPG must pre-exist.
> The configuration of domains are not verified by this template

If the EPG is associated to a VMware VMM Domain the resulting DVS port-group are assumed to have the following default properties:
  * allowPromiscuous="reject" 
  * forgedTransmits="reject" 
  * macChanges="reject"
  * switchingMode="native"

Unless specified otherwise will the test case assume netflow preference to be "disabled" for VMware VMM Domains.
#}
{% if 'netflowPref' not in config %}
  {% set x=config.__setitem__('netflowPref', 'disabled') %}
{% elif config['netflowPref'] not in ['enabled', 'disabled'] %}
  {% set x=config.__setitem__('netflowPref', 'disabled') %}
{% endif %}
{% if 'staticVlanForVmm' not in config or config['staticVlanForVmm'] == ""  %}
  {% set x=config.__setitem__('staticVlanForVmm', 'unknown') %}
{% endif %}
{% if 'deployImedcy' not in config %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% elif config['deployImedcy'] not in ['immediate', 'lazy'] %}
  {% set x=config.__setitem__('deployImedcy', 'lazy') %}
{% endif %}
{% if 'resImedcy' not in config %}
  {% set x=config.__setitem__('resImedcy', 'lazy') %}
{% elif config['resImedcy'] not in ['immediate', 'lazy', 'pre-provision'] %}
  {% set x=config.__setitem__('resImedcy', 'lazy') %}
{% endif %}
{% if config['domainType'] == "vmm_vmware" %}
  {% set tDn %}uni/vmmp-VMware/dom-{{config['domainName']}}{% endset %}
{% else %}
  {% set tDn %}uni/phys-{{config['domainName']}}{% endset %}
{% endif %}
Verify ACI EPG Domain Configuration - Tenant {{config['tenant']}}, App Profile {{config['app_profile']}}, EPG {{config['epg_name']}}, Domain {{config['domainName']}}
    [Documentation]   Verifies that ACI EPG Domain association for '{{config['epg_name']}}' under tenant '{{config['tenant']}}' are configured with the expected parameters
    ...  - Tenant Name: {{config['tenant']}}
    ...  - Application Profile Name: {{config['app_profile']}}
    ...  - EPG name: {{config['epg_name']}}
    ...  - Domain Name: {{config['domainName']}}
    ...  - Domain Type: {{config['domainType']}}
    ...  - Deployment Immediacy: {{config['deployImedcy']}}
    ...  - Resolution Immediacy: {{config['resImedcy']}}
    {% if config['domainType'] == "vmm_vmware" %}
    ...  - DVS Switching Mode: native
    ...  - DVS Netflow Preference: {{config['netflowPref']}}
    ...  - DVS Static Encapsulation: {{config['staticVlanForVmm']}}
    ...  - DVS Allow Promiscuous: reject
    ...  - DVS Forge Transmits: reject
    ...  - DVS Mac Changes: reject
    {% endif %}
    [Tags]      aci-conf  aci-tenant  aci-tenant-epg
	  # Retrieve Configuration
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['tenant']}}/ap-{{config['app_profile']}}/epg-{{config['epg_name']}}/rsdomAtt-[{{tDn}}]
    ${filter} =  Set Variable  	rsp-subtree=full&rsp-subtree-class=vmmSecP
    ${return}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  # Verify Configuration Parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Domain not associated with EPG		values=False
	  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.tDn}"   "{{tDn}}"                            Failure retreiving configuration		                          values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.instrImedcy}"  "{{config['deployImedcy']}}"               Deployment Immediacy not matching expected configuration                values=False
    {% if config['domainType'] == "vmm_vmware" %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.resImedcy}"  "{{config['resImedcy']}}"                    Resolution Immediacy not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.switchingMode}"  "native"                                 DVS switching mode not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.netflowPref}"  "{{config['netflowPref']}}"                DVS netflow preference not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.attributes.encap}"  "{{config['staticVlanForVmm']}}"                 DVS static encapsulation not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.allowPromiscuous}"  "reject"          DVS allow promiscuous not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.forgedTransmits}"  "reject"           DVS forged transmits not matching expected configuration                values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsDomAtt.children[0].vmmSecP.attributes.macChanges}"  "reject"                DVS mac changes not matching expected configuration                values=False
    {% endif %}

