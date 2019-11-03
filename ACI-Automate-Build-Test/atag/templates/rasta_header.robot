*** Settings ***
Library  RASTA
Resource  rasta.robot
Library  XML
Library  String
Library  Collections
Suite Setup   setup-test
Force Tags  aci

*** Variables ***
${testbed}  {{testbed_file}}
${apic}     {{dafe_data.apic_controller[0].apic_hostname}}

*** Keywords ***
setup-test
    use testbed "${testbed}"

Logout via url "${logout_url}" and close browser
   visit "${logout_url}"
   close browser

Logout CIMC and close browser
    select the main window
    click on the object with xpath ".//div[contains(@class,'settingIcon')]"
    wait until object is visible via xpath ".//td[@id='logout_text']"
    click on the object with xpath ".//td[@id='logout_text']"
    wait until object is present via xpath ".//span[@id='LP_LoginButton']"
    close browser

Get ACI uribv4 Prefix Match Count
    [Arguments]   ${urib}  ${prefix}
    ${match_count} =  Set Variable  0
    : FOR  ${route}  IN  @{urib}
    \  log  ${route}
    \  log  ${route.uribv4Route.attributes}
    \  ${count} =  Get Match Count  ${route.uribv4Route.attributes}  ${prefix}
    \  ${match_count} =  Evaluate  ${match_count} + ${count}
    log  ${match_count}
    [Return]  ${match_count}

Check ACI Controller NTP Status
    [Arguments]     ${ntpq}
    ${ntp_sync} =  Set Variable  "not_synchronized"
    ${ntp_peers} =      Create List
    : FOR  ${peer}  IN  @{ntpq}
    \  log  ${peer}
    \  Append To List  ${ntp_peers}  ${peer.datetimeNtpq.attributes.remote}
    \  ${tally} =  Run Keyword And Return Status  Should be equal as strings  ${peer.datetimeNtpq.attributes.tally}  *
    \  ${ntp_sync} =  Set Variable If  ${tally}  "synced_remote_server"
    \  ${ntp_server} =  Set Variable If  ${tally}  ${peer.datetimeNtpq.attributes.remote}
    \  ${ntp_statum} =  Set Variable If  ${tally}  ${peer.datetimeNtpq.attributes.stratum}
    ${ntp_sync_status} =  Run Keyword And Return Status    Should Be Equal as Strings  ${ntp_sync}  "synced_remote_server"
    ${ntp_statum} =  Set Variable If  "${ntp_sync_status} == False"  ${ntpq[0].datetimeNtpq.attributes.stratum}
    [Return]  ${ntp_sync}  ${ntp_server}  ${ntp_statum}  ${ntp_peers} 

Get ACI Switch NTP peers
    [Arguments]     ${peer_list}
    ${ntp_peers} =      Create List
    : FOR  ${peer}  IN  @{peer_list}
    \  Append to List  ${ntp_peers}  ${peer.datetimeNtpProvider.attributes.name}
    [Return]  ${ntp_peers}

*** Test Cases ***
