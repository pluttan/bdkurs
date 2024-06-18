# -*- coding: utf-8 -*-
import requests
from time import time, sleep


def parse(i):
    """Function for parsing images from thispersondoesnotexist.com"""
    URL = "https://thispersondoesnotexist.com/"

    headers = {
        "Host": "thispersondoesnotexist.com",
        "User-Agent": r"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0",
        "Accept": r"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": r"en,en-US;q=0.5",
        "Accept-Encoding": "gzip, deflate, br",
        "DNT": "1",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
        "Cache-Control": r"max-age=0",
        "TE": "Trailers",
    }
    r = requests.get(URL, headers=headers, stream=True)

    jpg_file = "{}.jpeg".format(str(i))
    with open(jpg_file, "wb") as f:
        f.write(r.content)
        f.close()


if __name__ == "__main__":
    for i in range(1000):
        parse(i+1)
        sleep(0.05)
        print(i)
