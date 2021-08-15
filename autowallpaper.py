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
import time
from change_background import change_wallpaper
import random
import os
IMG_PATH = (os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'saves'))
# Change wallpaper every x seconds.
CHANGE_FREQUENCY = 60

files = os.listdir(IMG_PATH)


def set_new_wallpaper():
    print('Changing wallpaper')
    random.shuffle(files)
    newpath = files.pop()
    filepath = os.path.join(IMG_PATH, newpath)
    print('New wallpaper:'+filepath)
    change_wallpaper(filepath)


while True:
    set_new_wallpaper()
    if len(files) == 0:
        files = os.listdir('saves')
        print('Reusing ..... cycling files again')
        print('-'*50)
    time.sleep(CHANGE_FREQUENCY)
