#!/bin/bash

process_name="obsidian"
run_command="flatpak run md.obsidian.Obsidian"

is_running=$(pgrep "$process_name")

if [ -z "$is_running" ]
then
	screen -dmS "$process_name"
	sleep 5
	screen -S "$process_name" -X stuff "$run_command\n"
else
	screen -S "$process_name" -X stuff $'\003' # sends ^c
	sleep 5
	screen -S "$process_name" -X stuff "$run_command\n"
fi
