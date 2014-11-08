
exports.parse = (input, result)->
    result ?= {}
    for line, linenumber in input.split '\n'
        line = line.trim()
        continue unless line
        shift = 1
        while true
            idx = line.indexOf '=', shift
            if idx is -1
                throw new Error "'=' not found on line #{linenumber + 1}"
            if '\\' isnt line.charAt idx - 1
                key = (line.substr 0, idx).split('\\=').join '='
                value = line.substr idx + 1
                break
            shift = idx + 1
        result[key.trimRight()] = value.trimLeft()
    result

