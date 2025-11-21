#!/bin/bash
[ -z "$1" ] && echo "Usage: $0 <bitcoin_address>" && exit 1
A="$1"
O="results/$A"
mkdir -p "$O/screenshots"

echo "[+] Fetching Bitcoin data from Blockchair API..."
curl -s "https://api.blockchair.com/bitcoin/dashboards/address/$A" > "$O/data.json"

# Fixed jq paths for 2025 Blockchair structure
balance=$(jq -r ".data[\"$A\"].address.balance // 0" "$O/data.json")
usd=$(jq -r ".data[\"$A\"].address.balance_usd // 0" "$O/data.json")
tx_count=$(jq -r ".data[\"$A\"].address.transaction_count // 0" "$O/data.json")
first_seen=$(jq -r ".data[\"$A\"].address.first_seen_receiving // \"Never\"" "$O/data.json")
last_seen=$(jq -r ".data[\"$A\"].address.last_seen_receiving // \"Never\"" "$O/data.json")
label=$(jq -r ".data[\"$A\"].address.tags[0].name // \"Unknown\"" "$O/data.json" 2>/dev/null || echo "Unknown")

echo "[+] Screenshotting explorer page..."
echo "https://blockchair.com/bitcoin/address/$A" | gowitness scan file -f - --screenshot-path "$O/screenshots" --threads 10 --timeout 20 --delay 2

cat > "$O/report.html" << HTML
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Bitcoin Recon - $A</title>
<style>
  body {font-family:Arial;background:#0d1117;color:#c9d1d9;padding:40px}
  h1,h2 {color:#58a6ff} .info {font-size:120%;line-height:2}
  img {max-width:900px;border:2px solid #30363d;border-radius:12px;margin:20px 0}
  .footer {margin-top:60px;color:#8b949e}
</style></head>
<body>
<h1>Bitcoin Wallet OSINT Report – $A</h1>
<p><b>Generated:</b> $(date)</p>
<div class="info">
<b>Balance:</b> $balance BTC (~$$usd USD)<br>
<b>Total Transactions:</b> $tx_count<br>
<b>First Seen:</b> $first_seen<br>
<b>Last Activity:</b> $last_seen<br>
<b>Known Label/Tag:</b> $label
</div>
<h2>Blockchair Explorer Screenshot</h2>
$(find "$O/screenshots" -name "*.png" -exec printf '<img src="%s">' "{}" \;)
<div class="footer"><small>API: api.blockchair.com • 100% free • No key needed • Works in 2025</small></div>
</body></html>
HTML

echo "════════════════════════════════"
echo "Bitcoin recon finished!"
echo "Open → firefox $O/report.html"
echo "════════════════════════════════"
EOF

chmod +x bitcoin.sh
