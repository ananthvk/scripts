#!/usr/bin/env python
# This scripts sets the wallpaper from saves folder
# located at the location of the file.
# further modifications to accept custom path has to be done.
"""
Copyright (c) 2021 ShankarCodes. All rights reserved.

You may use, distribute and modify this code under the terms of the
BSD 3-Clause "New" or "Revised" License.
You should have received a copy of the BSD-3-Clause License with
this file. If not visit https://opensource.org/licenses/BSD-3-Clause

Homepage: https://github.com/ShankarCodes/scripts
"""
import sys
import time
from pathlib import Path
from change_background import change_wallpaper
import random
import os
IMG_PATH = (os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'saves'))
# Change wallpaper every x seconds.
if len(sys.argv) >= 2:
    CHANGE_FREQUENCY = int(sys.argv[1])
else:
    CHANGE_FREQUENCY = 5

def get_files():
    filepaths = sorted(Path(IMG_PATH).iterdir(), key=os.path.getmtime)
    return filepaths

files = get_files()


def set_new_wallpaper():
    print('Changing wallpaper')
    # Gets the most recent wallpapers
    filepath = files.pop()
    if filepath.is_file():
        if str(filepath).endswith('json'):
            return False
        change_wallpaper(str(filepath.resolve()))
        print('New wallpaper:'+str(filepath))
        return True
    print('Invalid file path, not a file')
    print(filepath)
    return False


while True:
    st = set_new_wallpaper()
    if len(files) == 0:
        print('Recycling...')
        files = get_files()
    if st:
        time.sleep(CHANGE_FREQUENCY)
