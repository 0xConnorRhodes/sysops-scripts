#!/usr/bin/env python3
# Script for pre-processing podcast audio files.

# CONFIG
silent_speed = '15'
vol_adjust = '0.07'
podcasts_dir = '/zstore/newmedia/podcasts/ashelf_podcasts'

import os

subdirs = [i for i in os.listdir(podcasts_dir) if os.path.isdir(os.path.join(podcasts_dir, i))]
original_dirs = [i for i in subdirs if i.startswith('_original')]
rss_dirs = [i for i in subdirs if not i.startswith('_original')]

# remove silence from new downloads
for podcast in original_dirs:
    files = [file for file in os.listdir(os.path.join(podcasts_dir, podcast)) if file.endswith('.mp3')]
    prev_files = [file for file in os.listdir(os.path.join(podcasts_dir, podcast.replace('_original ', ''))) if file.endswith('.mp3')]
    # remove already converted files from the list of files to convert
    files = [file for file in files if file not in prev_files]

    # skip this iteration of the loop if there are no new podcast files
    if len(files) <= 0:
        print(f'No new files in {podcast.replace("_original ", "")}')
        continue

    # remove silence
    for file in files:
        print(os.path.join(podcast, file))
        os.system(f'auto-editor --no-open -s {silent_speed} "{os.path.join(podcast, file)}"')

# reduce volume on all _ALTERED files, move them to the corresponding folder, and clean up
for podcast in original_dirs:
    files = [file for file in os.listdir(os.path.join(podcasts_dir, podcast)) if '_ALTERED' in file]
    output_dir = podcast.replace('_original ', '')

    for file in files:
        output_file = file.replace('_ALTERED', '')
        input_path = os.path.join(podcast, file)
        output_path = os.path.join(output_dir, output_file)

        os.system(f'ffmpeg -i "{input_path}" -vn -filter:a "volume={vol_adjust}" "{output_path}"')

        if os.path.exists(output_path):
            os.remove(input_path)

