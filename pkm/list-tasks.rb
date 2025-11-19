require 'fileutils'
require 'fzf'

class ListTasksMenu
  def initialize
    @notes_folder = File.expand_path('~/notes')
    @today = Time.now.strftime('%y%m%d').to_i
  end

  def get_tasks_by_date(date_type, target_date)
    tasks = []
    task_files = Dir.glob(File.join(@notes_folder, 'tk_*.md'))

    task_files.each do |file|
      content = File.read(file)
      if content.match(/#{date_type}(\d{6})/)
        file_date = content.match(/#{date_type}(\d{6})/)[1].to_i
        if (date_type == "due_date: " && file_date <= target_date) ||
           (date_type == "start_date: " && file_date <= target_date)
          task_name = File.basename(file, '.md').sub('tk_', '')
          tasks << task_name
        end
      end
    end

    tasks
  end

  def generate_output
    # generate sequential output for single puts to terminal
    due_tasks = get_tasks_by_date("due_date: ", @today)
    due_soon_tasks = (get_tasks_by_date("due_date: ", @today+2) - due_tasks)
    start_tasks = get_tasks_by_date("start_date: ", @today) - (due_tasks + due_soon_tasks)

    output = []
    if due_tasks.length > 0
      output << "due tasks:"
      output += due_tasks
    end

    if due_soon_tasks.length > 0
      output << "due soon tasks:"
      output += due_soon_tasks
    end

    if start_tasks.length > 0
      output << "start tasks:"
      output += start_tasks
    end

    return output
  end

  def file_task(task_file, operation)
    date = Time.now.strftime('%y%m%d')
    move_from = File.join(@notes_folder, task_file)
    move_to = File.join(@notes_folder, 't', operation, "#{date}-#{File.basename(task_file, '.md').sub('tk_', '')}.md")

    # Create directory if it doesn't exist
    FileUtils.mkdir_p(File.dirname(move_to))

    FileUtils.mv(move_from, move_to)

    search_string = File.basename(task_file, '.md')
    files_with_links = `rg -l -F -d 1 "[[#{search_string}]]" #{@notes_folder}`.split("\n")
    replace_string = "_tk/#{operation}/#{date}-#{search_string.sub('tk_', '')}"

    files_with_links.each do |f|
      `sed -i 's##{search_string}##{replace_string}#g' "#{f}"`
    end

    puts "#{operation.upcase}: #{File.basename(task_file, '.md').sub('tk_', '')}"
  end

  def fzf_display_output output, editor:, preview: false
      output.unshift('q')
      output.unshift('ls')
      output.reverse!

      if preview
        preview_cmd = "--preview='bat ~/notes/tk_{}.md --color=always --style=plain -l markdown'"
        choices = fzf(output, "-m #{preview_cmd}")
      else
        choices = fzf(output, '-m')
      end

      if choices.include? 'q'
        exit(0)
      elsif choices.include? 'ls'
        output.delete('q')
        output.delete('ls')
        output.reverse!
        puts output
        exit(0)
      elsif choices.length == 1
        operation = fzf(['edit', 'done', 'drop', 'hold'])[0]
        task_file = "tk_#{choices[0]}.md"
        task_path = File.expand_path("~/notes/#{task_file}")
        case operation
        when 'edit'
          system("#{editor} \"#{task_path}\"")
        when 'done', 'drop', 'hold'
          file_task(task_file, operation)
        end
      else
        operation = fzf(['done', 'drop', 'hold'])[0]
        choices.each do |choice|
          task_file = "tk_#{choice}.md"
          file_task(task_file, operation)
        end
      end
  end # end fzf_display_output
end #end class

menu = ListTasksMenu.new

if ENV['TERMUX_VERSION']
  raw_output = menu.generate_output
  menu.fzf_display_output(raw_output, editor: 'termux-open', preview: false)
else
  loop do
    raw_output = menu.generate_output
    menu.fzf_display_output(raw_output, editor: 'nvim', preview: true)
  end
end
