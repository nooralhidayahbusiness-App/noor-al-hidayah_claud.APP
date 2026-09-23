import json
import urllib.request

url = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions.min.json'
request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(request, timeout=120) as response:
    editions = json.loads(response.read().decode('utf-8'))

items = editions.items() if isinstance(editions, dict) else enumerate(editions)
found = 0
for key, value in items:
    blob = json.dumps({'key': key, 'value': value}, ensure_ascii=False)
    if 'riyad' in blob.lower():
        found += 1
        print('----')
        print(blob[:400])

print('')
print('Total matches found:', found)
