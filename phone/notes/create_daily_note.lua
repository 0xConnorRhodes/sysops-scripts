#!/usr/bin/env lua
-- Create daily note from template file on phone

local template_path = os.getenv("HOME") .. "/Documents/scripts/notes/templates/_template_daily_note.md"

local date = os.date("%y%m%d")
local file_name = "📅 " .. date .. ".md"

-- Function to check if a file exists
local function file_exists(name)
    local f = io.open(name, "r")
    if f~=nil then io.close(f) return true else return false end
end

-- Check if the daily note file exists in the current directory
if file_exists(file_name) then
    print("file exists")
else
    -- Read the template content if it exists
    local template_file = io.open(template_path, "r")
    if not template_file then
        print("Template file does not exist.")
        return
    end
    local template_content = template_file:read("*a")
    template_file:close()

    -- Create the daily note file with the content from the template
    local daily_note_file = io.open(file_name, "w")
    daily_note_file:write(template_content)
    daily_note_file:close()
    print("note created")
end
