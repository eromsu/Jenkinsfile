# Installing ATAG

ATAG is a Python2 application requiring a number of python libraries (jinja2,
openpyxl, and a few more). As such, the installation is not necessarily complex,
but it does require some prior knowledge on Linux and python admin.

ATAG is typically run on either a Linux VM or on the local laptop - either Mac
or Windows based. When run locally on the laptop, then using Python virtual
environments **can** be beneficial.

The following installation instructions assumes that the tool is installed
on a Linux VM. In case of installation on the local laptop or elsewhere, the installation
instructions may be slightly different.

The VM must be able to communicate with the outside world.  
For software and tools installation you may need access to Cisco Intranet and the Internet.  
The Linux commands below are for *Ubuntu*, change **apt-get** to **yum** for *CentOS*.

## Step 1: Update OS (optional)

```
sudo apt-get update  
sudo apt-get upgrade  
sudo apt-get install man ssh openssh-client openssh-server openssl wget curl net-tools  
```

## Step 2: Access Linux OS file system via SFTP (or alternative protocol)

You may need to move files between your laptop and VM when using the tool so,
make sure that you can access the Linux file system from your laptop.

Providing access to the Linux file system can be done in multiple ways depending
on your flavor of installation.

Below are some of approaches that can be used:

* File sharing in VMware Fusion
* SFTP/SCP of files between laptop and Linux VM
* FTP of files between laptop and Linux VM

## Step 3: Install Python version 2

**Do NOT install Python3, as ATAG is written for Python 2.7**

```
sudo apt-get install python python-setuptools build-essential python-dev python-wheel  
sudo apt-get install python-pip python-virtualenv python-urllib3 python-yaml python-lxml  
sudo apt-get install python-requests python-openpyxl python-jinja2 python-paramiko  
```

Verify Python version >= 2.7 is installed
`python --version`

## Step 4: Install Git

```
sudo apt-get install git  
```

Verify Git is installed
`git --version`

## Step 5: Download ATAG

&emsp;&emsp;**_put your Cisco username to the command below_**  

```
cd ~  
git clone https://username@wwwin-github.cisco.com/AS-Community/ATAG.git  
```

Verify the python script, example and template files in the ATAG directory  

```
cd ATAG  
ls -al  
```

## Step 6: Install required Python modules

```
cd ~
cd ATAG  
sudo pip install -r requirements.txt
```

## Step 7: Test installation

```
cd ~
cd ATAG  
python generate_aci_tests.py -h 
```

The command above should give an output similar to the one below if the
installation is successful.

```
$ python generate_aci_tests.py -h
usage: generate_aci_tests.py [-h] [-c CONFIG] [-o OUTPUT] [-p PASSWORD] [-f]

This script generates RASTA/CXTA .robot files based on a DAFE compatible Excel
workbook

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
