#!/usr/bin/env lua
-- Daily Note Template
local template_content = "string"

-- Calculate the current date
os.date("*t")
local date = os.date("%y%m%d")

-- Search current folder to see if a daily note already exists
local file_name = "📅 " .. date .. ".md"
local file_exists = false
for filename in io.popen('ls', 'r'):lines() do
    if filename == file_name then
        file_exists = true
        break
    end
end

-- If a daily note exists print 'file exists'
if file_exists then
    print('file exists')
else
    -- If daily doesn't exist, create it and write the content
    local file = io.open(file_name, "w")
    file:write(template_content)
    file:close()
    print('file created')
end
