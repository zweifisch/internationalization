chai = require 'chai'
chai.should()
{expect} = chai

Template = require './template'
{getAcceptLanguage, findBestMatch} = require './index'

describe 'template', ->

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

    it 'should parse header', ->
        getAcceptLanguage('da, en-gb;q=0.8, en;q=0.7').should.deep.equal ['da', 'en-gb', 'en']

describe 'misc', ->

    it 'should find best match', ->
        findBestMatch(['da', 'en-gb', 'en'], {'da':yes, 'en-gb':yes}).should.equal 'da'
        findBestMatch(['da', 'en-gb', 'en'], {'en-gb':yes}).should.equal 'en-gb'
        findBestMatch(['da', 'en-gb', 'en'], {'en':yes}).should.equal 'en'
        findBestMatch(['da', 'en-gb'], {'en':yes}).should.equal 'en'

describe "translate", ->

    {setLangs, translate} = require "./index"

    setLangs
        en:
            ns:
                key: "value"
            positional: "second is {2}, first is {1}"
            named: "key is {key}, value is {value}"
            mixed: "value is {value}, first is {1}"


    it "should find key under namespace", ->

        translate("en", "ns:key").should.equal "value"

    it "should render template", ->

        translate("en", "positional", "first", "second").should.equal "second is second, first is first"
        translate("en", "named", key: "key", value: "value").should.equal "key is key, value is value"
        translate("en", "mixed", value: "value", "first").should.equal "value is value, first is first"
