### Useful commands

Display indexes
```zsh
curl http://localhost:9200/_aliases?pretty=true
```

Remove specific index
```zsh
curl -XDELETE localhost:9200/<index_name>
```
