
class Template

    constructor: (@template)->
        throw new Error "template is empty" if not @template
        @tokens = []
        @types = []
        token = ''
        type = 0  # 0 for static content, 1 for variable
        escape = no
        for i in [0...@template.length]
            char = @template.charAt i
            if escape
                escape = no
                token += char
            else if '\\' is char
                escape = yes
            else if '{' is char
                throw new Error "unclosed curly brackets in '#{@template}'" if type is 1
                if token
                    @tokens.push token
                    @types.push type
                token = ''
                type = 1
            else if '}' is char
                throw new Error "unmatched curly brackets '#{@template}'" if type is 0
                if token
                    @tokens.push token
                    @types.push type
                token = ''
                type = 0
            else
                token += char
        if token
            @tokens.push token
            @types.push type
        throw new Error "unclosed curly brackets '#{@template}'" if type is 1
        @len = @types.length

    render: (vars, positionalvars...)->
        ret = ''
        for i in [0...@len]
            if @types[i] is 0
                ret += @tokens[i]
            else
                if vars and @tokens[i] of vars
                    ret += vars[@tokens[i]]
                else if 0 < +@tokens[i] <= positionalvars.length
                    ret += positionalvars[+@tokens[i] - 1]
                else
                    throw new Error "var '#{@tokens[i]}' missing, required in '#{@template}'"
        ret

if module?
    module.exports = Template
else
    return Template
