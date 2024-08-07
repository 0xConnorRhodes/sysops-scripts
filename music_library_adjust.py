#!/usr/bin/env python3
# Script for transcoding music files and moving them to a server directory.

# CONFIG
music_library = '/zstore/media/music/music_library/music_library/'
#music_serve = '/zstore/media/music/music_serve/'
music_serve = '/media/music/'
vol_adjust = '0.03'

import os

# copy contents of music_archive to music_serve overwriting existing files
os.system(f'cp -r {music_library}/* {music_serve}/')

for root, dirs, files in os.walk(music_serve):
    for file in files:
        if file.rsplit('.', maxsplit=1)[-1] in ['mp3', 'm4a']:
            filepath = os.path.join(root, file)
            temp_file_path = os.path.join(root, ('q_' + file))

            os.system(f'ffmpeg -i "{filepath}" -vn -filter:a "volume={vol_adjust}" "{temp_file_path}"')

            os.remove(filepath)

            os.rename(temp_file_path, filepath)

