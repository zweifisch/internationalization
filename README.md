# internationalization

[![NPM Version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]

## setup

```javascript
i18n = require('internationalization');

app.use(i18n.middleware({
    directory: path.join(__dirname, 'locales'),
    fallback: "en",
    cookie: "lang" // default is "lang"
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

## client side

```javascript
app.use(i18n.javascript({
    directory: path.join(__dirname, 'locales'),
}));
```

include in html

```html
<script src="/i18n.js"></script>
<script>
console.log(i18n.resource);
console.log(i18n.lang);
</script>
```

more options:

* `cookie` default `lang`
* `path` default `/i18n.js`
* `exportAs` default `i18n`

### angularjs intergartion

```javascript
app.use(i18n.angular({
    directory: path.join(__dirname, 'locales'),
    module: 'i18n',
    service: 'i18n',
    filter: 'translate'
}));
```

include in html

```html
<script src="/path/to/angularjs.js"></script>
<script src="/i18n.js"></script>
```

using filter

```html
<p>{{'delete warning'| translate:resource.name}}</p>
<button>{{'action:delete' | translate}}</button>
```

using service

```javascript
app.directive("", function(i18n)->
    return {
        link: function(){
            console.log(i18n.translate("resource key", {name: "foo"}));
        }
    };
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

[npm-image]: https://img.shields.io/npm/v/internationalization.svg?style=flat
[npm-url]: https://npmjs.org/package/internationalization
[travis-image]: https://img.shields.io/travis/zweifisch/internationalization.svg?style=flat
[travis-url]: https://travis-ci.org/zweifisch/internationalization
