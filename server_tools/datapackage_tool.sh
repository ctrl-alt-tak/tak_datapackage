#!/bin/bash


# datapackage_tool.sh - server connection automation
#
# MIT License
# Copyright (c) 2025 James Crowder
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Check for root
if [ "$EUID" -ne 0 ]; then
 echo "Please run as root"
 echo "👉 try: sudo ./datapackage_tool.sh"
exit 1
fi

if [ -f "../.serverconfig" ]; then
 echo "Server Config Exsists"
else
 touch ../.serverconfig
fi

source ../.serverconfig

# Functions
config() {
 read -p "Enter Server Name: " TAK_SERVER_NAME
 read -p "Enter TAK Server IP Address: " TAK_SERVER_IP
 read -p "Is the server configured on the default port (y/n)? " qport
  if [[ "$qport" != "y" && "$qport" != "Y" ]]; then
   read -p "Enter Server Port: " TAK_SERVER_PORT
  else
   TAK_SERVER_PORT="8089"
  fi
}

# Define some bashrc, and start and end markers.
CONFIG="../.serverconfig"
START="# === TAK Server Environment Variables ==="
END="# === END TAK Server Environment Variables ==="

# Define colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

sleep 3

# Clear terminal and print
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

# Header
echo -e "${YELLOW}"
echo -e "MIT License"
echo -e "Copyright (c) 2025 Jimmie Crowder"
echo -e "${RESET}"

# Show current values if they exsist.
if grep -q "$START" "$CONFIG"; then
  echo "=== Current Server Configuration ==="
  echo "Server Name: $TAK_SERVER_NAME"
  echo "IP Address: $TAK_SERVER_IP"
  echo "Port: $TAK_SERVER_PORT"
  read -p "Would you like to edit this config (y/n)? " qconfig
  if [[ "$qconfig" == "y" || "$qconfig" == "Y" ]]; then
    config
  else
    echo "Moving on..."
  fi
else
  config
fi

# Remove old add new.
if [[ "$qconfig" == "y" || "qconfig" == "Y" ]]; then
  sed -i "/$START/,/$END/d" "$CONFIG"
fi
if [[ -n "$TAK_SERVER_NAME" && -n "$TAK_SERVER_IP" && -n "$TAK_SERVER_PORT" ]]; then
  cat <<EOF >> "$CONFIG"
$START
export TAK_SERVER_NAME="$TAK_SERVER_NAME"
export TAK_SERVER_IP="$TAK_SERVER_IP"
export TAK_SERVER_PORT="$TAK_SERVER_PORT"
$END
EOF
  echo "TAK environment variables set"
else
  echo "Values not set try again"
fi

# Add role
read -p "Add user Role (y/n)? " qrole
if [[ "$qrole" != "n" && "qrole" != "N" ]]; then
echo "Select Role:"
roles=("Team Member" "Team Lead" "HQ" "Sniper" "Medic" "Forward Observer" "RTO" "K9")
select role in "${roles[@]}"; do
  [[ -n "$role" ]] && break
  echo "Invalid selection, try again."
done
fi

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
) 
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
    <entry key="connectString0" class="class java.lang.String">${TAK_IP_ADDRESS}:${port}:ssl</entry>
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

# Zip the package
zip_filename="${callsign}.zip"
(
  zip -r "$zip_filename" cert prefs MANIFEST &>/dev/null
) 
echo -e "${GREEN}Datapackage created: ${zip_filename}${RESET}"

# Optional chown
# uid=1000
# gid=1001
# chown "$uid":"$gid" "$zip_filename"

# Cleanup
echo -e "${YELLOW}Done! UUID: ${uuid_str}${RESET}"

rm -r ./MANIFEST
rm -r ./cert
rm -r ./prefs

read -p "Press Enter to exit."


