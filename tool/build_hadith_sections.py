#!/usr/bin/env python3
"""Builds assets/data/hadith_sections.json from Sahih al-Bukhari, grouping
real book numbers (metadata.sections / reference.book) into topics.
Source: the free hadith-api project (via jsDelivr).
Check the license before publishing the app.
Run: python3 tool/build_hadith_sections.py
"""
import json
import os
import time
import urllib.request

ROOT = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/'

# id -> (Arabic name, English name, set of Bukhari book numbers)
SECTIONS = [
    ('fasting', 'الصيام', 'Fasting', {30}),
    ('ramadan', 'رمضان وقيام الليل', 'Ramadan & Night Prayer', {31, 32, 33}),
    ('eid', 'الأعياد', 'Eid', {13, 73}),
    ('jihad', 'الجهاد والغزوات', 'Jihad & Campaigns', {56, 57, 64}),
    ('rulings', 'الحدود والأحكام', 'Legal Rulings & Limits', {86, 87, 90}),
    ('manners', 'الآداب وتهذيب النفس', 'Manners & Etiquette', {78, 79, 81}),
]


def fetch(url):
    last = None
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(request, timeout=180) as response:
                return json.loads(response.read().decode('utf-8'))
        except Exception as error:
            last = error
            time.sleep(2)
    raise RuntimeError('%s : %s' % (url, last))


def main():
    print('Downloading Arabic Sahih al-Bukhari ...')
    ar = fetch(ROOT + 'ara-bukhari.min.json')
    print('Downloading English Sahih al-Bukhari ...')
    en = fetch(ROOT + 'eng-bukhari.min.json')

    ar_hadiths = ar['hadiths']
    en_hadiths = en['hadiths']
    book_names = ar['metadata']['sections']  # {"30": "Fasting", ...}

    en_lookup = {}
    for h in en_hadiths:
        ref = h.get('reference') or {}
        key = (ref.get('book'), ref.get('hadith'))
        en_lookup[key] = h.get('text', '')

    sections = {sid: [] for sid, _, _, _ in SECTIONS}
    for h in ar_hadiths:
        ref = h.get('reference') or {}
        book = ref.get('book')
        text_ar = (h.get('text') or '').strip()
        if not text_ar or book is None:
            continue
        for sid, _, _, book_set in SECTIONS:
            if book in book_set:
                text_en = en_lookup.get((book, ref.get('hadith')), '')
                sections[sid].append({
                    'ar': text_ar,
                    'en': text_en,
                    'chapter': book_names.get(str(book), ''),
                    'number': h.get('hadithnumber'),
                })
                break

    out = {
        'sections': [
            {'id': sid, 'nameAr': name_ar, 'nameEn': name_en, 'hadiths': sections[sid]}
            for sid, name_ar, name_en, _ in SECTIONS
        ]
    }
    os.makedirs('assets/data', exist_ok=True)
    with open('assets/data/hadith_sections.json', 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, separators=(',', ':'))

    print('')
    for sid, name_ar, _, _ in SECTIONS:
        print('%-10s %-28s : %d hadith' % (sid, name_ar, len(sections[sid])))
    print('File size: %.1f KB' % (os.path.getsize('assets/data/hadith_sections.json') / 1024))
    total = sum(len(v) for v in sections.values())
    if total < 20:
        print('Very few hadiths matched — something is off.')
        raise SystemExit(1)
    print('Done. Review the counts above before publishing.')


main()
