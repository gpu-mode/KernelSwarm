#!/bin/bash
# Usage: ./create-client.sh username device_number

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <device_number>"
  echo "Example: $0 john 1"
  exit 1
fi

USERNAME=$1
DEVICE_NUM=$2
IP="192.168.100.$((DEVICE_NUM + 10))"

# Install zip if needed
apt-get update -qq && apt-get install -y zip -qq

# Create certificate
cd /etc/nebula
nebula-cert sign -name "${USERNAME}-device${DEVICE_NUM}" -ip "${IP}/24" -groups "users"

# Create client directory
rm -rf /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}
mkdir -p /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}

# Copy files
cp ca.crt /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/
cp ${USERNAME}-device${DEVICE_NUM}.crt /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/host.crt
cp ${USERNAME}-device${DEVICE_NUM}.key /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/host.key

# Create config file
cat > /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/config.yml << EOCFG
pki:
  ca: ./ca.crt
  cert: ./host.crt
  key: ./host.key
static_host_map:
  "192.168.100.1": ["24.144.80.90:4242"]
lighthouse:
  am_lighthouse: false
  interval: 60
  hosts:
    - "192.168.100.1"
listen:
  host: 0.0.0.0
  port: 4242
punchy:
  punch: true
tun:
  dev: nebula1
  drop_local_broadcast: false
  drop_multicast: false
  tx_queue: 500
  mtu: 1300
logging:
  level: info
  format: text
firewall:
  outbound:
    - port: any
      proto: any
      host: any
  inbound:
    - port: any
      proto: any
      host: any
EOCFG

# Create readme file with instructions
cat > /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/README.txt << EOREADME
=== NEBULA CLIENT SETUP INSTRUCTIONS ===
1. Download and install Nebula for your OS:
   https://github.com/slackhq/nebula/releases
2. Place the Nebula binary in the same folder as these files
3. Run Nebula (as administrator/root):
   - Windows: Right-click cmd.exe, "Run as administrator" and run: nebula.exe -config config.yml
   - Mac/Linux: sudo ./nebula -config config.yml
4. Keep the terminal window open to maintain your connection
Your Nebula IP address: ${IP}
EOREADME

# Create platform-specific instructions
mkdir -p /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/windows
mkdir -p /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/mac
mkdir -p /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/linux

# Create Windows batch file
cat > /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/windows/start-nebula.bat << EOBAT
@echo off
echo Starting Nebula VPN...
echo This window must remain open for the connection to work
echo.
echo Your Nebula IP address: ${IP}
echo.
nebula.exe -config ../config.yml
pause
EOBAT

# Create Mac/Linux shell script
cat > /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/mac/start-nebula.sh << EOSH
#!/bin/bash
echo "Starting Nebula VPN..."
echo "This window must remain open for the connection to work"
echo ""
echo "Your Nebula IP address: ${IP}"
echo ""
sudo ./nebula -config ../config.yml
EOSH
chmod +x /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/mac/start-nebula.sh

# Create Linux shell script (same as Mac)
cp /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/mac/start-nebula.sh /etc/nebula/clients/${USERNAME}-${DEVICE_NUM}/linux/

# Package everything up
cd /etc/nebula/clients/
tar -czf ${USERNAME}-${DEVICE_NUM}.tar.gz ${USERNAME}-${DEVICE_NUM}/
zip -r ${USERNAME}-${DEVICE_NUM}.zip ${USERNAME}-${DEVICE_NUM}/

# Make packages downloadable
chmod 644 ${USERNAME}-${DEVICE_NUM}.tar.gz
chmod 644 ${USERNAME}-${DEVICE_NUM}.zip 2>/dev/null || true

echo ""
echo "Client package created for ${USERNAME}-${DEVICE_NUM} with IP ${IP}"
echo ""
echo "Download links:"
echo "TAR: scp root@24.144.80.90:/etc/nebula/clients/${USERNAME}-${DEVICE_NUM}.tar.gz ~/"
if [ -f "/etc/nebula/clients/${USERNAME}-${DEVICE_NUM}.zip" ]; then
  echo "ZIP: scp root@24.144.80.90:/etc/nebula/clients/${USERNAME}-${DEVICE_NUM}.zip ~/"
fi
echo ""
root@ubuntu-s-1vcpu-512mb-10gb-sfo3-01:~# 