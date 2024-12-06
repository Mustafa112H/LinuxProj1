#!/bin/bash

#Array will map the gnmi path the the correct cli command that we want so we can call the cli and then compare
declare -A GNMI_CLI_MAPPING

GNMI_CLI_MAPPING["/interfaces/interface[name=eth0]/state/counters"]="show interfaces eth0 counters"
GNMI_CLI_MAPPING["/system/memory/state"]="show memory"
GNMI_CLI_MAPPING["/interfaces/interface[name=eth1]/state/counters"]="show interfaces eth1 counters"
GNMI_CLI_MAPPING["/system/cpu/state/usage"]="show cpu"
GNMI_CLI_MAPPING["/routing/protocols/protocol[ospf]/ospf/state"]="show ospf status"
GNMI_CLI_MAPPING["/interfaces/interface[name=eth0]/state"]="show interfaces eth0 status,show interfaces eth0 mac-address,show interfaces eth0 mtu,show interfaces eth0 speed"
GNMI_CLI_MAPPING["/bgp/neighbors/neighbor[neighbor_address=10.0.0.1]/state"]="show bgp neighbors 10.0.0.1,show bgp neighbors 10.0.0.1 received-routes,show bgp neighbors 10.0.0.1 advertised-routes"
GNMI_CLI_MAPPING["/system/cpu/state"]="show cpu usage,show cpu user,show cpu system,show cpu idle"
GNMI_CLI_MAPPING["/ospf/areas/area[id=0.0.0.0]/state"]="show ospf area 0.0.0.0,show ospf neighbors"
GNMI_CLI_MAPPING["/system/disk/state"]="show disk space,show disk health"

CallCLI() {
#this function is so that i can return the command to the main.
    local gnmi_path=$1
    if [[ -n "${GnmiPathToCLI[$gnmi_path]}" ]]; then
        echo "${GnmiPathToCLI[$gnmi_path]}"
    else
        echo "Error Command not found!"
        return 1
    fi
}



