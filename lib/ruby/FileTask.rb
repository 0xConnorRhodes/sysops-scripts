require 'fileutils'
require 'date'

class FileTask
  def initialize
    @notes_folder =  File.join(File.expand_path('~'), 'notes')
    @file_date = Date.today.strftime('%y%m%d').to_s
  end

  def file_task task, operation
    # task: tk_task name.md
    # operation: done, drop, hold
    task_filed = task.sub("tk_", @file_date + '-')

    source = File.join(@notes_folder, task)
    destination = File.join(@notes_folder, 't', operation, task_filed)
    FileUtils.mv(source, destination)

    puts "#{operation.upcase}: #{task}"

    current_link = "[[#{task[..-4]}]]"
    new_link = "[[t/#{operation}/#{task_filed[..-4]}]]"

    update_links current_link, new_link
  end #end file_task

  private
    def update_links old_link, new_link
      files = Dir.glob("#{@notes_folder}/**/*.md")

      files.each do |f|
        content = File.read(f)
        new_content = content.gsub(old_link, new_link)
        if content != new_content
          File.write(f, new_content)
          puts "Updated link in: #{f[@notes_folder.length+1..]}"
        end
      end
    end # end update_links, private
end # end class