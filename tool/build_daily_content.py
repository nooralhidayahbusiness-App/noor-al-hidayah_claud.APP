#!/usr/bin/env python3
"""Builds assets/data/daily_*.json from trusted public sources.

Needs internet. Run once from the project folder:
    python3 tool/build_daily_content.py
The verse texts come from the Uthmani Quran text of alquran.cloud and the
hadith texts from An-Nawawi's Forty Hadith (hadith-api). Only the verse numbers
below are chosen by hand.
"""
import json
import os
import re
import sys
import urllib.request

QURAN_URL = 'https://api.alquran.cloud/v1/quran/quran-uthmani'
HADITH_URL = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-nawawi.min.json'

# Verse of the day (surah:ayah)
VERSES = """
1:5 1:6 2:45 2:148 2:152 2:153 2:155 2:156 2:186 2:255 2:261 2:286
3:31 3:92 3:103 3:133 3:139 3:159 3:173 3:185 3:200 4:86 4:103 4:110
5:8 5:35 6:17 6:162 7:56 7:180 7:199 8:24 8:46 9:51 9:105 9:129
10:26 10:57 10:62 10:107 11:114 12:87 13:11 13:28 14:7 15:99
16:90 16:97 16:127 16:128 17:36 17:53 17:82 18:46 18:110 19:96
20:82 20:114 20:132 21:107 22:77 25:63 28:77 29:45 29:69 30:21
31:17 31:18 33:41 33:56 33:70 35:10 39:10 39:53 40:60 41:34 42:43
47:7 49:10 49:13 50:16 51:56 53:39 55:60 59:18 63:9 64:11 64:16
65:3 66:6 67:2 73:8 91:9 93:3 93:4 93:5 94:5 94:6 94:7 94:8
99:7 99:8 103:3
""".split()

# Supplications from the Quran (surah:ayah)
DUAS = """
2:128 2:129 2:201 2:250 2:286 3:8 3:16 3:38 3:53 3:147 3:191 3:193 3:194
7:23 7:126 7:151 10:85 12:101 14:40 14:41 17:24 17:80 18:10 20:25 20:26
21:83 21:87 23:29 23:97 23:109 23:118 25:65 25:74 26:83 28:16 28:24
44:12 59:10 60:5 66:11 71:28
""".split()


def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.loads(response.read().decode('utf-8'))


def normalize(text):
    text = re.sub('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]', '', text)
    return text.replace('\u0671', '\u0627')


def clean(surah_number, ayah_number, text):
    """Some editions put the basmalah in front of the first verse: remove it."""
    text = text.strip()
    if ayah_number == 1 and surah_number not in (1, 9):
        words = text.split(' ')
        if normalize(' '.join(words[:4])) == 'بسم الله الرحمن الرحيم':
            text = ' '.join(words[4:]).strip()
    return text


def build(keys, index, max_words=75):
    entries = []
    for key in keys:
        surah_number, ayah_number = (int(x) for x in key.split(':'))
        found = index.get((surah_number, ayah_number))
        if not found:
            print('  WARN: verse not found:', key)
            continue
        surah, ayah = found
        text = clean(surah_number, ayah_number, ayah['text'])
        if len(text.split()) > max_words:
            print('  skipped (too long):', key)
            continue
        entries.append({
            'surah': surah_number,
            'ayah': ayah_number,
            'name': surah['name'],
            'englishName': surah['englishName'],
            'text': text,
        })
    return entries


def looks_like_dua(text):
    words = normalize(text).split()
    return any(w == 'رب' or w == 'ربي' or w.startswith('ربنا') or w.startswith('وربنا') for w in words) or 'سبحانك' in normalize(text) or 'ارحم' in normalize(text)


def main():
    print('Downloading the Quran text ...')
    quran = fetch(QURAN_URL)
    index = {}
    for surah in quran['data']['surahs']:
        for ayah in surah['ayahs']:
            index[(surah['number'], ayah['numberInSurah'])] = (surah, ayah)

    verses = build(VERSES, index)
    duas = build(DUAS, index)
    for d in duas:
        if not looks_like_dua(d['text']):
            print('  CHECK: this may not be a supplication:', d['surah'], ':', d['ayah'])

    print('Downloading the hadith ...')
    hadith_json = fetch(HADITH_URL)
    items = hadith_json.get('hadiths')
    if not items:
        print('Unexpected hadith data. Top-level keys:', list(hadith_json.keys()))
        sys.exit(1)
    hadiths = []
    for item in items:
        text = (item.get('text') or '').strip()
        number = item.get('hadithnumber') or item.get('arabicnumber')
        if text and number:
            hadiths.append({'number': int(float(number)), 'text': text})

    os.makedirs('assets/data', exist_ok=True)
    for name, data in (('daily_verses', verses), ('daily_duas', duas), ('daily_hadith', hadiths)):
        with open('assets/data/' + name + '.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False)

    print('')
    print('Verses :', len(verses))
    print('Duas   :', len(duas))
    print('Hadith :', len(hadiths))
    if verses:
        print('First verse :', verses[0]['name'], verses[0]['ayah'], verses[0]['text'][:40])
    if hadiths:
        print('First hadith:', hadiths[0]['number'], hadiths[0]['text'][:40])
    if len(verses) < 20 or len(duas) < 10 or len(hadiths) < 10:
        print('Something is wrong: too few items.')
        sys.exit(1)
    print('Done.')


main()
