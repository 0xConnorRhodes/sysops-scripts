#!/usr/bin/env python3

from datetime import datetime, timedelta
from jinja2 import Environment, FileSystemLoader
import os

home_dir = os.path.expanduser("~")
notes_dir = f"{home_dir}/notes"

def render_note_content(date_str):
    return template.render(
        today=date_str,
        yesterday=(datetime.strptime(date_str, '%y%m%d') - timedelta(days=1)).strftime('%y%m%d'),
        tomorrow=(datetime.strptime(date_str, '%y%m%d') + timedelta(days=1)).strftime('%y%m%d'),
    )

def get_note_filepath(date_str):
    return os.path.join(notes_dir, f"dn_{date_str}.md")

# Determine path to script, set and load template
base_dir = os.path.dirname(os.path.abspath(__file__))
template_dir = f"{home_dir}/code/notes-templates"
env = Environment(loader=FileSystemLoader(template_dir))
template = env.get_template('daily_note-template.md.j2')

# Get and format dates
today = datetime.now()
today_str = today.strftime('%y%m%d')
yesterday_str = (today - timedelta(days=1)).strftime('%y%m%d')
tomorrow_str = (today + timedelta(days=1)).strftime('%y%m%d')

# remove yesterday's note file if it was never edited
yesterday_note = get_note_filepath(yesterday_str)
if os.path.exists(yesterday_note):
    yesterday_content = render_note_content(yesterday_str)
    with open(yesterday_note) as file:
        file_content = file.read()
    if file_content == yesterday_content:
        os.remove(yesterday_note)

today_note = get_note_filepath(today_str)
if not os.path.exists(today_note):
    today_content = render_note_content(today_str)
    with open(today_note, 'w') as file:
        file.write(today_content)
    print(f"Daily note: dn_{today_str}.md created")

tomorrow_note = get_note_filepath(tomorrow_str)
if not os.path.exists(tomorrow_note):
    tomorrow_content = render_note_content(tomorrow_str)
    with open(tomorrow_note, 'w') as file:
        file.write(tomorrow_content)
    print(f"Daily note: dn_{tomorrow_str}.md created")
