#!/Users/connor.rhodes/code/scripts/.venv/bin/python
import requests
import re
import sys
import os

# Configuration
TS_KEY = os.getenv("TAILSCALE_API_KEY")
TAILNET = os.getenv("TAILNET_SUFFIX")
DRY_RUN = False

if not TS_KEY or not TAILNET:
    print("Set TS_API_KEY and TS_TAILNET in environment.")
    sys.exit(1)

session = requests.Session()
session.auth = (TS_KEY, "")

# Fetch devices
print("Fetching devices...")
resp = session.get(f"https://api.tailscale.com/api/v2/tailnet/{TAILNET}/devices")
resp.raise_for_status()
devices = resp.json().get("devices", [])

print(f"Found {len(devices)} devices")
if DRY_RUN:
    print("*** DRY RUN MODE - No actual changes will be made ***")
print()

# Show all devices
for d in devices:
    print(f"  {d['name']}")
print()

# Group devices by base hostname
# Pattern matches: base-number.domain or base.domain
pattern = re.compile(r"^(?P<base>.+?)(?:-(?P<num>\d+))?(?P<domain>\.taila\d+\.ts\.net)$")
groups = {}

for d in devices:
    name = d["name"]
    m = pattern.match(name)
    if not m:
        continue

    base = m.group("base")
    num = int(m.group("num")) if m.group("num") else 0
    domain = m.group("domain")
    full_base = base + domain  # base hostname with domain

    groups.setdefault(full_base, []).append((num, d))

# Process groups with multiple devices
processed_any = False
for base, devs in groups.items():
    if len(devs) == 1:
        continue  # nothing to collapse

    processed_any = True
    print(f"Processing group '{base}' with {len(devs)} devices:")

    # Sort by number (lowest first)
    devs.sort(key=lambda x: x[0])

    # Show all devices in group
    for num, dev in devs:
        print(f"  - {dev['name']} (num: {num})")

    # Keep the highest numbered device
    to_delete = devs[:-1]
    to_keep_num, keep_dev = devs[-1]

    print(f"  → Keeping: {keep_dev['name']} (highest number: {to_keep_num})")
    print(f"  → Deleting: {[d['name'] for _, d in to_delete]}")

    # Delete older devices
    for num, d in to_delete:
        if DRY_RUN:
            print(f"  [DRY RUN] Would delete {d['name']}")
        else:
            print(f"  Deleting {d['name']}...")
            r = session.delete(f"https://api.tailscale.com/api/v2/device/{d['id']}")
            if r.status_code in (200, 204):
                print(f"    ✓ Deleted")
            else:
                print(f"    ✗ Failed: {r.status_code} - {r.text}")

    # Rename the survivor to remove the number suffix
    if keep_dev["name"] != base:
        new_short_name = base.replace('.taila2416.ts.net', '')  # Remove domain for API call
        if DRY_RUN:
            print(f"  [DRY RUN] Would rename {keep_dev['name']} -> {new_short_name}")
        else:
            print(f"  Renaming {keep_dev['name']} -> {new_short_name}...")

            # Use the specific name endpoint
            r = session.post(
                f"https://api.tailscale.com/api/v2/device/{keep_dev['id']}/name",
                json={"name": new_short_name}
            )

            if r.status_code in (200, 201):
                print(f"    ✓ Renamed successfully")
            else:
                print(f"    ✗ Rename failed: {r.status_code} - {r.text}")
                # The device might not support renaming via API
                # or the API key might not have the right permissions
                print(f"    You may need to rename manually in the Tailscale admin console")

    print()

if not processed_any:
    print("No device groups with duplicates found.")

    # Check for individual devices that have numbers and could be renamed
    devices_to_rename = []
    for d in devices:
        name = d["name"]
        # Look for names like "media-7.taila2416.ts.net"
        m = re.match(r"^(.+?)-(\d+)(\.taila\d+\.ts\.net)$", name)
        if m:
            base, num, domain = m.groups()
            new_name = base + domain
            devices_to_rename.append((d, name, base))

    if devices_to_rename:
        print(f"Found {len(devices_to_rename)} devices with numbers that could be renamed:")
        for device, old_name, new_base in devices_to_rename:
            print(f"  {old_name} -> {new_base}")

        if not DRY_RUN:
            print("\nRenaming devices...")
            for device, old_name, new_base in devices_to_rename:
                print(f"Renaming {old_name} -> {new_base}...")
                r = session.post(
                    f"https://api.tailscale.com/api/v2/device/{device['id']}/name",
                    json={"name": new_base}
                )
                if r.status_code in (200, 201):
                    print(f"  ✓ Success")
                else:
                    print(f"  ✗ Failed: {r.status_code} - {r.text}")
                    print(f"    Manual rename needed: Go to https://login.tailscale.com/admin/machines")

print("Script completed.")
