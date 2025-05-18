#!/usr/bin/env ruby
# back up list of files and directories on desktop cache drive to rclone

require 'date'

date = Date.today.strftime('%y%m%d')
filename = "#{date}-cache-drive-files.txt"
files = `fd . /scary > /tmp/#{filename}`

def upload(filename, remote)
  system("rclone moveto /tmp/#{filename} #{remote}:cache_drive_files/#{filename}")
end

remotes = %w[
  dropbox_enc
]

remotes.each { |remote| upload(filename, remote) }
