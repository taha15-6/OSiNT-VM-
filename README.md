# OSINT - VM 
## Contributors
Muhammad Taha

Aaron Minhas

Umair Hashmi

Ramaize Shahab

Azhan Javed

Muhammad Owais Azhar

## 4 simple tools – 1 command each – perfect HTML reports with screenshots

### Tools (all ready to run on Trace Labs VM)

| Script name       | What you type                        | What you get                                      |
|-------------------|--------------------------------------|---------------------------------------------------|
| `username.sh`     | `maigret elonmusk`             | 180+ profiles + full screenshots (2–3 min)       |
| `email.sh`        | `./email.sh example@gmail.com`       | Breach history + leaked data + screenshots        |
| `domain.sh`       | `./domain.sh google.com`             | WHOIS, DNS, subdomains, SSL, security headers    |
| `bitcoin.sh`      | `./bitcoin.sh 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa` | Balance, transactions, tags + explorer screenshot |
                

### Requirements (already installed on Trace Labs VM)
- Python venv activated → `source ~/osint-venv/bin/activate`  
- Maigret → `/home/osint/osint-venv/bin/maigret`  
- Gowitness → `/usr/local/bin/gowitness`  
- Firefox (for opening reports)

### How to use
```bash
cd ~/trace-labs-osint-suite
./username.sh elonmusk     # or any other tool
```
→ Report automatically opens in Firefox when finished.

That’s it. No extra setup. Works 100 % on the official November 2025 VM.
