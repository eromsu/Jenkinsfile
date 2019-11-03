*** Settings ***
Library  RASTA
Resource  rasta.robot
Library  XML
Library  String
Library  Collections
Suite Setup   setup-test
Force Tags  aci

*** Variables ***
${testbed}  aci_tests_testbed.yaml
${apic}     APIC-01

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