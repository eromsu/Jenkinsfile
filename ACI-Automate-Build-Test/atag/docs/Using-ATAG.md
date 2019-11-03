# Using ATAG

Using the ATAG tool is a three step process:

1. Take the DAFE `aci_build_input_data.xlsx` spreadsheet and fill it in with
with the desired configuration if you do not already have one. You may need to
download it from your VM to your laptop file system.
2. Edit the ATAG configuration file `atag_config.yaml` in order to specify the
filename of the DAFE spreadsheet, change the device username RASTA/CXTA should
use to access the devices, enable the desired test cases, etc.
3. Generate RASTA/CXTA tests by executing the ATAG tool using the following
command.

```
$ python generate_aci_tests.py
```

When executing the tool without any optional parameters is it assumed that the
ATAG configuration file is named `atag_config.yaml` and that the device password
is specified in the configuration file. Similarly, will the generated tests by
default be written to two files named `aci_tests.robot` and
`aci_tests_testbed.yaml`.

The name of the ATAG configuration file, output filenames, and device password
be specified using command line arguments. The list of available arguments
can be seen with the following command:

```
$ python generate_aci_tests.py -h
usage: generate_aci_tests.py [-h] [-c CONFIG] [-o OUTPUT] [-p PASSWORD] [-f]

This script generates RASTA/CXTA .robot files based on a DAFE compatible Excel
spreadsheet

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        ATAG config file
  -o OUTPUT, --output OUTPUT
                        Output RASTA/CXTA test script file name
  -p PASSWORD, --password PASSWORD
                        password for APIC UI and device CLI access
  -f, --force
```

# Specifying which test cases that are generated

Which tests that are generated using ATAG are controlled by the `atag_config.yaml` configuration file, which consists of three distinct sections.

The `testcase_config` section, which specifies "global" parameters for the script like location of the DAFE excel sheet, default test types that should be generated, etc.

The `tests_to_generate` section, which provides control on a per test category basis on whether these tests gets generated or not. To enable a test category the attribute `test_enabled` must be set to "yes".
Optionally the test types can be controlled using the `test_type` attribute. Test types without a template defined are automatically skipped by the script. Additional variables can, optionally, be specified using the `<test_type>_variables` attribute. This is most commonly used for overwriting passing criterial for fault verification tests using a configuration like the one below.
```
- category: 'vrf'
  test_enabled: 'yes'
  faults_variables:
    critical: 1
    major: 2
    minor: 3
```

The `testcase_templates` section, which are used to link test category, description, and input sheet (DAFE Excel) together. This section will typically not require modification by the average user.
