#!/usr/bin/env ruby

require 'date'
require_relative '../lib/ruby/TaskLister'
require_relative '../lib/ruby/OOMarkdown'

def build_on_deck_section(due_tasks_arr, due_soon_tasks_arr, start_tasks_arr)
  on_deck_section = []
  on_deck_section += ['### due'] + due_tasks_arr.map{|i| "- [[tk#{i}]]"} + ["\n"] if due_tasks_arr.length > 0
  on_deck_section += ['### due soon'] + due_soon_tasks_arr.map{|i| "- [[tk#{i}]]"} + ["\n"] if due_soon_tasks_arr.length > 0
  on_deck_section += ['### start'] + start_tasks_arr.map{|i| "- [[tk#{i}]]"} + ["\n"] if start_tasks_arr.length > 0
  on_deck_section.unshift('## on deck') unless on_deck_section.empty?

  return on_deck_section
end

notes_folder = File.join(File.expand_path('~'), 'notes')
tasks = TaskLister.new
oom = OOMarkdown.new

today = Date.today.strftime('%y%m%d').to_i
daily_note_path = File.join(notes_folder, "dn_#{today}.md")
target_heading = "# Today I *get* to\n"

if File.readlines(daily_note_path).grep("## on deck\n").length > 0
  puts "On deck tasks already present in file dn_#{today}.md"
  exit(1)
end

due_tasks = tasks.get_tasks_by_date("due_date: ", today)
due_soon_tasks = tasks.get_tasks_by_date("due_date: ", today+3) - due_tasks
start_tasks = tasks.get_tasks_by_date("start_date: ", today) - due_soon_tasks

on_deck_md = build_on_deck_section(due_tasks, due_soon_tasks, start_tasks)

oom.append_to_heading(daily_note_path, target_heading, on_deck_md)
