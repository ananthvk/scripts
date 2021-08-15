#!/usr/bin/env python
# This script downloads the most trending 10 wallpapers from a subreddit and saves it to a folder.
"""
Copyright (c) 2021 ShankarCodes. All rights reserved.

You may use, distribute and modify this code under the terms of the 
BSD 3-Clause "New" or "Revised" License.
You should have received a copy of the BSD-3-Clause License with
this file. If not visit https://opensource.org/licenses/BSD-3-Clause

Homepage: https://github.com/ShankarCodes/scripts
"""

# Make sure to create a .env file which contains
# ID=<your app id>
# SECRET=<your app secret>
# NAME=<your username>
# PASSWORD=<your reddit password>
# USER_AGENT=<your user agent, for example MyWallpaperDownloader>

# List of sum subreddits for wallpapers.
# Remove or add your own subreddits here
import grequests
import json
import praw
from dotenv import load_dotenv, find_dotenv
import os
import requests
from mimetypes import MimeTypes

NUMBER_CONCURRENT_CONNECTIONS = 4
SAVE_PATH = 'saves'
subreddits = [
    'SpacePorn',
    'EarthPorn',
    'wallpaper'
    'wallpapers',
    'BotanicalPorn',
    'CityPorn',
    'WeatherPorn',
    'SkyPorn',
    'LakePorn',
    'VillagePorn',
    'BeachPorn',
    'WaterPorn',
]
subreddits = [
    'EarthPorn'
]

# Imports
load_dotenv(find_dotenv())

# Get credentials
client_id = os.environ.get('ID')
secret = os.environ.get('SECRET')
username = os.environ.get('NAME')
password = os.environ.get('PASSWORD')
user_agent = os.environ.get('USER_AGENT')

assert client_id is not None
assert secret is not None
assert username is not None
assert password is not None
assert user_agent is not None

mime = MimeTypes()


def exception_handler(request, exception):
    print('-'*50)
    print(f'Request Failed!')
    print(request)
    print(exception)
    print('-'*50)


class WallpaperDownloader:
    def __init__(self):
        self.reddit = praw.Reddit(client_id=client_id,
                                  client_secret=secret,
                                  password=password,
                                  user_agent=user_agent,
                                  username=username)
        self.cache = {}

    def get_trending_submissions(self, subreddit_name, limit=10):
        return [submission for submission in walldl.reddit.subreddit(subreddit_name).hot(limit=limit) if not submission.is_self]

    def generate_download_list(self, submissions):
        dl_list = []
        for submission in submissions:
            # Check if submission has not yet been downloaded
            if submission.id not in self.cache:
                typ = mime.guess_type(submission.url)[0]
                if typ is not None:
                    if typ.startswith('image'):
                        # Add the extension to the list.
                        dl_list += [(submission, typ.split('/')[-1])]
                    else:
                        print(
                            f'Unknown type for submission url: {submission.url}')
                else:
                    print(f'Unknown type for submission url: {submission.url}')
        return dl_list

    def download(self, url_list):
        all_requests = (grequests.get(u[0].url) for u in url_list)

        responses = grequests.map(all_requests, size=NUMBER_CONCURRENT_CONNECTIONS,
                                  exception_handler=exception_handler)
        for dl_tuple, response in zip(url_list, responses):
            submission = dl_tuple[0]
            extension = dl_tuple[1]
            with open(os.path.join(SAVE_PATH, f'{submission.title}.{extension}'), 'wb') as save_file:
                save_file.write(response.content)


walldl = WallpaperDownloader()
submissions = walldl.get_trending_submissions(subreddits[0])
dl_list = walldl.generate_download_list(submissions)
walldl.download(dl_list)
