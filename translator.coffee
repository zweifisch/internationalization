fs = require "fs"
pth = require "path"
Template = require './template'
{load, findBestMatch} = require './utils'


class Translator

    constructor: (@nsSeperator=":")->
        @langs = {}
        @templateCache = {}

    load: (directory)->
        for subdir in fs.readdirSync directory
            @langs[subdir] = load pth.join directory, subdir

    translate: (lang, key, vars...)->
        idx = key.indexOf @nsSeperator
        if idx isnt -1
            template = @langs[lang]?[key.substr 0, idx]?[key.substr idx+1] or key.substr idx+1
        else
            template = @langs[lang]?[key] or key
        if not vars.length
            return template

        if template not of @templateCache
            @templateCache[template] = new Template template

        if 'object' is typeof vars[0]
            @templateCache[template].render vars[0], vars[1..]
        else
            @templateCache[template].render null, vars...

    translatePlural: (lang, key, keyPlural, count, vars)->
        if count is 1
            translate lang, key, vars, count
        else
            translate lang, keyPlural, vars, count

    speaks: ->
        Object.keys @langs

    knows: (lang)->
        lang and lang of @langs

    try: (langs)->
        findBestMatch langs, @langs

translator = null
getInstance = ->
    translator = new Translator unless translator
    translator

module.exports =
    Translator: Translator
    getInstance: getInstance
