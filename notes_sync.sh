#!/usr/bin/env sh

source .env # provides NOTES_PATH

cd "$NOTES_PATH"

CHANGES_EXIST="$(git status --porcelain | wc -l)"

if [ "$CHANGES_EXIST" -eq 0 ] ; then
	exit 0
fi

git pull
git add .
git commit -q -m "autosync"
git push -q
