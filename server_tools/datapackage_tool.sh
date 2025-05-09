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

if [ -f "./.serverconfig" ]; then
 echo "Server Config Exsists"
else
 touch ./.serverconfig
fi

source ./.serverconfig

# Functions
config() {
 read -p "Enter Server Name: " TAK_SERVER_NAME
 read -p "Enter TAK Server IP Address: " TAK_SERVER_IP
 read -p "Is the server configured on the default port (y/n)? " QPORT
  if [[ "$QPORT" != "y" && "$QPORT" != "Y" ]]; then
   read -p "Enter Server Port: " TAK_SERVER_PORT
  else
   TAK_SERVER_PORT="8089"
  fi
 TRUSTSTORE_JKS=$(grep 'truststoreFile=' "/opt/tak/CoreConfig.xml" | grep -v 'fed-truststore' | sed -n 's/.*truststoreFile="\([^"]*\)".*/\1/p')
 TRUSTSTORE_BN=$(basename "/opt/tak/${TRUSTSTORE_JKS}")
 TRUSTSTORE_PEM="${TRUSTSTORE_BN%.jks}.pem"
 CA_CERT_PATH="/opt/tak/certs/files/${TRUSTSTORE_BN%.jks}.p12"
 CACERT="${TRUSTSTORE_BN%.jks}.p12"
 echo "Available admin certs:"
 mapfile -t P12_CERTS_ADMIN < <(find /opt/tak/certs/files/ -maxdepth 1 -type f -name "*admin*.p12" -exec basename {} \; | sort)

 if [ "${#P12_CERTS_ADMIN[@]}" -eq 0 ]; then
  echo "No admin certs found."
 fi

 select QWEBADMIN in "${P12_CERTS[@]}"; do
  if [[ -n "$QWEBADMIN" ]]; then
    ADMIN="/opt/tak/certs/files/${QWEBADMIN}"
    echo "Selected $QWEBADMIN as admin cert"
    break
  else
    echo "Invalid selection. Try again."
  fi
 done
}

makeCertnonFips() {
  /opt/tak/certs/makeCert.sh client $CLIENT
}

makeCert () {
  ./makeCert client $CLIENT --fips 
}

