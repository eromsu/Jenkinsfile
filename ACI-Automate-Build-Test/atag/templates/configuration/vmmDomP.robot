{#
Verifies VMware VMM domain configuration.

> The association of VLAN pool to the VMM domain are not verified by this template.
#}
{% if 'vmm_type' not in config %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% elif config['vmm_type'] not in ['vmware'] %}
  {% set x=config.__setitem__('vmm_type', 'vmware') %}
{% endif %}
{% if 'vmm_sw_mode' not in config %}
  {% set x=config.__setitem__('vmm_sw_mode', 'default') %}
{% endif %}
{% if 'stp_policy' not in config %}
  {% set x=config.__setitem__('stp_policy', '') %}
{% endif %}
{% if 'lldp_policy' not in config %}
  {% set x=config.__setitem__('lldp_policy', '') %}
{% endif %}
{% if 'cdp_policy' not in config %}
  {% set x=config.__setitem__('cdp_policy', '') %}
{% endif %}
{% if 'lacp_policy' not in config %}
  {% set x=config.__setitem__('lacp_policy', '') %}
{% endif %}
{% if 'l2_policy' not in config %}
  {% set x=config.__setitem__('l2_policy', '') %}
{% endif %}
{% if 'fw_policy' not in config %}
  {% set x=config.__setitem__('fw_policy', '') %}
{% endif %}
{% if config['vmm_type'] == "vmware" %}
Verify ACI VMware VMM Domain Configuration - Domain {{config['name']}}
    [Documentation]   Verifies that ACI VMM Domain '{{config['name']}}' are configured with the expected parameters
    ...  - VMM Domain Name:  {{config['name']}}
	...  - VMM Switch Type:  {{config['vmm_sw_mode']}}
    ...  - vCenter Datacenter: {{config['vcenter_datacenter_name']}}
    ...  - vCenter Controller Name: {{config['vcenter_controller_name']}}
    ...  - vCenter Hostname/IP: {{config['vcenter_hostname_ip']}}
    ...  - vCenter Credential Profile Name: {{config['vcenter_credential_profile']}}
    ...  - vCenter Username: {{config['vcenter_username']}}
    {% if config['stp_policy'] != '' %}
    ...  - STP Interface Policy: {{config['stp_policy']}}
    {% endif %}
    {% if config['lldp_policy'] != '' %}
    ...  - LLDP Interface Policy: {{config['lldp_policy']}}
    {% endif %}
    {% if config['cdp_policy'] != '' %}
    ...  - CDP Interface Policy: {{config['cdp_policy']}}
    {% endif %}
    {% if config['lacp_policy'] != '' %}
    ...  - LACP Interface Policy: {{config['lacp_policy']}}
    {% endif %}
    {% if config['l2_policy'] != '' %}
    ...  - L2 Interface Policy: {{config['l2_policy']}}
    {% endif %}
    {% if config['fw_policy'] != '' %}
    ...  - FW Policy: {{config['fw_policy']}}
    {% endif %}
    [Tags]      aci-conf  aci-vmm  aci-vmm-vmware
	# Retrieve Configuration
	${uri} =  Set Variable  	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
	${return}=  via ACI REST API retrieve "${uri}" from "${apic}" as "object"
    Should Be Equal as Integers     ${return.status}		200		Failure executing API call			values=False
	# Verify Configuration Parameters
	Should Be Equal as Integers     ${return.totalCount}	1		VMM Domain does not exist	values=False
	Should Be Equal as Strings     ${return.payload[0].vmmDomP.attributes.name}   {{config['name']}}        Failure retreiving configuration		values=False
	Run keyword And Continue on Failure  Should Be Equal as Strings     "${return.payload[0].vmmDomP.attributes.mode}"   "{{config['vmm_sw_mode']}}"      vSwitch Mode not matching expected configuration                 values=False
    {% if config['stp_policy'] != '' %}
	# STP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultStpIfPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultStpIfPol.tnStpIfPolName, "{{config['stp_policy']}}")
	${stp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${stp.totalCount}	1		STP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['lldp_policy'] != '' %}
	# LLDP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultLldpIfPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultLldpIfPol.tnLldpIfPolName, "{{config['lldp_policy']}}")
	${lldp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${lldp.totalCount}	1		LLDP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['cdp_policy'] != '' %}
	# CDP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultCdpIfPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultCdpIfPol.tnCdpIfPolName, "{{config['cdp_policy']}}")
	${cdp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${cdp.totalCount}	1		CDP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['lacp_policy'] != '' %}
	# LACP Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultLacpLagPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultLacpLagPol.tnLacpLagPolName, "{{config['lacp_policy']}}")
	${lacp}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${lacp.totalCount}	1		LACP Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['l2_policy'] != '' %}
	# L2 Interface Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultL2InstPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultL2InstPol.tnL2InstPolName, "{{config['l2_policy']}}")
	${l2}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${l2.totalCount}	1		L2 Interface Policy not matching expected configuration	values=False
    {% endif %}
    {% if config['fw_policy'] != '' %}
	# FW Policy Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsDefaultFwPol&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmRsDefaultFwPol.tnNwsFwPolName, "{{config['fw_policy']}}")
	${fw}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${fw.totalCount}	1		FW Policy not matching expected configuration	values=False
    {% endif %}
	# Credential Profile Verification
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmUsrAccP&rsp-subtree-include=required&rsp-subtree-filter=eq(vmmUsrAccP.name, "{{config['vcenter_credential_profile']}}")
	${credential}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${credential.status}		200		Failure executing API call			values=False
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${credential.totalCount}	1		Credential Profile '{{config['vcenter_credential_profile']}}' not associated with VMM Domain	values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${credential.payload[0].vmmDomP.children[0].vmmUsrAccP.attributes.usr}	{{config['vcenter_username']}}	    vCenter Username not matching expected configuration    values=False
	# vCenter Profile
	${uri} =	Set Variable	/api/node/mo/uni/vmmp-VMware/dom-{{config['name']}}/ctrlr-{{config['vcenter_controller_name']}}
    ${filter}=	Set Variable	rsp-subtree=children&rsp-subtree-class=vmmRsAcc
	${vcenter}=  via filtered ACI REST API retrieve "${uri}" using filter "${filter}" from "${apic}" as "object"
    Should Be Equal as Integers     ${vcenter.status}		200		Failure executing API call			values=False
	Run keyword And Continue on Failure     Should Be Equal as Integers     ${vcenter.totalCount}	1		vCenter Profile '{{config['vcenter_controller_name']}}' not associated with VMM Domain	values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.attributes.hostOrIp}		{{config['vcenter_hostname_ip']}}	        vCenter Hostname/IP not matching expected configuration    values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.attributes.rootContName}		{{config['vcenter_datacenter_name']}}	vCenter Datacenter not matching expected configuration    values=False
	Run keyword And Continue on Failure     Should Be Equal as Strings		${vcenter.payload[0].vmmCtrlrP.children[0].vmmRsAcc.attributes.tDn}		uni/vmmp-VMware/dom-{{config['name']}}/usracc-{{config['vcenter_credential_profile']}}	vCenter Credential Profile not matching expected configuration    values=False
{% endif %}

