#!/bin/bash
[ -z "$1" ] && echo "Usage: $0 email@domain.com" && exit 1
E="$1"
O="results/$E"
mkdir -p "$O"

echo "[+] Running Holehe on $E (120+ sites)..."
# New 2025 syntax – no --pretty flag anymore
holehe "$E" > "$O/raw.txt" 2>&1

# Extract only the sites where it says "Yes" or "[+]"
grep -i -E "(Yes|\[\+\])" "$O/raw.txt" > "$O/found.txt" 2>/dev/null || echo "No accounts found" > "$O/found.txt"

cat > "$O/report.html" <<HTML
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Holehe – $E</title>
<style>
  body {font-family:Arial;background:#0d1117;color:#c9d1d9;padding:40px}
  h1 {color:#58a6ff} pre {background:#161b22;padding:20px;border-radius:8px;font-size:90%}
</style></head>
<body>
<h1>Holehe Email OSINT – $E</h1>
<p><b>Generated:</b> $(date)</p>
<h2>Registered Sites Found</h2>
<pre>$(cat "$O/found.txt")</pre>
<h2>Full Raw Output</h2>
<pre>$(cat "$O/raw.txt")</pre>
</body></html>
HTML

echo "════════════════════════════════"
echo "Holehe finished! → firefox $O/report.html"
echo "════════════════════════════════"
