#!/usr/bin/env python3
"""Create today's and tomorrow's org daily notes under ~/notes.

Scheduled nightly at 03:00 by a systemd timer
(modules/jobs/zk-cron.nix -> create-daily-note.{timer,service}). Emacs does NOT
create these files: it only opens what this job (and then notes-syncd) have
materialized, so a missing note surfaces a sync problem instead of being
silently papered over with a duplicate.

Each note is rendered from the org template
(configs/emacs/lisp/org/daily-note-template.org, tracked in the forge repo) by
substituting the {{date}}, {{yesterday}} and {{tomorrow}} tokens — so every
note carries clickable Yesterday / Tomorrow links to its neighbours.

Idempotent: never overwrites an existing note, never deletes notes.

Override the template / notes directory with the DAILY_NOTE_TEMPLATE and
NOTES_DIR environment variables (defaults: forge template, ~/notes).
"""

from __future__ import annotations

import os
import sys
from datetime import date, timedelta
from pathlib import Path

# This script lives in ~/code/scripts/cron/. The org template it renders is
# tracked in the sibling forge checkout (~/code/forge), so resolve across:
#   SCRIPT_DIR.parents[0] = ~/code/scripts
#   SCRIPT_DIR.parents[1] = ~/code
SCRIPT_DIR = Path(__file__).resolve().parent
CODE_ROOT = SCRIPT_DIR.parents[1]
FORGE_ROOT = CODE_ROOT / "forge"
DEFAULT_TEMPLATE = FORGE_ROOT / "configs" / "emacs" / "lisp" / "org" / "daily-note-template.org"


def stamp(d: date) -> str:
    """YYMMDD for date d."""
    return d.strftime("%y%m%d")


def render(template_text: str, d: date) -> str:
    """Substitute the note's own date and its neighbour stamps."""
    text = template_text
    text = text.replace("{{date}}", d.strftime("%Y-%m-%d %A"))
    text = text.replace("{{yesterday}}", stamp(d - timedelta(days=1)))
    text = text.replace("{{tomorrow}}", stamp(d + timedelta(days=1)))
    return text


def create(notes_dir: Path, template_text: str, d: date) -> bool:
    """Create dn/<stamp>.org for d if missing. Return True if created.

    Notes live under <notes_dir>/dn/ (one file per day, named <stamp>.org)."""
    daily_dir = notes_dir / "dn"
    path = daily_dir / f"{stamp(d)}.org"
    if path.exists():
        return False
    daily_dir.mkdir(parents=True, exist_ok=True)
    path.write_text(render(template_text, d))
    print(f"daily note created: {path}")
    return True


def main() -> int:
    notes_dir = Path(os.environ.get("NOTES_DIR", Path.home() / "notes"))
    template_path = Path(os.environ.get("DAILY_NOTE_TEMPLATE", DEFAULT_TEMPLATE))
    template_text = template_path.read_text()

    today = date.today()
    for d in (today, today + timedelta(days=1)):
        create(notes_dir, template_text, d)
    return 0


if __name__ == "__main__":
    sys.exit(main())
