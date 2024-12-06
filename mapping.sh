#!/bin/bash

#Array will map the gnmi path the the correct cli command that we want so we can call the cli and then compare
declare -A GnmiPathToCLI

GnmiPathToCLI["/interfaces/interface[name=eth0]/state/counters"]="show interfaces eth0 counters"
GnmiPathToCLI["/system/memory/state"]="show memory"
GnmiPathToCLI["/interfaces/interface[name=eth1]/state/counters"]="show interfaces eth1 counters"
GnmiPathToCLI["/system/cpu/state/usage"]="show cpu"
GnmiPathToCLI["/routing/protocols/protocol[ospf]/ospf/state"]="show ospf status"
GnmiPathToCLI["/interfaces/interface[name=eth0]/state"]="show interfaces eth0 status,show interfaces eth0 mac-address,show interfaces eth0 mtu,show interfaces eth0 speed"
GnmiPathToCLI["/bgp/neighbors/neighbor[neighbor_address=10.0.0.1]/state"]="show bgp neighbors 10.0.0.1,show bgp neighbors 10.0.0.1 received-routes,show bgp neighbors 10.0.0.1 advertised-routes"
GnmiPathToCLI["/system/cpu/state"]="show cpu usage,show cpu user,show cpu system,show cpu idle"
GnmiPathToCLI["/ospf/areas/area[id=0.0.0.0]/state"]="show ospf area 0.0.0.0,show ospf neighbors"
GnmiPathToCLI["/system/disk/state"]="show disk space,show disk health"

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



