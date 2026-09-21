#!/usr/bin/env python3
"""Builds assets/data/quran.json (the whole Quran) from alquran.cloud.

Needs internet. Run once from the project folder:
    python3 tool/build_quran_data.py

Editions:
  quran-uthmani : Uthmani script (default reading text)
  quran-simple  : simple vowelled script (the "simple font" button)
  en.sahih      : English translation (Saheeh International)
Change TRANSLATION below to use another English translation.
Check the license of every text before publishing the app.
"""
import json
import os
import re
import sys
import time
import urllib.request

BASE = 'https://api.alquran.cloud/v1/quran/'
UTHMANI = 'quran-uthmani'
SIMPLE = 'quran-simple'
TRANSLATION = 'en.sahih'


def fetch(edition):
    url = BASE + edition
    last_error = None
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(request, timeout=180) as response:
                payload = json.loads(response.read().decode('utf-8'))
            return payload['data']['surahs']
        except Exception as error:
            last_error = error
            print('  retry', attempt + 1, '-', error)
            time.sleep(3)
    print('Could not download', edition, ':', last_error)
    sys.exit(1)


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


def main():
    print('Downloading Uthmani text ...')
    uthmani = fetch(UTHMANI)
    print('Downloading simple text ...')
    simple = fetch(SIMPLE)
    print('Downloading English translation ...')
    translation = fetch(TRANSLATION)

    if not (len(uthmani) == len(simple) == len(translation) == 114):
        print('Unexpected number of surahs:', len(uthmani), len(simple), len(translation))
        sys.exit(1)

    surahs = []
    total = 0
    different = 0
    for u, s, t in zip(uthmani, simple, translation):
        n = u['number']
        assert s['number'] == n and t['number'] == n, 'surah order mismatch'
        assert len(u['ayahs']) == len(s['ayahs']) == len(t['ayahs']), 'ayah count mismatch in surah %d' % n
        ayahs = []
        for a, b, c in zip(u['ayahs'], s['ayahs'], t['ayahs']):
            i = a['numberInSurah']
            uth = clean(n, i, a['text'])
            sim = clean(n, i, b['text'])
            if uth != sim:
                different += 1
            ayahs.append({
                'i': i,
                'u': uth,
                's': sim,
                't': c['text'].strip(),
                'p': a.get('page', 0),
                'j': a.get('juz', 0),
            })
        total += len(ayahs)
        surahs.append({
            'n': n,
            'ar': u['name'],
            'en': u['englishName'],
            'mean': u.get('englishNameTranslation', ''),
            'type': u.get('revelationType', ''),
            'count': len(ayahs),
            'ayahs': ayahs,
        })

    if total != 6236:
        print('Unexpected number of verses:', total, '(expected 6236)')
        sys.exit(1)

    os.makedirs('assets/data', exist_ok=True)
    with open('assets/data/quran.json', 'w', encoding='utf-8') as f:
        json.dump({'surahs': surahs}, f, ensure_ascii=False, separators=(',', ':'))

    sample = surahs[0]['ayahs'][1]
    harakat = len(re.findall('[\u064B-\u0652]', sample['s']))
    print('')
    print('Surahs :', len(surahs))
    print('Verses :', total)
    print('Verses where simple differs from Uthmani:', different)
    print('Harakat found in the simple sample:', harakat, '(should be more than 0)')
    print('Sample Uthmani :', sample['u'])
    print('Sample simple  :', sample['s'])
    print('Sample English :', sample['t'])
    print('File size      : %.1f MB' % (os.path.getsize('assets/data/quran.json') / 1048576))
    print('Done.')


main()
