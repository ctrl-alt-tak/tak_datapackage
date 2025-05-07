#!/bin/bash

if [ "$EUID" -ne 0 ]

then 
    echo "Please run as root"
    echo "use: sudo ./datapackage_tool.sh"

exit

fi


#Define colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

#Clear terminal and print header
clear
echo -e "${GREEN}"
echo -e "                                  @@                                  "
echo -e "                                @@@@@@                                "
echo -e "                             @@@@@..@@@@@                             "
echo -e "                           @@@@*......-@@@@                           "
echo -e "                        @@@@@............@@@@@                        "
echo -e "                     @@@@@:.................@@@@@                     "
echo -e "                 @@@@@@-......................:@@@@@@                 "
echo -e "           @@@@@@@@@..............................@@@@@@@@@           "
echo -e "         @@@@@@........................................%@@@@@         "
echo -e "         @@.......@@..............................@@.......@@         "
echo -e "         @@.........@@@@:........@@@@.........@@@@.........@@         "
echo -e "         @@@..........@@@@@@@@@=-@@@@.:@@@@@@@@@..........%@@         "
echo -e "         @@@.........@@@@.@@@@@@@@@@@@@@@@@@.@@@@.........@@@         "
echo -e "         @@@...........@@@@@@@@@@@@@@@@@@@@@@@@...........@@@         "
echo -e "          @@@..................@=::::=@..................@@@          "
echo -e "          *@@...................@:@@-@...................@@@          "
echo -e "           @@............................................@@           "
echo -e "         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         "
echo -e "        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        "
echo -e "       .@@@@@@@@@@         @@@@@     @@@@@    @@   @@@@@@@@@@@#       "
echo -e "       @@@@@@@@@@@         @@@@       @@@@    @   @@@@@@@@@@@@@       "
echo -e "      %@@@@@@@@@@@@@@    @@@@@@   @   @@@@        @@@@@@@@@@@@@@      "
echo -e "      @@@@@@@@@@@@@@@    @@@@@@   @   @@@@       #@@@@@@@@@@@@@@      "
echo -e "     @@@@@@@@@@@@@@@@    @@@@@         @@@        @@@@@@@@@@@@@@@     "
echo -e "     @@@@@@@@@@@@@@@@    @@@@@    @    @@@    @    @@@@@@@@@@@@@@     "
echo -e "    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    "
echo -e "    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    "
echo -e "   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   "
echo -e "                     @@@@....................@@@@                     "
echo -e "                       @@@..................@@@                       "
echo -e "                        .@@@..............@@@=                        "
echo -e "                          @@@@+........:@@@@                          "
echo -e "                            @@@@@....@@@@@                            "
echo -e "                               @@@@@@@@                               "
echo -e "                                 @@@@                                 "
echo -e "${RESET}"

echo -e "${YELLOW}"
echo -e "Created by: Jimmie Crowder"
echo -e "Email: jcrowder@kranzetech.com"
echo -e "Email for any questions or improvements"
echo -e "${RESET}"

#Get user inputs
read -p "Enter Server Name: " server_name
read -p "Enter TAK Server IP Address: " ip_address
read -p "Enter Server Port: " port

# Role selection menu
echo "Select Role:"
roles=("Team Member" "Team Lead" "HQ" "Sniper" "Medic" "Forward Observer" "RTO" "K9")
select role in "${roles[@]}"; do
  [[ -n "$role" ]] && break
  echo "Invalid selection, try again."
done

read -p "Enter Callsign: " callsign
read -s -p "Enter Cert Password: " cert_pass
echo ""
read -p "Enter Client Cert Path (.p12): " client_cert
read -p "Enter CA Cert Path (.p12): " ca_cert

# Validate cert file paths
if [[ ! -f "$client_cert" || ! -f "$ca_cert" ]]; then
  echo -e "${RED}Error: One or both certificate files not found!${RESET}"
  exit 1
fi

# Generate UUID
uuid_str=$(uuidgen)

# Create directories
mkdir -p cert prefs MANIFEST

# Copy cert files (with spinner)
(
  cp "$client_cert" "cert/$(basename "$client_cert")"
  cp "$ca_cert" "cert/$(basename "$ca_cert")"
) & spinner $!
echo -e "${GREEN}Certificates copied.${RESET}"

# Generate .pref file
pref_file="prefs/${server_name}.pref"
cat <<EOF > "$pref_file"
<?xml version='1.0' standalone='yes'?>
<preferences>
<preference version="1" name="cot_streams">
    <entry key="count" class="class java.lang.Integer">1</entry>
    <entry key="description0" class="class java.lang.String">${server_name}</entry>
    <entry key="enabled0" class="class java.lang.Boolean">true</entry>
    <entry key="connectString0" class="class java.lang.String">${ip_address}:${port}:ssl</entry>
    <entry key="caLocation0" class="class java.lang.String">/sdcard/atak/cert/$(basename "$ca_cert")</entry>
    <entry key="caPassword0" class="class java.lang.String">${cert_pass}</entry>
    <entry key="clientPassword0" class="class java.lang.String">${cert_pass}</entry>
    <entry key="certificateLocation0" class="class java.lang.String">/sdcard/atak/cert/$(basename "$client_cert")</entry>
    <entry key="useAuth0" class="class java.lang.Boolean">true</entry>
    <entry key="cacheCreds0" class="class java.lang.String">Cache credentials</entry>
    <entry key="locationCallsign" class="class java.lang.String">${callsign}</entry>
</preference>
</preferences>
EOF

# Generate MANIFEST.xml
manifest_file="MANIFEST/MANIFEST.xml"
cat <<EOF > "$manifest_file"
<MissionPackageManifest version="2">
  <Configuration>
    <Parameter name="uid" value="${uuid_str}"/>
    <Parameter name="name" value="${callsign}"/>
    <Parameter name="name" value="${server_name}.zip"/>
    <Parameter name="onReceiveDelete" value="true"/>
  </Configuration>
  <Contents>
    <Content ignore="false" zipEntry="prefs/${server_name}.pref"/>
    <Content ignore="false" zipEntry="cert/$(basename "$ca_cert")"/>
    <Content ignore="false" zipEntry="cert/$(basename "$client_cert")"/>
  </Contents>
</MissionPackageManifest>
EOF

# Zip the package (with spinner)
zip_filename="${callsign}.zip"
(
  zip -r "$zip_filename" cert prefs MANIFEST &>/dev/null
) & spinner $!
echo -e "${GREEN}Datapackage created: ${zip_filename}${RESET}"

# Optional chown (currently commented out)
# uid=1000
# gid=1001
# chown "$uid":"$gid" "$zip_filename"

# Cleanup message
echo -e "${YELLOW}Done! UUID: ${uuid_str}${RESET}"
read -p "Press Enter to exit."


