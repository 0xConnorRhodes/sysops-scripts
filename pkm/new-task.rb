#!/usr/bin/env ruby

require 'highline'
require 'date'
require "fzf"

class TaskCreator
  def initialize
    @notes_folder = File.expand_path("~/notes")
  end

  def get_task_str
    cli = HighLine.new
    task_str = cli.ask "task: "
  end

  def create_task_file task_name:, file_content:
    file_name = "tk_#{task_name}.md"
    file_path = File.join(@notes_folder, file_name)
    File.open(file_path, 'w') do |f|
      f.puts file_content
    end
    return file_path
  end

  def process_task_str task_str
    start_match = task_str.match(/s \d{6}/) || task_str.match(/s \d{1,2}/)
    if start_match
      start_date = start_match[0].slice(2..-1).to_i
    else
      start_match = task_str.match(/s\d{6}/) || task_str.match(/s\d{1,2}/)
      if start_match
        start_date = start_match[0].slice(1..-1).to_i
      else
        start_date = nil
      end
    end

    if start_date && start_date < 101
      start_date = (Date.today + start_date).strftime('%y%m%d')
    end

    due_match = task_str.match(/d \d{6}/) || task_str.match(/d \d{1,2}/)
    if due_match
      due_date = due_match[0].slice(2..-1).to_i
    else
      due_match = task_str.match(/d\d{6}/) || task_str.match(/d\d{1,2}/)
      if due_match
        due_date = due_match[0].slice(1..-1).to_i
      else
        due_date = nil
      end
    end

    if due_date && due_date < 101
      due_date = (Date.today + due_date).strftime('%y%m%d')
    end

    task_name = task_str.sub(start_match.to_s, '').sub(due_match.to_s, '').strip

    task_data = { task_name: task_name, start_date: start_date, due_date: due_date }
  end

  def render_file_content task_data, task_meta
    file_lines = ["# meta\n", 
                  "\n", 
                  "# info\n", 
                  "\n\n", 
                  "# mtks\n", 
                  "- [ ] \n", 
                  "\n"]

    if task_meta[:tags].include?("# ")
      file_lines.insert(1, "- tags: \n",)
    else
      file_lines.insert(1, "- tags: #{task_meta[:tags].join(', ')}\n")
    end

    if task_meta[:projects].any?
      file_lines.insert(2, "- project: #{task_meta[:projects].join(', ')}\n")
    end

    if task_data[:start_date]
      file_lines.insert(2, "- start_date: #{task_data[:start_date]}\n")
    end

    if task_data[:due_date]
      file_lines.insert(2, "- due_date: #{task_data[:due_date]}\n")
    end

    file_lines.join()
  end

  def prompt_meta
    tags_list = [' ']+File.readlines(File.join(@notes_folder, '.task-tags.list'))

    project_list = Dir.glob(
      File.join(@notes_folder, 'tk_p_*'))
      .map{|i| i[@notes_folder.length+4..-4]}

    project_list.reject! {|i| i.include?("(Connor Rhodes's conflicted copy)") }

    choices = fzf(tags_list+project_list, '-m')

    projects = choices.grep(/^p_/)
    tags = choices - projects
    tags.map!{|i| "#"+i}
    projects.map!{|i| "[[tk_#{i}]]"}

    meta = { tags: tags, projects: projects }
    return meta
  end

end # end Class

new_task = TaskCreator.new
task_str = new_task.get_task_str
exit(1) if task_str.empty?
task_data = new_task.process_task_str(task_str)
task_meta = new_task.prompt_meta
file_content = new_task.render_file_content(task_data, task_meta)
task_file = new_task.create_task_file(task_name: task_data[:task_name], file_content: file_content)
if ENV['TERMUX_VERSION']
  exec("termux-open \"#{task_file}\"")
elsif RUBY_PLATFORM.include?("darwin")
  exec("#{ENV['HOME']}/.nix-profile/bin/code \"#{ENV['HOME']}/code/notes/#{File.basename(task_file)}\"")
else
  exec("nvim \"#{task_file}\"")
end
