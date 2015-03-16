// Generated by CoffeeScript 1.8.0
(function() {
  var Template, Translator, findBestMatch, fs, getInstance, load, pth, translator, _ref,
    __slice = [].slice;

  fs = require("fs");

  pth = require("path");

  Template = require('./template');

  _ref = require('./utils'), load = _ref.load, findBestMatch = _ref.findBestMatch;

  Translator = (function() {
    function Translator(nsSeperator) {
      this.nsSeperator = nsSeperator != null ? nsSeperator : ":";
      this.langs = {};
      this.templateCache = {};
    }

    Translator.prototype.load = function(directory) {
      var subdir, _i, _len, _ref1, _results;
      _ref1 = fs.readdirSync(directory);
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        subdir = _ref1[_i];
        _results.push(this.langs[subdir] = load(pth.join(directory, subdir)));
      }
      return _results;
    };

    Translator.prototype.translate = function() {
      var idx, key, lang, template, vars, _ref1, _ref2, _ref3, _ref4;
      lang = arguments[0], key = arguments[1], vars = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      idx = key.indexOf(this.nsSeperator);
      if (idx !== -1) {
        template = ((_ref1 = this.langs[lang]) != null ? (_ref2 = _ref1[key.substr(0, idx)]) != null ? _ref2[key.substr(idx + 1)] : void 0 : void 0) || key.substr(idx + 1);
      } else {
        template = ((_ref3 = this.langs[lang]) != null ? _ref3[key] : void 0) || key;
      }
      if (!vars.length) {
        return template;
      }
      if (!(template in this.templateCache)) {
        this.templateCache[template] = new Template(template);
      }
      if ('object' === typeof vars[0]) {
        return this.templateCache[template].render(vars[0], vars.slice(1));
      } else {
        return (_ref4 = this.templateCache[template]).render.apply(_ref4, [null].concat(__slice.call(vars)));
      }
    };

    Translator.prototype.translatePlural = function(lang, key, keyPlural, count, vars) {
      if (count === 1) {
        return translate(lang, key, vars, count);
      } else {
        return translate(lang, keyPlural, vars, count);
      }
    };

    Translator.prototype.speaks = function() {
      return Object.keys(this.langs);
    };

    Translator.prototype.knows = function(lang) {
      return lang && lang in this.langs;
    };

    Translator.prototype["try"] = function(langs) {
      return findBestMatch(langs, this.langs);
    };

    return Translator;

  })();

  translator = null;

  getInstance = function() {
    if (!translator) {
      translator = new Translator;
    }
    return translator;
  };

  module.exports = {
    Translator: Translator,
    getInstance: getInstance
  };

}).call(this);