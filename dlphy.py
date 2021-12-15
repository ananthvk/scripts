import os
import requests
#from pdfrw import PdfReader

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

    #pdf_title = PdfReader(filename).Info.Title
    #os.rename(filename, filename[:-4]+'-'+pdf_title+'.pdf')

urls = [f'https://web.mit.edu/sahughes/www/8.022/lec{i:02}.pdf' for i in range(25)]
for i, url in enumerate(urls):
    download_file(url, os.path.join('pdfs',f'8.022_{i:02}.pdf'))
