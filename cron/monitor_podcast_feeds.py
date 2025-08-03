#!/home/connor/code/scripts/cron/.venv/bin/python

import sys
import os
import yaml
import feedparser
from datetime import datetime, date

CONFIG_FILE_PATH = os.path.expanduser('~/code/notes/monitored_podcasts.yml')
LOG_FILE_PATH = os.path.expanduser('~/code/notes/new_podcast_episodes.log')

def parse_date_from_yaml(date_str):
    """
    Parses a date string from the YAML file (format YYMMDD) into a datetime object.

    Args:
        date_str (str): The date string in 'YYMMDD' format.

    Returns:
        datetime.date: A date object.
    """
    return datetime.strptime(str(date_str), '%y%m%d').date()

def parse_date_from_feed(published_parsed):
    """
    Converts a time.struct_time object from feedparser into a datetime object.

    Args:
        published_parsed (time.struct_time): The parsed publication date from a feed entry.

    Returns:
        datetime.date: A date object.
    """
    # Use the imported date class directly
    return date(*published_parsed[:3])

def monitor_podcasts():
    """
    Monitors podcast RSS feeds based on a YAML config file and logs new episodes.
    """
    # --- 2. Read the YAML configuration file ---
    try:
        with open(CONFIG_FILE_PATH, 'r') as f:
            podcasts_to_monitor = yaml.safe_load(f)
        if not podcasts_to_monitor:
            print(f"Warning: Configuration file is empty or invalid: {CONFIG_FILE_PATH}")
            return
    except FileNotFoundError:
        print(f"Error: Configuration file not found at {CONFIG_FILE_PATH}")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}")
        sys.exit(1)

    # Read existing log entries to avoid duplicates
    existing_log_entries = set()
    if os.path.exists(LOG_FILE_PATH):
        with open(LOG_FILE_PATH, 'r') as log_file:
            existing_log_entries = set(log_file.read().splitlines())

    new_episodes_found = []

    # --- 3. Iterate through each podcast in the config ---
    for podcast_key, podcast_info in podcasts_to_monitor.items():
        podcast_name = podcast_info.get('name', 'Unknown Podcast')
        monitor_from_date_str = podcast_info.get('date')
        feed_url = podcast_info.get('feed')

        if not all([monitor_from_date_str, feed_url]):
            print(f"Warning: Skipping '{podcast_key}' due to missing 'date' or 'feed' URL.")
            continue

        print(f"Checking feed for: {podcast_name}...")

        monitor_from_date = parse_date_from_yaml(monitor_from_date_str)

        # --- 4. Fetch and parse the RSS feed ---
        # The ETag and modified headers are used to prevent re-downloading the feed
        # if it hasn't changed since the last time it has been fetched by feedparser.
        feed = feedparser.parse(feed_url)

        if feed.bozo:
            print(f"Warning: Could not parse the feed for {podcast_name}. "
                  f"Reason: {feed.bozo_exception}")
            continue

        # --- 5. Check each episode in the feed ---
        for entry in feed.entries:
            if 'published_parsed' in entry:
                episode_date = parse_date_from_feed(entry.published_parsed)

                # --- 6. Compare dates and log if new and not already in log ---
                if episode_date > monitor_from_date:
                    episode_title = entry.get('title', 'No Title')
                    formatted_date = episode_date.strftime('%y%m%d')
                    log_entry = f"{podcast_name}: {episode_title} - {formatted_date}"
                    if log_entry not in existing_log_entries:
                        new_episodes_found.append(log_entry)
                        print(f"  -> Found new episode: {episode_title}")

    # --- 7. Write all new episodes to the log file ---
    if new_episodes_found:
        print(f"\nFound {len(new_episodes_found)} new episode(s). Logging to {LOG_FILE_PATH}")
        with open(LOG_FILE_PATH, 'a') as log_file:
            for entry in sorted(new_episodes_found): # Sort for consistent order
                log_file.write(entry + '\n')
    else:
        print("\nNo new episodes found.")


if __name__ == "__main__":
    # --- Run the monitor ---
    monitor_podcasts()
