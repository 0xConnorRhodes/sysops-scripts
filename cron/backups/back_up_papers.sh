#!/usr/bin/env sh

rclone copy --max-age 24h --no-traverse ~/Documents/papers dropbox_enc:papers
rsync -r ~/Documents/papers s:/zstore/data/records/papers