writeconfig () {
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
export CACERT="$CACERT"
export ADMIN="$ADMIN"
export CA_CERT_PATH="$CA_CERT_PATH"
$END
EOF
  echo "TAK environment variables set"
else
  echo "Values not set try again"
fi
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
  echo "CA Cert: $CACERT"
  echo "CA Cert Path: $CA_CERT_PATH"
  echo "Admin Cert: $ADMIN"
  read -p "Would you like to edit this config (y/n)? " QCONFIG
  if [[ "$QCONFIG" == "y" || "$QCONFIG" == "Y" ]]; then
    config
  else
    echo "Moving on..."
  fi
else
  config
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

read -p "Enter Callsign: " CALLSIGN
read -p "Are you using the default cert pass ${YELLOW}atakatak${RESET} (y/n)? " QPASS
if [[ "$QPASS" != "y" && "$QPASS" != "Y" ]]; then
read -s -p "Enter Cert Password: " CERT_PASS
else
CERT_PASS="atakatak"
fi

 echo "Available client certs:"
 mapfile -t P12_CERTS < <(find /opt/tak/certs/files/ -maxdepth 1 -type f -name "*.p12" -exec basename {} \; | sort)

 if [ "${#P12_CERTS[@]}" -eq 0 ]; then
  echo "No certs found."
 fi

 select QCLIENT in "${P12_CERTS[@]}"; do
  if [[ -n "$QCLIENT" ]]; then
    CLIENT_CERT_PATH="/opt/tak/certs/files/${QCLIENT}"
    echo "Selected $QCLIENT as admin cert"
    break
  else
    echo "Invalid selection. Try again."
  fi
 done

writeconfig

echo "Client: ${CLIENT_CERT_PATH}"
echo "CA: ${CA_CERT_PATH}"
read -p "Press enter to continue: "

# Validate cert file paths
if [[ ! -f "$CLIENT_CERT_PATH" || ! -f "$CA_CERT_PATH" ]]; then
  echo -e "${RED}Error: One or both certificate files not found!${RESET}"
  exit 1
fi

# Generate UUID
UUID=$(uuidgen)

# Create directories
mkdir -p cert prefs MANIFEST

(
  cp "$CLIENT_CERT_PATH" "cert/$(basename "$CLIENT_CERT_PATH")"
  cp "$CA_CERT_PATH" "cert/$(basename "$CA_CERT_PATH")"
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
    <entry key="connectString0" class="class java.lang.String">${TAK_SERVER_IP}:${TAK_SERVER_PORT}:ssl</entry>
    <entry key="caLocation0" class="class java.lang.String">/sdcard/atak/cert/$(basename "$CA_CERT_PATH")</entry>
    <entry key="caPassword0" class="class java.lang.String">${CERT_PASS}</entry>
    <entry key="clientPassword0" class="class java.lang.String">${CERT_PASS}</entry>
    <entry key="certificateLocation0" class="class java.lang.String">/sdcard/atak/cert/$(basename "$CLIENT_CERT_PATH")</entry>
    <entry key="useAuth0" class="class java.lang.Boolean">true</entry>
    <entry key="cacheCreds0" class="class java.lang.String">Cache credentials</entry>
</preference>
<preference version="1" name="com.atakmap.app_preferences">
    <entry key="displayServerConnectionWidget" class="class java.lang.Boolean">true</entry>
    <entry key="locationCallsign" class="class java.lang.String">${CALLSIGN}</entry>
    <entry key="atakRoleType" class="class java.lang.String">${ROLE}</entry>
</preference>
</preferences>
EOF

# Generate MANIFEST.xml
MANIFEST_FILE="MANIFEST/MANIFEST.xml"
cat <<EOF > "$MANIFEST_FILE"
<MissionPackageManifest version="2">
  <Configuration>
    <Parameter name="uid" value="${UUID}"/>
    <Parameter name="name" value="${CALLSIGN}"/>
    <Parameter name="name" value="${TAK_SERVER_NAME}.zip"/>
    <Parameter name="onReceiveDelete" value="true"/>
  </Configuration>
  <Contents>
    <Content ignore="false" zipEntry="prefs/${TAK_SERVER_NAME}.pref"/>
    <Content ignore="false" zipEntry="cert/$(basename "$CA_CERT_PATH")"/>
    <Content ignore="false" zipEntry="cert/$(basename "$CLIENT_CERT_PATH")"/>
  </Contents>
</MissionPackageManifest>
EOF

# Zip
ZIP_FILENAME="${CALLSIGN}.zip"
(
  zip -r "$ZIP_FILENAME" cert prefs MANIFEST &>/dev/null
) 
echo -e "${GREEN}Datapackage created: ${ZIP_FILENAME}${RESET}"

# Optional chown
# uid=1000
# gid=1001
# chown "$uid":"$gid" "$ZIP_FILENAME"

# Cleanup
echo -e "${YELLOW}Done! Datapackage for ${CALLSIGN} created ${RESET}"

rm -r ./MANIFEST
rm -r ./cert
rm -r ./prefs

# Extract truststore password
TRUSTSTORE_PASS=$(grep 'keystorePass=' "/opt/tak/CoreConfig.xml" | grep -v 'fed-truststore' | sed -n 's/.*keystorePass="\([^"]*\)".*/\1/p')

# Define the PEM path
TRUSTSTORE_PEM_PATH="${CA_CERT_PATH%.p12}.pem"
TRUSTSTORE="/opt/tak/certs/files/$(basename "$TRUSTSTORE_PEM_PATH")"

# Check if PEM exists, else convert
if [[ -f "$TRUSTSTORE_PEM_PATH" ]]; then
  echo -e "${GREEN}Using existing PEM truststore: ${TRUSTSTORE}${RESET}"
else
  echo -e "${YELLOW}Enter the password when prompted:${RESET} ${TRUSTSTORE_PASS}"
  openssl pkcs12 -in "$CA_CERT_PATH" -nokeys -out "$TRUSTSTORE_PEM_PATH" -nodes
fi

# Upload datapackage via curl
curl -vvvL -k -X POST \
  -H "Content-Type: application/x-zip-compressed" \
  --data-binary "@${ZIP_FILENAME}" \
  --cert "$ADMIN:$CERT_PASS" --cert-type P12 \
  --cacert "$TRUSTSTORE" \
  "https://localhost:8443/Marti/sync/upload?name=${ZIP_FILENAME}&keywords=missionpackage&creatorUid=webadmin" &








