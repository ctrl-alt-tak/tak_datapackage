#!/bin/bash

if [ "$EUID" -ne 0 ]

then 
    echo "Please run as root"
    echo "use: sudo ./tak_server_connnection_datapackage.sh"

exit

fi