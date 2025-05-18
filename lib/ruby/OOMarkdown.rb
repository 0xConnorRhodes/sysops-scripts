class OOMarkdown
  def append_to_heading(file, heading, append_lines)
    # given a heading, parse all text under that heading (including nested subheadings)
    # append the append_lines array to this section of the file and write the full contents back to the file
    file_lines = File.readlines(file)
    segment_start = file_lines.index(heading)

    unless segment_start
      puts "Error: Heading \"#{heading.chomp}\" not in file"
      exit(1)
    end

    heading_level = heading.match(/^(#+).*/)&.[](1)

    segment_end = nil
    file_lines[segment_start+1..-1].each do |line|
      if line[0..heading_level.length] == heading_level + " "
        segment_end = file_lines.index(line)
        break
      end
      segment_end = -1
    end

    new_file_lines = file_lines[..segment_end-1] + append_lines + ["\n"] + file_lines[segment_end..]
    File.open(file, 'w') { |file| file.puts new_file_lines }
  end

  def append_under_heading(file, heading, append_lines)
    # appends under all text in the given heading but above any subheadings (if they exist)
    nil
  end

  def prepend_to_heading(file, heading, append_lines)
    # insert as the top text under the given heading
    file_lines = File.readlines(file)
    segment_start = file_lines.index(heading)

    unless segment_start
      puts "Error: Heading \"#{heading.chomp}\" not in file"
      exit(1)
    end

    # heading_level = heading.match(/^(#+).*/)&.[](1)

    # segment_end = nil
    # file_lines[segment_start+1..-1].each do |line|
    #   if line[0..heading_level.length] == heading_level + " "
    #     segment_end = file_lines.index(line)
    #     break
    #   end
    #   segment_end = -1
    # end

    new_file_lines = file_lines[..segment_start] + append_lines + file_lines[segment_start+1..]
    File.open(file, 'w') { |file| file.puts new_file_lines }
  end
end
