#!/usr/bin/env python3
# A script to download ncert textbooks from commandline
"""
Copyright (c) 2021 ShankarCodes. All rights reserved.

You may use, distribute and modify this code under the terms of the 
BSD 3-Clause "New" or "Revised" License.
You should have received a copy of the BSD-3-Clause License with
this file. If not visit https://opensource.org/licenses/BSD-3-Clause

Homepage: https://github.com/ShankarCodes/scripts
"""

import sys
import os
import requests
import traceback
from pdfrw import PdfReader

try:
    import pyperclip
except Exception as e:
    # pyperclip not found so prepare a mock for it
    class PyperclipMock:
        def copy(self, fake_str):
            pass
    pyperclip = PyperclipMock()


def generate_url(std, sub, part, chno):

    # Generate the URL according to the below pattern.
    # https://ncert.nic.in/textbook/pdf/<standard as (a-z)>e<subject code><part>*100+chno.pdf
    # Examples:
    # https://ncert.nic.in/textbook/pdf/lemh102.pdf
    # This is class 12 maths chapter 2.
    # Say it is part 2 and chapter 3.
    # Code is 2*100 = 200 + 3 = 203.

    return f'https://ncert.nic.in/textbook/pdf/{chr(ord("a") + int(std) - 1)}e{sub}{(int(part)*100)+int(chno)}.pdf'


def generate_filename(std, sub, part, chno):
    return f'class-{std}-{sub}-{part}-{chno}.pdf'


def display_copy(url):
    pyperclip.copy(url)
    print(f'URL:{url}')
    print('Copied to clipboard')


def download_file(url, filename):
    response = requests.get(url)
    if not response.ok:
        print(f'Unable to download file {url}')
    # To remove contents of file if it has been opened.
    with open(filename, 'wb') as fil:
        pass
    with open(filename, 'ab') as fil:
        for chunk in response.iter_content(4096):
            fil.write(chunk)

    pdf_title = PdfReader(filename).Info.Title
    os.rename(filename, filename[:-4]+'-'+pdf_title+'.pdf')


def main_no_argv():
    standard = input('>>Enter class (1 - 12):')
    subject = input('''>>Enter 2 letter code for subject.
    Example: Science -> sc
    Physics -> ph
    Chemistry->ch
    Maths->mh
    >>Subject code:''')
    part = input('>>Enter part(Part 1 or 2, blank for 1:')
    if part == '':
        part = '1'
    chno = input('>>Enter the chapter_number:')

    # We have got all the details now.
    url = generate_url(standard, subject, part, chno)
    display_copy(url)
    download_file(url, generate_filename(standard, subject, part, chno))


def main_argv():
    if not (len(sys.argv) == 5 or len(sys.argv) == 6):
        print('Usage ncert_dl <class> <subject 2 letter code> <part> <chapter number start> | <chapter number end>')
        return False
    elif len(sys.argv) == 5:
        url = generate_url(*sys.argv[1:])
        display_copy(url)
        download_file(url, generate_filename(*sys.argv[1:]))
    else:
        for i in range(int(sys.argv[4]), int(sys.argv[5])+1, 1):
            try:
                url = generate_url(sys.argv[1], sys.argv[2], sys.argv[3], i)
                display_copy(url)
                download_file(url, generate_filename(
                    sys.argv[1], sys.argv[2], sys.argv[3], i))
            except Exception as e:
                print('An error occured!')
                traceback.print_exc()
                print('Continuing')


if __name__ == '__main__':
    main_argv()
