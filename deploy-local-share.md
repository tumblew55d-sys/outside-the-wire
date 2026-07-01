# Local Network Sharing

## Share on your local network:

# Your app is currently running at:
# http://localhost:8080

# To share on your local network:

# 1. Find your local IP address:
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object IPAddress, InterfaceAlias

# 2. Share the IP address with your local network users
# Example: http://192.168.1.100:8080

## For temporary internet sharing (testing only):

# Use ngrok (requires signup):
# 1. Download ngrok: https://ngrok.com/download
# 2. Run: ngrok http 8080
# 3. Share the generated URL (expires when you close ngrok)

# Note: This is only for testing. Use proper hosting (GitHub Pages, Firebase, etc.) for production.
