chai = require 'chai'
chai.should()
{expect} = chai

describe 'template', ->

    Template = require './template'

    it 'should support named vars', ->
        t = new Template "{key} is {value}"
        t.render(key: 'true', value: 'false').should.equal 'true is false'

    it 'should complain when var missing', ->
        t = new Template "{key} is {value}"
        expect(-> t.render(key: 'true')).to.throw Error

    it 'should support positional vars', ->
        t = new Template "{2} is {1}"
        t.render(null, 'true', 'false').should.equal 'false is true'

    it 'should escape', ->
        t = new Template "\\{key\\} is {value}\\\\"
        t.render(key: 'true', value: 'false').should.equal '{key} is false\\'

    it 'should complain when curly bracket not matched', ->
        expect(-> new Template "{{key}").to.throw Error
        expect(-> new Template "{key}}").to.throw Error
        expect(-> new Template "key}").to.throw Error
        expect(-> new Template "}key").to.throw Error
        expect(-> new Template "{key").to.throw Error
        expect(-> new Template "key{").to.throw Error

describe 'header parsing', ->

    {getAcceptLanguage} = require './utils'
    it 'should parse header', ->
        getAcceptLanguage('da, en-gb;q=0.8, en;q=0.7').should.deep.equal ['da', 'en-gb', 'en']

describe "translate", ->

    {Translator} = require "./translator"

    it "should find key under namespace", ->

        translator  = new Translator()
        translator.langs =
            en:
                ns:
                    key: "value"
        translator.translate("en", "ns:key").should.equal "value"

        translator = new Translator "."
        translator.langs =
            en:
                ns:
                    key: "value"
        translator.translate("en", "ns.key").should.equal "value"

    it "should render template", ->

        translator = new Translator()
        translator.langs =
            en:
                positional: "second is {2}, first is {1}"
                named: "key is {key}, value is {value}"
                mixed: "value is {value}, first is {1}"

        translator.translate("en", "positional", "first", "second").should.equal "second is second, first is first"
        translator.translate("en", "named", key: "key", value: "value").should.equal "key is key, value is value"
        translator.translate("en", "mixed", value: "value", "first").should.equal "value is value, first is first"

    it "should find closest", ->

        translator = new Translator()

        translator.langs = 'da':yes, 'en-gb':yes
        translator.try(['da', 'en-gb', 'en']).should.equal 'da'

        translator.langs = 'en-gb':yes
        translator.try(['da', 'en-gb', 'en']).should.equal 'en-gb'

        translator.langs = en: yes
        translator.try(['da', 'en-gb', 'en']).should.equal 'en'

        translator.langs = en: yes
        translator.try(['da', 'en-gb']).should.equal 'en'

