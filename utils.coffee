fs = require 'fs'
pth = require 'path'
{parse} = require 'miff'


exports.load = (directory)->
    ret = {}
    for file in fs.readdirSync directory
        path = pth.join directory, file
        content = fs.readFileSync path, encoding: 'utf8'
        try
            parse content, equal:yes, ret
        catch e
            throw new Error "#{e.message} in #{path}"
    ret


exports.findBestMatch = (accepts, available)->
    for lang in accepts
        return lang if lang of available
    accepts = accepts.map (x)-> x.split '-'
        .filter (x)-> x.length > 1
        .map ([x])-> x
    for lang in accepts
        return lang if lang of available


exports.getAcceptLanguage = (header)->
    return [] unless header
    header.split(',').map (item)->
        [lang,q] = item.split ';'
        lang.trim()
