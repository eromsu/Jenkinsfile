# Supported test cases

The list of supported test cases is constant changing. The table below will give an indication of the overall areas that are supported by each of the three categories of test cases.

ACI Area/Topic         | Configuration | Faults | Operational State | Template Name
--------------         | ------------- | ------ | ----------------- | -------------
Node Provisioning (APIC) | Yes         | No     | No                | node_provisioning_apic.robot
Node Provisioning (Switch) | Yes       | No     | No                | node_provisioning_node.robot
Infra VLAN (APIC)      | Yes           | No     | No                | infra_vlan_apic.robot
Infra VLAN (Switch)    | Yes           | No     | No                | infra_vlan_node.robot
TEP Pool Config        | Yes           | No     | No                | tep_pool_setup.robot
VLAN Pool              | Yes           | Yes    | No                | fvnsVlanInstP.robot
VLAN Pool Encap Block  | Yes           | No     | No                | fvnsEncapBlk.robot
Domain                 | Yes           | Yes    | No                | anyDomP.robot
VMM Domain (VMware)    | Yes           | Yes    | No                | vmmDomP.robot
AAEP                   | Yes           | Yes    | No                | infraAttEntityP.robot
AAEP Domain Assoc.     | Yes           | No     | No                | infraAttEntityPRsDomP.robot
vPC Domain             | Yes           | Yes    | No                | vpcDom.robot
Fabric BGP Route Reflector         | Yes           | Yes    | Yes               | bgpInstP.robot
DNS Profile            | Yes       | No         | No                | dnsProfile.robot
DNS Provider           | Yes       | No         | No                | dnsProv.robot
Datetime Profile       | Yes       | Yes        | No                | datetimePol.robot
Datetime NTP Provider  | Yes       | Yes        | No                | datetimeNtpProv.robot
Datetime NTP Sync Status | No      | No         | Yes               | datetime_ntp_status.robot
Interface Policies - CDP           | Yes           | No     | No                | cdpIfPol.robot
Interface Policies - L2            | Yes           | No     | No                | l2IfPol.robot
Interface Policies - Link Level    | Yes           | No     | No                | fabricHIfPol.robot
Interface Policies - LLDP          | Yes           | No     | No                | lldpIfPol.robot
Interface Policies - MCP           | Yes           | No     | No                | mcpIfPol.robot
Interface Policies - Port Channel  | Yes           | No     | No                | lacpLagPol.robot
Interface Policies - STP           | Yes           | No     | No                | stpIfPol.robot
Interface Policies - Storm Control | Yes           | No     | No                | stormctrlIfPol.robot
Interface Policy Group | Yes           | Yes    | No                | infraAccBndlGrp.robot
Interface Profile      | Yes           | Yes    | No                | infraAccPortP.robot
Interface Selector     | Yes           | No     | No                | infraHPortS.robot
Switch Profile         | Yes           | Yes    | No                | infraNodeP.robot
Interface Profile to Switch Profile Assoc. | Yes | No | No | infraRSxxPortP.robot
Tenant                 | Yes           | No     | No                | fvTenant.robot
VRF                    | Yes           | Yes    | No                | fvCtx.robot
BD                     | Yes           | Yes    | No                | fvBD.robot
BD Subnet              | Yes           | No     | No                | fvSubnet.robot
BD to L3out Assoc.     | Yes           | No     | No                | fvRsBDToOut.robot
BGP Peer (node)        | Yes           | Yes    | Yes               | bgpPeerP.robot
BGP Route Target       | Yes           | No     | No                | bgpRtTargetP.robot
Application Prof       | Yes           | No     | No                | fvAP.robot
EPG                    | Yes           | Yes    | No                | fvAEPg.robot
EPG Domain Assoc.      | Yes           | No     | No                | fvRsDomAtt.robot
EPG Contract           | Yes           | No     | No                | fvAEPgCtr.robot
EPG Static Port        | Yes           | No     | No                | fvAEPg_static_binding.robot
L3Out                  | Yes           | Yes    | No                | l3extOut.robot
L3Out Node Profile     | Yes           | No     | No                | l3extNodeProf.robot
L3Out Interface Profile | Yes          | No     | No                | l3extNodeIntProf.robot
L3Out Ext. EPG         | Yes           | Yes    | No                | instP.robot
L3Out Ext. EPG Subnet  | Yes           | No     | No                | l3extSubnet.robot
Contract               | Yes           | Yes    | No                | vzBrCp.robot
Contract Subject       | Yes           | No     | No                | vzSubj.robot
Contract Filter        | Yes           | Yes    | No                | vzFilter.robot
Contract Filter Entry  | Yes           | Yes    | No                | vzEntry.robot
APIC Login             | No            | No     | Yes               | login.robot
APIC Login (CIMC)      | No            | No     | Yes               | login_cimc.robot
Software Version (APIC)        | No            | No     | Yes               | software_version_apic.robot
Software Version (Switch)      | No            | No     | Yes               | software_version_node.robot
Hardware State (APIC)  | No            | No     | Yes               | hardware_state_cimc.robot
Connecivity (fabric)   | No            | No     | Yes               | connectivity_fabric.robot
Connecivity (APIC)     | No            | No     | Yes               | connectivity_apic.robot
Connecivity (hosts)    | No            | No     | Yes               | connectivity_host.robot
Presence of External Route | No        | No     | Yes               | route_presence_ipv4.robot
Interface Counters (errors) | No       | No     | Yes               | interface_counters.robot

For more in-dept information, please reference the documentation available for each test case template within the three categories.

* [Configuration verification](Templates-configuration.md)
* [Fault verification](Templates-faults.md)
* [Operational State verification](Templates-operational_state.md)