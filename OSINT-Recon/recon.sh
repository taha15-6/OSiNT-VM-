#!/bin/bash
# Trace Labs OSINT VM – Ultimate Domain Recon v2025
# Works out of the box on official Trace Labs VM

if [ -z "$1" ]; then
    echo "Usage: $0 <domain.com>"
    exit 1
fi

DOMAIN="$1"
OUT="results/$DOMAIN"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
mkdir -p "$OUT/screenshots"

echo "Starting full automated recon on $DOMAIN"
echo "Results → $OUT"

# 1. Subdomain Enumeration (best sources on Trace Labs)
echo "[1/7] Subdomain enumeration..."
subfinder -d $DOMAIN -all -silent -o "$OUT/subfinder.txt"
assetfinder --subs-only $DOMAIN > "$OUT/assetfinder.txt"
amass enum -passive -d $DOMAIN -o "$OUT/amass.txt"
sublist3r -d $DOMAIN -o "$OUT/sublist3r.txt" 2>/dev/null || true

cat "$OUT"/*.txt 2>/dev/null | sort -u | grep -v "*" > "$OUT/subdomains.txt"

# 2. Alive check + titles + tech + status codes
echo "[2/7] Probing with httpx..."
cat "$OUT/subdomains.txt" | httpx -title -tech-detect -status-code -timeout 15 -retries 2 -silent -o "$OUT/alive.txt"

# 3. Screenshots (gowitness works perfectly on Trace Labs)
echo "[3/7] Taking screenshots..."
cat "$OUT/alive.txt" | awk '{print $1}' | gowitness file -f - --destination "$OUT/screenshots" --threads 30 --timeout 20 --delay 1

# 4. Historical URLs (gauplus + waybackurls)
echo "[4/7] Crawling archives..."
echo "$DOMAIN" | waybackurls > "$OUT/wayback.txt"
cat "$OUT/subdomains.txt" | gauplus -t 40 -random -subs -o "$OUT/gau.txt"
cat "$OUT"/wayback.txt "$OUT"/gau.txt 2>/dev/null | sort -u > "$OUT/urls.txt"

# 5. DNS + WHOIS
echo "[5/7] WHOIS & DNS..."
whois "$DOMAIN" > "$OUT/whois.txt" 2>/dev/null || true
dig ANY "$DOMAIN" > "$OUT/dig.txt" 2>/dev/null

# 6. Light tech scan with Nuclei
echo "[6/7] Nuclei tech detection..."
nuclei -l "$OUT/alive.txt" -t technologies/ -silent -o "$OUT/nuclei_tech.txt" 2>/dev/null || true

# 7. Generate beautiful HTML report
echo "[7/7] Generating report..."
cat > "$OUT/report.html" <<EOF
<!DOCTYPE html>
<html><head><title>Trace Labs OSINT Report - $DOMAIN</title>
<meta charset="utf-8">
<style>
  body {font-family: Arial; background:#0d1117; color:#c9d1d9; padding:30px; line-height:1.6;}
  h1,h2 {color:#58a6ff;} pre {background:#161b22; padding:15px; border-radius:8px; overflow-x:auto;}
  img {max-width:300px; margin:8px; border:2px solid #30363d; border-radius:8px;}
  .grid {display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:15px;}
  .footer {margin-top:50px; font-size:90%; color:#8b949e;}
</style></head>
<body>
<h1>Trace Labs OSINT Recon Report</h1>
<p><strong>Target:</strong> $DOMAIN<br><strong>Generated:</strong> $TIMESTAMP (Trace Labs VM)</p>

<h2>Alive Subdomains (Title | Status | Tech)</h2>
<pre>$(cat "$OUT/alive.txt" | head -50)</pre>

<h2>Screenshots</h2>
<div class="grid">
$(find "$OUT/screenshots" -name "*.png" -type f | head -40 | sed 's|^|<img src="|; s|$|">|')
</div>

<h2>Sample Historical URLs (last 50)</h2>
<pre>$(tail -50 "$OUT/urls.txt")</pre>

<h2>WHOIS Summary</h2>
<pre>$(grep -iE "registrar|created|expiry|name server|status" "$OUT/whois.txt" 2>/dev/null || echo "No WHOIS data")</pre>

<div class="footer"><i>Generated on official Trace Labs OSINT VM • 100% legal & ethical when used properly</i></div>
</body></html>
