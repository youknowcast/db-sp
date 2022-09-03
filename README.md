# db-sp

setup

pre-requirement: [ridgepole](https://github.com/ridgepole/ridgepole)

```
% gem install ridgepole
% bundle install
```

apply schema

```
% ridgepole -c config.yml -f Schemafile -a
```

db

```
% sqlite3 db.sqlite3
```
