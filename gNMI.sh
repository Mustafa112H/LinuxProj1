#!/bin/bash

declare -A gNMI_paths

gNMI_paths[/interfaces/interface[name=eth0]/state/counters]='{
 "in_octets": 1500000,
 "out_octets": 1400000,
 "in_errors": 10,
 "out_errors": 2
}'

gNMI_paths[/system/memory/state]='{
"total_memory": 4096000,
 "available_memory": 1024000
}'

gNMI_paths[/interfaces/interface[name=eth1]/state/counters]='{
 "in_octets": 200000,
 "out_octets": 100000,
 "in_errors": 5
}'

gNMI_paths[/system/cpu/state/usage]='{
 "cpu_usage": 65,
 "idle_percentage": 35
}'

gNMI_paths[/routing/protocols/protocol[ospf]/ospf/state]='{
 "ospf_area": "0.0.0.0",
 "ospf_state": "up"
}'
#####requirments
gNMI_paths[/interfaces/interface[name=eth0]/state]='{
 "admin_status": "up",
 "oper_status": "up",
 "mac_address": "00:1C:42:2B:60:5A",
 "mtu": 1500,
 "speed": 1000
}'

gNMI_paths[/bgp/neighbors/neighbor[neighbor_address=10.0.0.1]/state]='{
 "peer_as": 65001,
 "connection_state": "Established",
 "received_prefix_count": 120,
 "sent_prefix_count": 95
}'

gNMI_paths[/system/cpu/state]='{
"cpu_usage": 75,
 "user_usage": 45,
 "system_usage": 20,
 "idle_percentage": 25
}'

gNMI_paths[/ospf/areas/area[id=0.0.0.0]/state]='{
 "area_id": "0.0.0.0",
 "active_interfaces": 4,
 "lsdb_entries": 200,
 "adjacencies": [
 {"neighbor_id": "1.1.1.1", "state": "full"},
 {"neighbor_id": "2.2.2.2", "state": "full"}
 ]
}'

gNMI_paths[/system/disk/state]='{
 "total_space": 1024000,
 "used_space": 500000,
 "available_space": 524000,
 "disk_health": "good"
}'

gNMI_paths[/interfaces/interface[name=eth0]/state/oper-status]='{
LINK_UP
}'

gNMI_paths[/interfaces/interface[name=eth0]/state/admin-status]='{
ACTIVE
}'

gNMI_paths[/interfaces/interface[name=eth0]/state/speed]='{
400
}'

gNMI_paths[/system/memory/state/used]='{
361296 bytes
}'

gNMI_paths[/system/cpu/state/utilization]='{
31
}'

gNMI_paths[/system/storage/state/used]='{
43
}'
gNMI_paths[/testing]='{
"in":5
"out":10
"status":available
"next": gnmi
"not": hey 
"Third": ._.
}'
gNMI_paths[/system/storage/state/used]='{
43
}'
gNMI_paths[/test1]='{
"first": 43
"second": 75
"third": HEY
}'

##to return the output to the main 
CallGNMI(){
    gnmi_path=$1
    if [[ -n "${gNMI_paths[$gnmi_path]}" ]]; then
        echo "${gNMI_paths[$gnmi_path]}"
        return 0
    else
        return 1
    fi
}
