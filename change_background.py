#!/usr/bin/env python3
# This script changes the desktop wallpaper in windows
"""
Copyright (c) 2021 ShankarCodes. All rights reserved.

You may use, distribute and modify this code under the terms of the 
BSD 3-Clause "New" or "Revised" License.
You should have received a copy of the BSD-3-Clause License with
this file. If not visit https://opensource.org/licenses/BSD-3-Clause

Homepage: https://github.com/ShankarCodes/scripts
"""
import ctypes
import sys
import os


def change_wallpaper(wallpaper_path):
    ctypes.windll.user32.SystemParametersInfoW(20, 0, wallpaper_path, 0)


def main():
    if len(sys.argv) > 1:
        # Checks if arguments are passed.
        pth = sys.argv[1]
        if os.path.isabs(pth):
            # If the path is absolute, directly change the wallpaper.
            change_wallpaper(pth)
        else:
            # If the path is not absolute, append the given path with the current path.
            pth = os.path.join(os.getcwd(), pth)
            change_wallpaper(pth)
    else:
        print("Invalid usage. Usage change_background.py <Filename>")
        print("Or cbg <filename>")


if __name__ == '__main__':
    main()
