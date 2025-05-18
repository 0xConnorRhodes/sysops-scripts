require 'fileutils'
require 'date'
require 'fzf'

class TasksViewer
  def initialize
    @notes_folder = File.expand_path("~/notes")
    @date = Time.now.strftime('%y%m%d')
  end

  def build_tasks_arr(include_future: false,  show_tags: false, exclude_tags: false)

    @tasks = []
    if show_tags
      show_tags.each do |tag|
        append_tasks = `rg -l -F -d 1 "##{tag}" "#{@notes_folder}" --glob "tk_*.md"`.split("\n")
        @tasks += append_tasks
      end
    else
      @tasks = Dir.glob(File.join(@notes_folder, 'tk_*.md'))
    end


    if include_future == false
      scheduled_tasks = `rg -l -F -d 1 "start_date: " "#{@notes_folder}"`.split("\n")
      future_tasks = []
      scheduled_tasks.each do |f|
       start_date = `grep "start_date: " "#{f}"`
       start_date = start_date.match(/\d{6}/)[0].to_i
       if start_date > @date.to_i
         future_tasks.push(f)
       end
      end
      @tasks = @tasks - future_tasks
    end
  end

  def display
    display_tasks = @tasks.map {|f| File.basename(f)}.map {|i| i.sub('tk_', '')}.map {|i| i.sub('.md', '')}
    display_tasks.unshift('q') # add 'q' option at begining to allow quitting script

    @chosen_tasks = fzf(display_tasks, "-m --preview='bat ~/notes/tk_{}.md --color=always --style=plain -l markdown'")
    exit if @chosen_tasks[0] == 'q'

    operation_list = ['done', 'drop', 'hold', 'tag', 'q']
    operation_list.unshift('edit') if @chosen_tasks.length == 1
    @operation = fzf(operation_list)[0]
    exit if @operation == 'q'
  end

  def process_choice
    case @operation
    when 'edit'
      edit_file = File.join(@notes_folder, "tk_#{@chosen_tasks[0]}.md")
      system("nvim \"#{edit_file}\"")
    when 'done', 'drop', 'hold'
      @chosen_tasks.each do |task|
        move_from = File.join(@notes_folder, "tk_#{task}.md")
        move_to = File.join(@notes_folder, 't', @operation, "#{@date}-#{task}.md")
      
        FileUtils.mv(move_from, move_to)
      
        search_string = "tk_#{task}"
        files_with_links = `rg -l -F -d 1 "[[#{search_string}]]" ~/notes`.split("\n")
        replace_string = "_tk/#{@operation}/#{@date}-#{task}"
      
        files_with_links.each do |f|
          `sed -i 's##{search_string}##{replace_string}#g' "#{f}"`
        end
      
        puts "#{@operation.upcase}: #{task}"
      end
    when 'tag'
      tag = fzf(['verk', 'proj'])[0]
      @chosen_tasks.each do |task|
        file_path = File.join(@notes_folder, "tk_#{task}.md")
        original_content = File.read(file_path)
        new_content = "##{tag}\n" + original_content
        File.open(file_path, 'w') do |file|
          file.write(new_content)
        end
      end
    end
  end
end

tasks = TasksViewer.new

# pass how tags on cli with `rb triage-tasks.rb "tag1 tag2"`
show_tags = ARGV[0] ? ARGV[0].split(' ') : false

while true
  tasks.build_tasks_arr(show_tags: show_tags)
  tasks.display
  tasks.process_choice
end
