#!/home/connor/code/sysops-scripts/.pyvenv/bin/python3
import os
import re
from datetime import datetime, timedelta

notes_dir = '/zssd/notes'

today = datetime.now()
today_str = today.strftime('%y%m%d')
tomorrow_str = (today + timedelta(days=1)).strftime('%y%m%d')
d_a_tomorrow_str = (today + timedelta(days=2)).strftime('%y%m%d')
tomorrow_file = f"📅{tomorrow_str}.md"
d_a_tomorrow_file = f"📅{d_a_tomorrow_str}.md"

for filename in os.listdir(notes_dir):
    if filename.startswith("📅"):
        with open(os.path.join(notes_dir, filename), 'r') as file:
            contents = file.read()
            dates = re.findall(r'\[\[📅\d{6}\]\]', contents)
            for date in dates:
                linkfile = date.replace("[", "").replace("]", "") + '.md'
                if linkfile == tomorrow_file or linkfile == d_a_tomorrow_file:
                    continue
                elif not os.path.exists(os.path.join(notes_dir, linkfile)):
                    filepath = os.path.join(notes_dir, filename)
                    with open(filepath, 'r') as file:
                        filedata = file.read()
                    filedata = filedata.replace(date, '')
                    with open(filepath, 'w') as file:
                        file.write(filedata)
                    print(f"pruned link in {filename}")
