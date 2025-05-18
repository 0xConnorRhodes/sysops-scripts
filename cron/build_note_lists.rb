#!/usr/bin/env ruby
# script to build note index lists based on specific tags

NOTES_FOLDER = File.join(File.expand_path('~'), 'notes')

def build_list_from_tag (tag_query, output_file)
  file_list = `rg -l -d 1 "#{tag_query}" "#{NOTES_FOLDER}"`.split("\n")

  # slice from after the file path to before the file extension
  file_list.map! {|i| i[NOTES_FOLDER.length+1..-4]}
  file_list.append('NEW')

  File.open(File.join(NOTES_FOLDER, output_file), 'w') do |f|
    f.puts(file_list)
  end
end

def build_list_from_filename(glob_pattern, output_file)
  file_list = Dir.glob("#{NOTES_FOLDER}/#{glob_pattern}")
  file_list.map! {|i| i[(NOTES_FOLDER.length + glob_pattern.length)..-4]}
  file_list.append('NEW')

  File.open(File.join(NOTES_FOLDER, output_file), 'w') do |f|
    f.puts(file_list)
  end
end

build_list_from_tag('#vaccounts', '.vaccounts.list')
build_list_from_filename('r_*', '.rdex.list')
build_list_from_filename('c_*', '.circles.list')
