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

files = os.listdir(IMG_PATH)


def set_new_wallpaper():
    print('Changing wallpaper')
    random.shuffle(files)
    newpath = files.pop()
    filepath = os.path.join(IMG_PATH, newpath)
    if os.path.isfile(filepath):
        change_wallpaper(filepath)
        print('New wallpaper:'+filepath)
    else:
        print('Invalid file path, not a file')
        print(filepath)


while True:
    set_new_wallpaper()
    if len(files) == 0:
        # If all current files are used, download wallpapers again.
        allfiles = os.listdir(IMG_PATH)
        for fil in allfiles:
            if not fil.endswith('json') and os.path.isfile(fil):
                print('Moving file')
                os.rename(fil, os.path.join('old', fil))
        '''
        print('Downloading wallpapers...')
        download_wallpapers()
        print('-'*50)
        files = os.listdir('saves')
        if len(files) <= 5:
            # All files have been consumed!
            print('Recycling as no new wallpapers')
            files = files + os.listdir(os.path.join(IMG_PATH, 'old'))
        '''
        files = os.listdir(IMG_PATH)
    time.sleep(CHANGE_FREQUENCY)
