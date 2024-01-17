# JMeter_master-slave_Azure

Project in order to test a website (latency, thorughput, etc.) from different VMs on different parts of the world. Requires to have Azure-cli and an account with ZeroTier VPN.

Technologies used:
- JMeter
- Terraform
- Azure
- ZeroTier VPN
- Ansible

## Start

```bash
chmod +x run.sh
./run.sh
```

> Note: there is a 10s window (indicated on the terminal) that is given for you to approve on the ZeroTier VPN's website the VMs

## Description

1. Terraform creates different VMs on different parts of the world using the Azure provider
2. Ansible configures all of the dependencies and installs the required components
3. All of the slave VMs connect to the master using ZeroTier VPN
4. The JMeter test file is run with the master/slave configuration



## Add/modify regions

On the file `main.tf`, it is necessary to modify the list with the desired regions to test on:
```terraform
# Define the Azure regions
variable "regions" {
  type    = list(string)
  default = ["brazilsouth", "northeurope", "southeastasia", "westus"]
}
```

> Note: use the same name convention on the available Azure regions
