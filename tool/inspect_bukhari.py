import json
import urllib.request

ROOT = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/'

def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.loads(response.read().decode('utf-8'))

editions = fetch(ROOT + 'editions.min.json')
items = editions.items() if isinstance(editions, dict) else enumerate(editions)

candidates = []
for key, value in items:
    blob = json.dumps({'key': key, 'value': value}, ensure_ascii=False)
    if 'bukhari' in blob.lower():
        candidates.append((key, value))

print('Bukhari-related entries:', len(candidates))
for key, value in candidates[:15]:
    print(' -', key, '|', json.dumps(value, ensure_ascii=False)[:200])

# Try downloading the first Arabic one and show its real structure.
ar_name = None
for key, value in candidates:
    name = value.get('name') if isinstance(value, dict) else key
    if str(name).lower().startswith('ara'):
        ar_name = name
        break

if ar_name:
    print('')
    print('Fetching sample from:', ar_name)
    data = fetch(ROOT + 'editions/' + ar_name + '.min.json')
    hadiths = data.get('hadiths') if isinstance(data, dict) else data
    print('Top-level keys:', list(data.keys()) if isinstance(data, dict) else type(data))
    print('Hadith count:', len(hadiths))
    print('First hadith full content:')
    print(json.dumps(hadiths[0], ensure_ascii=False, indent=2)[:1500])
else:
    print('No Arabic Bukhari edition name found automatically.')
