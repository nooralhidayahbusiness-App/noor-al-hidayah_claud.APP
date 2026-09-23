import json
import urllib.request

ROOT = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/'

def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(request, timeout=180) as response:
        return json.loads(response.read().decode('utf-8'))

editions = fetch(ROOT + 'editions.min.json')
bukhari_entry = editions.get('bukhari') if isinstance(editions, dict) else None
print('=== Full collection list for "bukhari" ===')
print(json.dumps(bukhari_entry, ensure_ascii=False, indent=2))

print('')
print('=== Downloading editions/ara-bukhari.min.json ===')
ar = fetch(ROOT + 'editions/ara-bukhari.min.json')
print('Top-level keys:', list(ar.keys()) if isinstance(ar, dict) else type(ar))
if isinstance(ar, dict) and 'metadata' in ar:
    print('')
    print('=== metadata (full) ===')
    print(json.dumps(ar['metadata'], ensure_ascii=False, indent=2)[:4000])
hadiths = ar.get('hadiths') if isinstance(ar, dict) else ar
print('')
print('Hadith count:', len(hadiths))
print('=== First hadith (full) ===')
print(json.dumps(hadiths[0], ensure_ascii=False, indent=2))
print('')
print('=== A later hadith, e.g. index 500 (full) ===')
print(json.dumps(hadiths[500], ensure_ascii=False, indent=2))
