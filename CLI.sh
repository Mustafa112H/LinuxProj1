#!/bin/bash

declare -A CLI_paths

CLI_paths["show interfaces eth0 counters"]='in_octets: 1500000
out_octets: 1400000
in_errors: 10
out_errors: 2
'

CLI_paths["show memory"]='total_memory: 4096000
available_memory: 1000000
'

CLI_paths["show interfaces eth1 counters"]='in_octets: 200000
out_octets: 100000
'

CLI_paths["show cpu"]='cpu_usage: 65
'

CLI_paths["show ospf status"]='ospf_area: "0.0.0.0"
ospf_state: "down"
'
#####requirments

##
CLI_paths["show interfaces eth0 status"]='admin_status: up
oper_status: up
'
CLI_paths["show interfaces eth0 mac-address"]='mac_address: 00:1C:42:2B:60:5A
'
CLI_paths["show interfaces eth0 mtu"]='mtu: 1500
'
CLI_paths["show interfaces eth0 speed"]='speed: 1000
'
##


##
CLI_paths["show bgp neighbors 10.0.0.1"]='peer_as: 65001
connection_state: Established
'

CLI_paths["show bgp neighbors 10.0.0.1 received-routes"]='received_prefix_count: 120
'

CLI_paths["show bgp neighbors 10.0.0.1 advertised-routes"]='sent_prefix_count: 95
'
##

##
CLI_paths["show cpu usage"]='cpu_usage: 75
'

CLI_paths["show cpu user"]='user_usage: 45
'

CLI_paths["show cpu system"]='system_usage: 20
'

CLI_paths["show cpu idle"]='idle_percentage: 25
'
##
##
CLI_paths["show ospf area 0.0.0.0"]='area_id: 0.0.0.0
active_interfaces: 4
lsdb_entries: 200
'

CLI_paths["show ospf neighbors"]='neighbor_id: 1.1.1.1, state: full
neighbor_id: 2.2.2.2, state: full
'
##
##

CLI_paths["show disk space"]='total_space: 1024000
used_space: 500000
available_space: 524000
'

CLI_paths["show disk health"]='disk_health: good
'


CallCLI() {
#this function is so that i can return the command to the main.
    path=$1
    if [[ -n "${CLI_paths[$path]}" ]]; then
        echo "${CLI_paths[$path]}"
    else
        echo "Error Command not found!"
        return 1
    fi
}
