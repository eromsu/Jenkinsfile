{#
Verifies APIC CIMC login using SSH
#}
{% set cimc_ip = config['cimc_ip'].split('/') %}
Verify CIMC Login - APIC {{config['apic_id']}}
    [Documentation]  Verifies CIMC login
    ...  APIC Node ID: {{config['apic_id']}}
    ...  APIC Hostname: {{config['apic_hostname']}}
    ...  CIMC IP: {{ cimc_ip[0] }}
    [Tags]      aci-operations  aci-apic-cimc
    # Login
    connect to device "{{config['apic_hostname']}}_cimc" via "cli"

