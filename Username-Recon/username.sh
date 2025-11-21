#!/bin/bash
[[ -z "$1" ]] && { echo "Usage: $0 username"; exit 1; }
U="$1"
O="results/$U"
mkdir -p "$O/screenshots"

echo "[+] Running Maigret on: $U"
# 2025 working flags – this is the only combination that still prints URLs
maigret "$U" --all --print-found --site ALL --no-progressbar --timeout 40 > "$O/links.txt" 2>&1

# Extract URLs
grep -Eio 'https?://[^ ]+' "$O/links.txt" | grep -v 'maigret' | sort -u > "$O/urls.txt"
NUM=$(wc -l < "$O/urls.txt")
echo "[+] Found $NUM profiles"

if [[ $NUM -gt 0 ]]; then
    echo "[+] Screenshotting $NUM profiles (Gowitness v3)..."
    cat "$O/urls.txt" | gowitness scan file -f - \
        --screenshot-path "$O/screenshots" \
        --threads 30 \
        --timeout 25 \
        --delay 2 > /dev/null 2>&1
    sleep 80
fi

SHOT=$(find "$O/screenshots" -name "*.png" 2>/dev/null | wc -l)

cat > "$O/report.html" <<HTML
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>$U – Username Recon</title>
<style>
  body{font-family:Arial;background:#0d1117;color:#c9d1d9;padding:40px}
  h1,h2{color:#58a6ff}
  pre{background:#161b22;padding:20px;border-radius:8px}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:18px}
  img{max-width:100%;border:2px solid #30363d;border-radius:10px}
</style></head>
<body>
<h1>Username Recon – $U</h1>
<p><b>Generated:</b> $(date)</p>
<p><b>$NUM profiles found → $SHOT screenshots</b></p>
<h2>Raw Maigret Output</h2>
<pre>$(cat "$O/links.txt")</pre>
<h2>Screenshots</h2>
<div class="grid">
$(find "$O/screenshots" -name "*.png" -type f -printf '<img src="%f">\n' 2>/dev/null || echo "<p>No screenshots (some sites blocked)</p>")
</div>
</body></html>
HTML

echo "════════════════════════════════"
echo "DONE – $NUM profiles, $SHOT screenshots"
echo "Open → firefox $O/report.html"
echo "════════════════════════════════"
EOF

chmod +x username.sh
