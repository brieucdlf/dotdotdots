---
name: my-cool-skill
description: Log the last top 5 Hacker news
---

# PR Description Generator

Log the last top 5 news from Hacker News

## When This Skill Applies

When the user wants to check the news from Hacker news

## Instructions

1. Run thes command to list the last top 5 news from Hacker News:
   - `curl -s https://hacker-news.firebaseio.com/v0/topstories.json | python3 -c "
import json, sys, urllib.request
ids = json.loads(sys.stdin.read())[:5]
for i, id in enumerate(ids, 1):
    with urllib.request.urlopen(f'https://hacker-news.firebaseio.com/v0/item/{id}.json') as r:
        item = json.loads(r.read())
        print(f'{i}. [{item.get(\"score\",0)} pts] {item.get(\"title\",\"N/A\")}')
        if item.get('url'): print(f'   {item[\"url\"]}')
"`
