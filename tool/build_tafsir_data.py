#!/usr/bin/env python3
"""Builds assets/data/tafsir.json (a tafsir for every verse).

Needs internet and assets/data/quran.json (run tool/build_quran_data.py first).
Run once from the project folder:
    python3 tool/build_tafsir_data.py
Arabic: Tafsir Al-Muyassar.  English: Tafsir Al-Jalalayn.
Source: the free spa5k/tafsir_api project (via the jsDelivr CDN).
Check the license of each tafsir before publishing the app.
"""
import html
import json
import os
import re
import sys
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir/'
AR_LABEL = 'التفسير الميسر'
EN_LABEL = 'Tafsir al-Jalalayn'


def fetch(url):
    last = None
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(request, timeout=120) as response:
                return json.loads(response.read().decode('utf-8'))
        except Exception as error:
            last = error
            time.sleep(2)
    raise RuntimeError('%s : %s' % (url, last))


def find_edition(editions, needle, prefix):
    for e in editions:
        if not isinstance(e, dict):
            continue
        slug = str(e.get('slug', ''))
        blob = json.dumps(e, ensure_ascii=False).lower()
        if slug.lower().startswith(prefix) and needle in blob:
            return slug
    return None


def clean(text):
    text = re.sub(r'(?i)<br\s*/?>|</p>|</div>', '\n', text or '')
    text = re.sub(r'<[^>]+>', '', text)
    text = html.unescape(text)
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\s*\n\s*', '\n', text)
    return text.strip()


def parse_surah(payload, count, surah_number):
    items = None
    if isinstance(payload, dict):
        items = payload.get('ayahs') or payload.get('verses') or payload.get('data')
    elif isinstance(payload, list):
        items = payload
    if not isinstance(items, list):
        keys = list(payload.keys())[:8] if isinstance(payload, dict) else type(payload)
        raise ValueError('Unexpected data shape in surah %d: %s' % (surah_number, keys))
    texts = [''] * count
    for item in items:
        if not isinstance(item, dict):
            continue
        number = item.get('ayah') or item.get('ayah_number') or item.get('verse_number') or item.get('number')
        if number is None:
            continue
        number = int(number)
        if 1 <= number <= count:
            texts[number - 1] = clean(item.get('text') or '')
    return texts


def load_edition(slug, counts):
    def job(n):
        payload = fetch('%s%s/%d.json' % (BASE, slug, n))
        return parse_surah(payload, counts[n - 1], n)

    with ThreadPoolExecutor(max_workers=8) as pool:
        return list(pool.map(job, range(1, 115)))


def stats(surahs):
    total = sum(len(s) for s in surahs)
    filled = sum(1 for s in surahs for t in s if t)
    return total, filled


def main():
    if not os.path.exists('assets/data/quran.json'):
        print('assets/data/quran.json is missing. Run tool/build_quran_data.py first.')
        sys.exit(1)
    with open('assets/data/quran.json', encoding='utf-8') as f:
        quran = json.load(f)
    counts = [s['count'] for s in quran['surahs']]
    if len(counts) != 114:
        print('quran.json looks incomplete.')
        sys.exit(1)

    print('Reading the list of tafsirs ...')
    editions = fetch(BASE + 'editions.json')
    if isinstance(editions, dict):
        editions = editions.get('editions') or list(editions.values())
    print('Tafsirs available:', len(editions))

    ar_slug = find_edition(editions, 'muyassar', 'ar')
    en_slug = find_edition(editions, 'jalalayn', 'en')
    if not ar_slug or not en_slug:
        print('Could not find the wanted tafsirs. Arabic / English slugs found:', ar_slug, en_slug)
        slugs = [str(e.get('slug', '')) for e in editions if isinstance(e, dict)]
        print('Arabic slugs :', [s for s in slugs if s.startswith('ar')])
        print('English slugs:', [s for s in slugs if s.startswith('en')])
        sys.exit(1)
    print('Arabic tafsir :', ar_slug)
    print('English tafsir:', en_slug)

    print('Downloading the Arabic tafsir (114 surahs) ...')
    ar = load_edition(ar_slug, counts)
    print('Downloading the English tafsir (114 surahs) ...')
    en = load_edition(en_slug, counts)

    out = {
        'ar': {'name': AR_LABEL, 'slug': ar_slug, 'surahs': ar},
        'en': {'name': EN_LABEL, 'slug': en_slug, 'surahs': en},
    }
    os.makedirs('assets/data', exist_ok=True)
    with open('assets/data/tafsir.json', 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, separators=(',', ':'))

    ar_total, ar_filled = stats(ar)
    en_total, en_filled = stats(en)
    print('')
    print('Arabic : %d verses, %d with their own tafsir (%d shared)' % (ar_total, ar_filled, ar_total - ar_filled))
    print('English: %d verses, %d with their own tafsir (%d shared)' % (en_total, en_filled, en_total - en_filled))
    print('Sample Arabic  1:2 :', ar[0][1][:70])
    print('Sample English 1:2 :', en[0][1][:70])
    print('File size: %.1f MB' % (os.path.getsize('assets/data/tafsir.json') / 1048576))
    if ar_total != 6236 or en_total != 6236 or ar_filled < 3000 or en_filled < 3000:
        print('Something is wrong: too few tafsir entries.')
        sys.exit(1)
    print('Done.')


main()
