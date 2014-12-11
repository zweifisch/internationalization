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
