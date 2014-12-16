# internationalization

## setup

```javascript
i18n = require('internationalization');

app.use(i18n.middleware({
    directory: path.join(__dirname, 'locales')
}));
```

directory layout

files under then same directory will be merged(file name does not matter)

```
locales
├── en
│   ├── foo.ini
│   └── bar.ini
└── zh
    └── index.ini
```

## usage

```jade
span= _("Hello {username}", {username: username})
span= _("Hello {1}", username)
input(placeholder=_("Password") type="password")
```

```ini
Hello {username} = Guten Tag {username}
Hello {1} = Guten Tag {1}
Password = Passwort
```

### namespace

```jade
span= _("profile:Hello {username}", {username: username})
```

```ini
[profile]
Hello {username} = Guten Tag {username}
```

## generate/update language files(TBD)

```javascript
directory: 'locales'
views: 'views/**.jade'
```

grunt i18n will scan the view direcotry for `_()` and `__()`

```sh
$ grunt i18n de
```
