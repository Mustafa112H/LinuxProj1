#!/bin/bash

declare -A CLI_paths

CLI_paths[0]='{
"
in_octets: 1500000
out_octets: 1400000
in_errors: 10
out_errors: 2
"
}'

CLI_paths[1]='{"
makefile
Copy code
total_memory: 4096000
available_memory: 1000000
}'

CLI_paths[2]='{
 "in_octets": 200000,
 "out_octets": 100000,
 "in_errors": 5
}'

CLI_paths[3]='{
 "cpu_usage": 65,
 "idle_percentage": 35
}'

CLI_paths[4]='{
 "ospf_area": "0.0.0.0",
 "ospf_state": "up"
}'
#####requirments
CLI_paths[5]='{
 "admin_status": "up",
 "oper_status": "up",
 "mac_address": "00:1C:42:2B:60:5A",
 "mtu": 1500,
 "speed": 1000
}'

CLI_paths[6]='{
 "peer_as": 65001,
 "connection_state": "Established",
 "received_prefix_count": 120,
 "sent_prefix_count": 95
}'

CLI_paths[7]='{
"cpu_usage": 75,
 "user_usage": 45,
 "system_usage": 20,
 "idle_percentage": 25
}'

CLI_paths[8]='{
{
 "area_id": "0.0.0.0",
 "active_interfaces": 4,
 "lsdb_entries": 200,
 "adjacencies": [
 {"neighbor_id": "1.1.1.1", "state": "full"},
 {"neighbor_id": "2.2.2.2", "state": "full"}
 ]
}'

CLI_paths[9]='{
{
 "total_space": 1024000,
 "used_space": 500000,
 "available_space": 524000,
 "disk_health": "good"
}
}'
