url = require 'url'
pth = require 'path'
fs = require 'fs'
{getInstance} = require './translator'
debug = (require 'debug') 'i18n'

TemplateSource = fs.readFileSync pth.join __dirname, 'template.js'

translate = (key, vars...)->
    return "" unless key
    idx = key.indexOf nsSeparator
    if idx isnt -1
        template = resource[key.substr 0, idx]?[key.substr idx+1] or key.substr idx+1
    else
        template = resource[key]
        if "string" isnt typeof template
            template = resource[defaultNs]?[key] or key
    if not vars.length
        return template

    template = new Template template

    if 'object' is typeof vars[0]
        template.render vars[0], vars[1..]
    else
        template.render null, vars...

bundle = ({resource, lang, nsSeparator, module, filter, service, defaultNs})->
    """
    (function() {
        var __slice = [].slice;
        var nsSeparator = '#{nsSeparator}';
        var defaultNs = '#{defaultNs}';
        var resource = #{JSON.stringify resource};
        var Template = #{TemplateSource};
        var translate = #{translate.toString()};
        angular.module('#{module}', [])
        .factory('#{service}', function(){
            return {
                lang: '#{lang}',
                translate: translate,
                resource: resource
            };
        })
        .filter('#{filter}', function(){
            return translate;
        });
    })();
    """

middleware = ({directory, cookie, path, nsSeparator, module, service, filter, defaultNs})->
    path ?= '/i18n-angular.js'
    cookie ?= 'lang'
    nsSeparator ?= ':'
    module ?= 'i18n'
    service ?= 'i18n'
    filter ?= 'translate'
    defaultNs ?= 'defualt'

    translator = getInstance()
    translator.load directory

    (req, res, next)->
        {pathname} = url.parse req.url
        if req.method is 'GET' and pathname is path
            lang = req.cookies[cookie]
            try
                res.end bundle
                    resource: translator.langs[lang]
                    lang: lang
                    module: module
                    service: service
                    filter: filter
                    nsSeparator: nsSeparator
                    defaultNs: defaultNs
            catch e
                debug e
                res.write ';console.error(' + JSON.stringify(e.toString()) + ');'
                res.end()
        else
            next()

module.exports =
    middleware: middleware
    bundle: bundle
