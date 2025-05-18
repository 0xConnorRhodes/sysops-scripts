#!/usr/bin/env ruby

require 'date'

file_path = File.join(File.expand_path('~'), 'notes', 'index.md')
file_lines = File.readlines(file_path)

daily_index = file_lines.find_index { |line| line.strip == "# Daily" }
today_date = Date.today.strftime('%y%m%d')

file_lines[daily_index + 1] = "- [[dn_#{today_date}]]\n"

File.open(file_path, 'w') do |file|
  file.puts(file_lines)
end
