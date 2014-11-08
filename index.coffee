fs = require 'fs'
path = require 'path'

Template = require './template'
{parse} = require './parser'

debug = require('debug') 'i18n'

langs = {}
templateCache = {}

loadSingle = (directory)->
    ret = {}
    for file in fs.readdirSync directory
        pth = path.join directory, file
        content = fs.readFileSync pth, encoding: 'utf8'
        try
            parse content, ret
        catch e
            throw new Error "#{e.message} in #{pth}"
    ret

load = (directory)->
    for subdir in fs.readdirSync directory
        langs[subdir] = loadSingle path.join directory,subdir

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
        throw new Error "you hava to specify direcotory for locales"
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
            lang = findBestMatch (getAcceptLanguage req.headers['accept-language']), langs
            if lang
                debug "accept language intepreted as #{lang}"
            else
                lang = fallback
                debug "fallback to #{lang}"
        res.locals._ = (args...)-> translate lang, args...
        res.locals.__ = (args...)-> translatePlural lang, args...
        req.lang = lang
        if lang and req.cookies[cookie] isnt lang
            res.cookie cookie, lang
        debug "lang #{lang}"
        next()

module.exports =
    load: load
    middleware: middleware
    translate: translate
    translatePlural: translatePlural
    getAcceptLanguage: getAcceptLanguage
    findBestMatch: findBestMatch
