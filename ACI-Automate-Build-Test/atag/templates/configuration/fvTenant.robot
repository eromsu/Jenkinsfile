{#
Verifies tenant configuration including associated security domains.

Given the way the DAFE excel is build will a test case be generated per security domain.

> The configuration of child objects like VRFs, BDs, etc. are not verified in this test case template.
#}
{% if 'nameAlias' not in config %}
  {% set x=config.__setitem__('nameAlias', '') %}
{% endif %}
{% if 'security_domain' not in config %}
  {% set x=config.__setitem__('security_domain', '') %}
{% endif %}
{% if 'Description' not in config %}
  {% set x=config.__setitem__('Description', '') %}
{% endif %}
{% if 'mon_policy' not in config %}
  {% set x=config.__setitem__('mon_policy', '') %}
{% endif %}
{% if config['security_domain'] != "" %}
Verify ACI Tenant Configuration - Tenant {{config['name']}}, Security Domain {{config['security_domain']}}
{% else %}
Verify ACI Tenant Configuration - Tenant {{config['name']}}
{% endif %}
    [Documentation]   Verifies that ACI tenant '{{config['name']}}' are configured with the expected parameters:
    ...  - Tenant Name: {{config['name']}}
    {% if 'nameAlias' not in config %}
    ...  - Name Alias: {{config['nameAlias']}}
    {% endif %}
    {% if 'description' not in config %}
    ...  - Description: {{config['description']}}
    {% endif %}
    {% if config['security_domain'] != "" %}
    ...  - Security Domain: {{config['security_domain']}}
    {% endif %}
    {% if config['mon_policy'] != "" %}
    ...  - Monitoring Policy: {{config['mon_policy']}}
    {% endif %}
    [Tags]      aci-conf  aci-tenant
    # Retrieve Tenant
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['name']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
    # Verify Tenant parameters
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.dn}     uni/tn-{{config['name']}}       Failure retreiving configuration                    values=False
    Should Be Equal as Strings      ${return.payload[0].fvTenant.attributes.name}   {{config['name']}}              Failure retreiving configuration                    values=False
    {% if 'nameAlias' not in config %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvTenant.attributes.nameAlias}"  "{{config['nameAlias']}}"   Name alias not matching expected configuration     values=False
    {% endif %}
    {% if 'description' not in config %}
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvTenant.attributes.descr}"  "{{config['description']}}"   Description not matching expected configuration     values=False
    {% endif %}
    {% if config['security_domain'] != "" %}
    # Verify Security Domain association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['name']}}/domain-{{config['security_domain']}}
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Run keyword And Continue on Failure  Should Be Equal as Integers     ${return.totalCount}  1		Security Domain associated with tenant		values=False
    {% endif %}
    {% if config['mon_policy'] != "" %}
    # Verify Monitoring Policy association
    ${uri} =  Set Variable  /api/mo/uni/tn-{{config['name']}}/rsTenantMonPol
    ${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200		Failure executing API call		values=False
	  Should Be Equal as Integers     ${return.totalCount}  1		Failure retreiving configuration		values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      "${return.payload[0].fvRsTenantMonPol.attributes.tnMonEPGPolName}"   "{{config['mon_policy']}}"              Monitoring policy not matching expected configuration                    values=False
    {% endif %}
