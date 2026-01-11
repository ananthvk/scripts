#!/usr/bin/env python3
"""
Copyright (c) 2021 ananthv. All rights reserved.

You may use, distribute and modify this code under the terms of the 
BSD 3-Clause "New" or "Revised" License.
You should have received a copy of the BSD-3-Clause License with
this file. If not visit https://opensource.org/licenses/BSD-3-Clause

cleandir.py - A script for cleaning a directory by moving related
type of files to separate folders.

Homepage: https://github.com/ananthvk/scripts
"""

# Extensions have to be space separated
import shutil
from pathlib import Path
import sys
import os
import argparse

extensions = '''ebook:epub mobi azw azw3 iba djvu azw4 azw6 cbr cbz azw1
document:txt rtf md doc docx log odt rst tex wpd wps pdf
spreadsheet:xls xlsx ods csv ics vcf tsv
archive:7z a apk ar bz2 cab cpio deb dmg egg gz iso jar lha mar pea rar rpm s7z shar tar tbz2 tgz tlz war whl xpi zip zipx xz pak
executable: exe msi bin command com sh bat crx cpl dll
image:3dm 3ds max bmp dds gif jpg jpeg png psd xcf tga thm tif tiff yuv ai eps ps svg dwg dxf gpx kml kmz webp
video:3g2 3gp aaf asf avchd avi drc flv m2v m4p m4v mkv mng mov mp2 mp4 mpe mpeg mpg mpv mxf nsv ogg ogv ogm qt rm rmvb roq srt svi vob webm wmv yuv
audio:aac aiff ape au flac gsm it m3u m4a mid mod mp3 mpa pls ra s3m sid wav wma xm
code:c cc class clj cpp cs cxx el go h java lua m m4 php pl po py rb rs sh swift vb vcxproj xcodeproj xml diff patch html js json
web:html htm css js jsx less scss wasm php
font:eot otf ttf woff woff2
slide:ppt odp pptx'''


def parse_extensions(ext):
    """
    Parse the extensions as given in the format and convert it into a dictionary.
    <category>:<ext1> <ext2> <ext3> ....

    Args:
        ext (str): A string containing the extensions as the format given in the top of this file.

    Returns:
        dict: A dictionary representing the extensions with the key being the category
            and the value, a list containing all extensions as str.
    """
    extensions_map = {}
    for line in ext.split('\n'):
        try:
            category, extensions_list = line.split(':')
            extensions_list = extensions_list.split()
            extensions_list = list(
                filter(lambda x: x != '' or x != ' ', extensions_list))
            extensions_map[category] = extensions_list
        except Exception as e:
            print(e)
            print('WARNING: ERRORS WHILE READING EXTENSION LIST')
    return extensions_map


def get_category(extension, extension_map):
    """
    Gets the category of the extension like (ebook for a pdf file).
    Note: The extension must not start with a '.'

    Args:
        extension (str): String for which the category has to be found.
        extension_map (dict): A dictionary containing the category as the key, value is list of extensions.

    Returns:
        str: Returns a string which is the category of the given extension.
    """
    for category, extension_list in extension_map.items():
        if extension in extension_list:
            return category
    return ''


def get_files(path, recurse):
    """
    Lists all the files in a directory.
    Args:
        path (str): absolute path of the required directory to get files.
        recurse (bool): list all files by recursing through each subfolder or not.

    Yields:
        str: a single file name, if no files are left, yields a ''
    """
    files = None
    entries = []
    if path.exists():
        entries = path.glob('**/*' if recurse else '*')
    else:
        print(f'The given input path ({path}) does not exist')
        yield ''
    for entry in entries:
        if entry.is_file():
            yield os.path.abspath(str(entry))
    yield ''


def remove_prefix(string, prefix):
    if string.startswith(prefix):
        return string[len(prefix):]
    return string


def short(path):
    return remove_prefix(str(path), str(Path.cwd()) + '\\')


if __name__ == '__main__':
    """
    Main function of the program
    """
    parser = argparse.ArgumentParser(
        description="Cleans a directory by copying related extensions to folders",
        epilog="Do not try to clean application folder directories as files can get mixed up",
    )
    parser.add_argument('input_path', metavar='path', type=str,
                        help='the path to the directory to be cleaned')
    parser.add_argument('output_path', metavar='outpath', type=str,
                        help='path to store the directory structure after cleaning')
    parser.add_argument('-V', '--version', action='version')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='turns verbose mode on')
    parser.add_argument('-r', '--recursive', action='store_true',
                        help='recursively copies or moves files (DANGEROUS if used in application folders)')
    parser.add_argument('-m', '--move', action='store_true',
                        help='moves files instead of copying (default is copying)')
    parser.version = 'Shankar directory cleaning script v1.0.1'
    args = parser.parse_args()

    input_path = args.input_path
    out_path = args.output_path
    should_move = args.move
    is_recursive = args.recursive
    is_verbose = args.verbose

    # Create the extension map.
    ext_map = parse_extensions(extensions)
    errors = {}

    clean_path = Path(input_path)
    output_path = Path(out_path)

    # If the paths are not absolute, convert them to absolute.
    if not clean_path.is_absolute():
        clean_path = Path.cwd() / input_path
    if not output_path.is_absolute():
        output_path = Path.cwd() / out_path

    for path in get_files(clean_path, is_recursive):
        # Find out the extension and then find out the category to which the file belongs.
        extension = Path(path).suffix[1:].lower()
        category = get_category(extension, ext_map)
        if category == '':
            # The category of that extension has not been found.
            # Keep it as misc
            # category = 'misc'
            continue
        if category.strip() != '' or category.strip() != ' ':
            try:
                if os.path.isfile(str(clean_path / out_path)):
                    # If a file of the same name exists, directory creation will fail
                    # so ask the user to remove it.
                    print('Cannot create the output folder: '+out_path)
                    print(
                        'Please check if a file by the same name exists, and delete it.')
                    break
                target_path = output_path / (category+'s')
            except Exception as e:
                # Any other error has occured while creating output directory.
                print('Error occured while creating output directory')
                print('Check if a file by the same name exists')
                break
            target_path.mkdir(parents=True, exist_ok=True)
            if is_verbose:
                print("Moving" if should_move else "Copying",
                      short(path), '=>', short(target_path))
            try:
                # Move the folder to the target folder
                if should_move:
                    shutil.move(path, target_path)
                else:
                    shutil.copy2(path, target_path)
            except shutil.Error as e:
                errors[f'{"Moving" if should_move else "Copying"} {short(path)} => {short(target_path)}:'] = str(
                    e)
            except Exception as e:
                errors[f'{"Moving" if should_move else "Copying"} {short(path)} => {short(target_path)}:'] = str(
                    e)
    if len(errors.keys()) > 0:
        print()
        print('='*5+' ERRORS '+'='*5)
        print()
        for incident, error in errors.items():
            print(incident, '-', error)
        print()
