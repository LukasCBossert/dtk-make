dtk-make-bossert
===

[![CircleCI](https://circleci.com/gh/lukascbossert/dtk-make.svg?style=svg)](https://circleci.com/gh/LukasCBossert/dtk-make)

Dies ist ein Repositorium, bei dem es vor allem um die `makefile` geht.

Um die `makefile` zu nutzen, tippe im Terminal ein:

```
make <ZIEL>
```

Folgende Ziele sind definiert:

- `article`: Erstelle nur den Artikel
- `minimize`: Erstelle eine komprimierte PDF
- `count.colorpages`: Zähle Seiten mit Farbe und erstelle eine CSV
- `zip`: Erstelle eine zip-Datei mit den notwendigen Dateien plus PDF

Wird kein konkretes `<ZIELE>` eingegeben, werde alle definierten `<ZIELE>` ausgeführt.
