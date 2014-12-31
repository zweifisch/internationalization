url = require 'url'
pth = require 'path'
{getInstance} = require "./translator"

bundle = (resource, lang, exportAs)->
    """
    ;var #{exportAs} = {};
    (function() {
        var resource = #{JSON.stringify resource};
        #{exportAs}.translate = function(key, ns) {
            if (ns) {
                return resource[ns][key];
            } else {
                return resource[key];
            }
        };
        #{exportAs}.resource = resource;
        #{exportAs}.lang = '#{lang}';
    })();
    """

middleware = ({directory, cookie, path, exportAs})->
    path ?= '/i18n.js'
    cookie ?= 'lang'
    exportAs ?= 'i18n'
    translator = getInstance()
    translator.load directory
    (req, res, next)->
        {pathname} = url.parse req.url
        if req.method is 'GET' and pathname is path
            lang = req.cookies[cookie]
            try
                res.end bundle translator.langs[lang], lang, exportAs
            catch e
                debug e
                res.write ';console.error(' + JSON.stringify(e.toString()) + ');'
                res.end()
        else
            next()

module.exports =
    middleware: middleware
    bundle: bundle
