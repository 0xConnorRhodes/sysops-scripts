class TaskLister
  def initialize
    @notes_folder = File.join(File.expand_path('~'), 'notes')
  end

  def get_tasks_by_date(key_string, date_limit)
    date_tasks = `rg -d 1 -l "#{key_string}" #{@notes_folder}/tk_*`.split("\n")
    date_tasks -= date_tasks.grep(/(Connor Rhodes's conflicted copy)/)

    date_tasks.each do |t|
      # int value of due date from file
      task_date = File.readlines(t).grep(/#{key_string}/)[0].match(/\d{6}/)

      unless task_date.nil?
        task_date = task_date[0].to_i
      else
        puts "WARNING: Task #{t} has invalid date format"
        sleep 3
        next
      end

      date_tasks -= Array(t) unless task_date <= date_limit
    end

    # slice off file path, task prefix, and extension. Keep _ so no char replacement needed later
    date_tasks -= date_tasks.grep(/(Connor Rhodes's conflicted copy)/)
    return date_tasks.map {|i| i[@notes_folder.length+3..-4]}
  end
end
