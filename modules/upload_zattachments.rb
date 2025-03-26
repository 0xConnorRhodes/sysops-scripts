# upload attachments in the zattachments folder (1 folder for entire notes repo)

def upload_zattachments
  notes_dir = $notes_path
  remote_dir = ENV['REMOTE_DIR']
  static_url = ENV['STATIC_URL']
  access_token = ENV['ACCESS_TOKEN']

  attachments = Dir.glob(File.join(notes_dir, 'zattachments', '*'))

  if attachments.empty?
    puts "No local attachments"
    return
  end

  attachments = attachments.map {|f| File.basename(f)}

  remote_files = `rsync --list-only '#{remote_dir}/'`.split("\n").map { |line| line.split.last }
  if remote_files.empty?
    puts "Error listing remote files. Do you have network access?"
    exit 1
  end

  attachments.each do |attachment|
    remote_filename = Time.now.utc.strftime("%Y%m%d%H%M%S-%L")
    remote_filename += File.extname(attachment).downcase # preserve file extension

    if remote_files.include?(remote_filename)
      puts "Warning: #{remote_filename} already exists on remote, exiting"
      exit 1
    end

    upload = false
    file_data = {
      wiki_link_files: `rg -F -l "zattachments/#{attachment}]]" "#{notes_dir}"`.split("\n"),
      md_link_files: `rg -F -l "zattachments/#{attachment})" "#{notes_dir}"`.split("\n"),
      wiki_short_link_files: `rg -F -l "![[#{attachment}]]" "#{notes_dir}"`.split("\n"),
    }

    # skip dangling attachments
    files = file_data[:wiki_link_files] + file_data[:md_link_files] + file_data[:wiki_short_link_files]
    if files.count == 0
      present_files = `rg -F -l "#{attachment}" "#{notes_dir}"`.split("\n")
      puts "No files found for #{attachment}, removing"
      `rm "#{notes_dir}/zattachments/#{attachment}"` if present_files.count == 0
      next
    end

    file_data[:wiki_link_files].each do |file_path|
      file_content = File.read(file_path)
      # match any amount of ../ in relative path
      pattern = /!?\[\[(?:\.\.\/)*zattachments\/#{attachment}\]\]/
      matches = file_content.scan(pattern)
      matches.uniq.each do |match|
        puts "replacing #{match} in #{file_path}"
        new_link = "![](#{static_url}/#{remote_filename}?#{access_token})"
        File.write(file_path, file_content.gsub(match, new_link))
        upload = true
      end
    end

    file_data[:md_link_files].each do |file_path|
      file_content = File.read(file_path)
      # match any amount of ../ in relative path and any link text
      pattern = /!?\[[^\]]*\]\((?:\.\.\/)*\/?zattachments\/#{attachment}\)/
      matches = file_content.scan(pattern)
      matches.uniq.each do |match|
        puts "replacing #{match} in #{file_path}"
        new_link = "![](#{static_url}/#{remote_filename}?#{access_token})"
        File.write(file_path, file_content.gsub(match, new_link))
        upload = true
      end
    end

    file_data[:wiki_short_link_files].each do |file_path|
      file_content = File.read(file_path)
      # match any amount of ../ in relative path
      search_string = "![[#{attachment}]]"
      if file_content.include?(search_string)
        puts "replacing #{search_string} in #{file_path}"
        new_link = "![](#{static_url}/#{remote_filename}?#{access_token})"
        File.write(file_path, file_content.gsub(search_string, new_link))
        upload = true
      end
    end

    if upload
      puts "Uploading #{attachment}"
      puts `rsync --remove-source-files '#{notes_dir}/zattachments/#{attachment}' '#{remote_dir}/#{remote_filename}'`
    end
  end

end
