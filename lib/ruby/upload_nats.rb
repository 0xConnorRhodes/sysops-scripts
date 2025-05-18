# upload attachments in each of the `.nats` folders in various directories within the notes repo

def upload_nats
  notes_dir = $notes_path
  remote_dir = ENV['REMOTE_DIR']
  static_url = ENV['STATIC_URL']
  access_token = ENV['ACCESS_TOKEN']

  nats_files = []
  nats_dirs = (Dir.glob(File.join(notes_dir, '.nats')) + Dir.glob(File.join(notes_dir, '**', '.nats'))).uniq
  nats_dirs.each do |nats_folder|
    Dir.glob(File.join(nats_folder, '*')).each do |file_path|
      next unless File.file?(file_path)
      relative_file = file_path.sub(%r{\A#{Regexp.escape(notes_dir + File::SEPARATOR)}}, '')
      nats_files << relative_file
    end
  end
end