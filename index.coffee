fs = require 'fs'
path = require 'path'

Template = require './template'
{parse} = require 'miff'

debug = require('debug') 'i18n'

langs = {}
templateCache = {}

loadSingle = (directory)->
    ret = {}
    for file in fs.readdirSync directory
        pth = path.join directory, file
        content = fs.readFileSync pth, encoding: 'utf8'
        try
            parse content, equal:yes, section:yes, quote:yes, ret
        catch e
            throw new Error "#{e.message} in #{pth}"
    ret

load = (directory)->
    for subdir in fs.readdirSync directory
        langs[subdir] = loadSingle path.join directory, subdir
    langs

getAcceptLanguage = (header)->
    header.split(',').map (item)->
        [lang,q] = item.split ';'
        lang.trim()

findBestMatch = (accepts, available)->
    for lang in accepts
        return lang if lang of available
    accepts = accepts.map (x)-> x.split '-'
        .filter (x)-> x.length > 1
        .map ([x])-> x
    for lang in accepts
        return lang if lang of available

translate = (lang, key, vars...)->
    template = langs[lang]?[key] or key
    if not vars.length
        return template

    if not template of templateCache
        templateCache[template] = new Template template

    if 'object' is typeof vars[0]
        templateCache[template].render vars[0], vars[1..]
    else
        templateCache[template].render vars...

translatePlural = (lang, key, keyPlural, count, vars)->
    if count is 1
        translate lang, key, vars, count
    else
        translate lang, keyPlural, vars, count

middleware = ({cookie, directory, fallback})->
    if not directory
        throw new Error "you hava to specify directory for locales"
    cookie ?= 'lang'
    load directory
    _langs = Object.keys langs
    if _langs.length
        debug "languages loaded: #{_langs}"
    else
        debug "no languages loaded"
    _langs = undefined
    (req, res, next)->
        if req.query['set-lang']
            lang = req.query['set-lang']
            debug "language preference from query #{lang}"
        else
            lang = req.cookies[cookie]
            if lang
                debug "language preference from cookie #{lang}"
        if lang not of langs
            debug "accept language #{req.headers['accept-language']}"
            lang = if req.headers['accept-language']
                findBestMatch (getAcceptLanguage req.headers['accept-language']), langs
            if lang
                debug "accept language intepreted as #{lang}"
            else
                lang = fallback
                debug "fallback to #{lang}"
        res.locals._ = (args...)-> translate lang, args...
        res.locals.__ = (args...)-> translatePlural lang, args...
        res.locals.lang = lang
        req.lang = lang
        if lang and req.cookies[cookie] isnt lang
            res.cookie cookie, lang,
                maxAge: 31536000000  # a year
        debug "lang #{lang}"
        next()

bundleAsJavascript = (resource, lang, exportAs)->
    """
    ;var #{exportAs} = {};
    (function() {
        var dict = #{JSON.stringify resource};
        #{exportAs}.translate = function(key, ns) {
            if (ns) {
                return dict[ns][key];
            } else {
                return dict[key];
            }
        };
        #{exportAs}.resource = dict;
        #{exportAs}.lang = '#{lang}';
    })();
    """

javascript = ({directory, cookie, path, exportAs})->
    url = require 'url'
    pth = require 'path'
    path ?= '/i18n.js'
    cookie ?= 'lang'
    exportAs ?= 'i18n'
    (req, res, next)->
        {pathname} = url.parse req.url
        if req.method is 'GET' and pathname is path
            realpath = pth.join directory, pathname.substr 1
            try
                res.end bundleAsJavascript langs[req.cookies[cookie]], req.cookies[cookie], exportAs
            catch e
                debug e
                res.write ';console.error(' + JSON.stringify(e.toString()) + ');'
                res.end()
        else
            next()

module.exports =
    load: load
    middleware: middleware
    javascript: javascript
    translate: translate
    translatePlural: translatePlural
    getAcceptLanguage: getAcceptLanguage
    findBestMatch: findBestMatch
    bundleAsJavascript: bundleAsJavascript
