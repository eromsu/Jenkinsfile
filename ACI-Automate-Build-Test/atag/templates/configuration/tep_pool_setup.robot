{#
Verifies ACI TEP Pool Configuration.

> The template reads the intended TEP Pool configuration from two DAFE excel workbooks:
> * 'fabric_initial_config' workbook for POD 1
> * 'pod_tep_pool' for all other PODs

#}
{% set tepDict = [{'pod_id': '1', 'tep_pool': dafe_data.fabric_initial_config.row(parameters='TEP Pool').value,}] %}
{% for row in dafe_data.pod_tep_pool %}
{% set x = tepDict.append({'pod_id': row.pod_id, 'tep_pool': row.tep_pool}) %}
{% endfor %}
{% for pod in tepDict %}
Verify ACI TEP Pool Configuration - POD {{pod.pod_id}}
    [Documentation]   Verifies that ACI TEP Pool Configuration for POD {{pod.pod_id}}
    ...  - POD ID: {{pod.pod_id}}
    ...  - TEP Pool: {{pod.tep_pool}}
    [Tags]      aci-conf  aci-fabric-tep-pool
    ${return}=  via ACI REST API retrieve "/api/mo/uni/controller/setuppol/setupp-{{pod.pod_id}}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}   200      Failure executing API call		values=False
    should be equal as strings      ${return.totalCount}  1     Fabric POD does not exist	values=False
    Run keyword And Continue on Failure  Should Be Equal as Strings      ${return.payload[0].fabricSetupP.attributes.tepPool}   {{pod.tep_pool}}        TEP Pool not matching expected configuration	            values=False


{% endfor %}