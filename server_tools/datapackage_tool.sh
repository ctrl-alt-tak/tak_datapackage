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
 touch ./.serverconfig
fi

source ./.serverconfig

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

sendToserver() {
  curl -vvvL  
}

#Functions for cert creation
makeCertnonFips() {
  /opt/tak/certs/makeCert.sh client $CLIENT
}

makeCert () {
  ./makeCert client $CLIENT --fips 
}


# Define some stuff, and start and end markers for server config.
CONFIG="./.serverconfig"
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
echo -e "Copyright (c) 2025 James Crowder"
echo -e "${RESET}"

# Show current values if they exsist.
if grep -q "$START" "$CONFIG"; then
  echo "=== Current Server Configuration ==="
  echo "Server Name: $TAK_SERVER_NAME"
  echo "IP Address: $TAK_SERVER_IP"
  echo "Port: $TAK_SERVER_PORT"
  echo "Admin Cert: $ADMIN"
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
if grep -q "$START" "$CONFIG"; then
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
read -p "Add user Role (y/n)? " QROLE
if [[ "$QROLE" != "n" && "$QROLE" != "N" ]]; then
echo "Select Role:"
ROLES=("Team Member" "Team Lead" "HQ" "Sniper" "Medic" "Forward Observer" "RTO" "K9")
select ROLE in "${ROLES[@]}"; do
  [[ -n "$ROLE" ]] && break
  echo "Invalid selection, try again."
done
fi

read -p "Enter Callsign: " callsign
read -p "Are you using the default cert pass "atakatak" (y/n)? " QPASS
if [[ "$QPASS" != "y" && "$QPASS" != "Y" ]]; then
read -s -p "Enter Cert Password: " CERT_PASS
else
CERT_PASS="atakatak"
fi
ls /opt/tak/certs/files/
read -p "Enter Client Cert (.p12): " CLIENTCERT
read -p "Enter CA Cert (.p12): " CACERT
#Set path
CLIENT_CERT="/opt/tak/certs/files/${CLIENTCERT}"
CA_CERT="/opt/tak/certs/files/${CACERT}"

# Validate cert file paths
if [[ ! -f "$CLIENT_CERT" || ! -f "$CA_CERT" ]]; then
  echo -e "${RED}Error: One or both certificate files not found!${RESET}"
  exit 1
fi

# Generate UUID
uuid_str=$(uuidgen)

# Create directories
mkdir -p cert prefs MANIFEST

(
  cp "$CLIENT_CERT" "cert/$(basename "$CLIENT_CERT")"
  cp "$CA_CERT" "cert/$(basename "$CA_CERT")"
) 
echo -e "${GREEN}Certificates copied.${RESET}"

# Generate .pref file
PREF_FILE="prefs/${TAK_SERVER_NAME}.pref"
cat <<EOF > "$PREF_FILE"
<?xml version='1.0' standalone='yes'?>
<preferences>
<preference version="1" name="cot_streams">
    <entry key="count" class="class java.lang.Integer">1</entry>
    <entry key="description0" class="class java.lang.String">${TAK_SERVER_NAME}</entry>
    <entry key="enabled0" class="class java.lang.Boolean">true</entry>
    <entry key="connectString0" class="class java.lang.String">${TAK_IP_ADDRESS}:${port}:ssl</entry>
    <entry key="caLocation0" class="class java.lang.String">/sdcard/atak/cert/$(basename "$CA_CERT")</entry>
    <entry key="caPassword0" class="class java.lang.String">${CERT_PASS}</entry>
    <entry key="clientPassword0" class="class java.lang.String">${CERT_PASS}</entry>
    <entry key="certificateLocation0" class="class java.lang.String">/sdcard/atak/cert/$(basename "$CLIENT_CERT")</entry>
    <entry key="useAuth0" class="class java.lang.Boolean">true</entry>
    <entry key="cacheCreds0" class="class java.lang.String">Cache credentials</entry>
</preference>
<preference version="1" name="com.atakmap.app_preferences">
    <entry key="displayServerConnectionWidget" class="class java.lang.Boolean">true</entry>
    <entry key="locationCallsign" class="class java.lang.String">${callsign}</entry>
    <entry key="atakRoleType" class="class java.lang.String">${role}</entry>
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
    <Content ignore="false" zipEntry="prefs/${TAK_SERVER_NAME}.pref"/>
    <Content ignore="false" zipEntry="cert/$(basename "$CA_CERT")"/>
    <Content ignore="false" zipEntry="cert/$(basename "$CLIENT_CERT")"/>
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
echo -e "${YELLOW}Done! ${callsign}${RESET}"

rm -r ./MANIFEST
rm -r ./cert
rm -r ./prefs

#Push datatpackage to server
read -p "Enter web admin cert name: " QWEBADMIN
ADMIN="/opt/tak/certs/files/${QWEBADMIN}.p12"

TRUSTSTORE_JKS=$(grep 'truststoreFile=' "/opt/tak/CoreConfig.xml" | sed -n 's/.*truststoreFile="\([^"]*\)".*/\1/p')
TRUSTSTORE="${TRUSTSTORE_JKS%.jks%/certs/files/}.pem"


TRUSTSTORE_PASS=$(grep 'truststorePass=' "/opt/tak/CoreConfig.xml" | sed -n 's/.*truststorePass="\([^"]*\)".*/\1/p')

#read -p "
curl -vvvL -X POST -H "Content-Type: application/x-zip-compressed" --data-binary "@${zip_filename}" --cert $ADMIN:$CERT_PASS --cert-type P12  --cacert $TRUSTSTORE "https://localhost:8443/Marti/sync/upload?name=${zip_filename}&keywords=missionpackage&creatorUid=webadmin"





