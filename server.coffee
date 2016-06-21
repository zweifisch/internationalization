debug = require('debug') 'i18n'
{getAcceptLanguage} = require "./utils"
{getInstance} = require "./translator"

middleware = ({cookie, directory, fallback, nsSeparator, query})->
    if not directory
        throw new Error "you hava to specify directory for locales"
    if not fallback
        throw new Error "you hava to specify a fallback language"
    cookie ?= 'lang'
    query ?= 'set-lang'
    nsSeparator ?= ':'

    env = process.env.NODE_ENV or 'development'

    translator = getInstance nsSeparator
    translator.load directory
    debug "languages loaded: #{translator.speaks()}"

    (req, res, next)->

        throw new Error "cookies not accessible" unless req.cookies

        translator.load directory if env is "development"

        lang = req.query[query] || req.cookies[cookie] || translator.try getAcceptLanguage req.headers['accept-language']

        if not translator.knows lang
            lang = fallback
            debug "fallback to #{lang}"

        req.tr = res.locals._ = (args...)-> translator.translate lang, args...
        req.tp = res.locals.__ = (args...)-> translator.translatePlural lang, args...
        req.lang = res.locals.lang = lang

        if req.cookies[cookie] isnt lang
            res.cookie cookie, lang, maxAge: 31536000000  # a year
            debug "set cookie lang=#{lang}"

        next()

module.exports =
    middleware: middleware
