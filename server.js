(function() {
  var debug, getAcceptLanguage, getInstance, middleware,
    slice = [].slice;

  debug = require('debug')('i18n');

  getAcceptLanguage = require("./utils").getAcceptLanguage;

  getInstance = require("./translator").getInstance;

  middleware = function(arg) {
    var cookie, directory, env, fallback, nsSeparator, query, translator;
    cookie = arg.cookie, directory = arg.directory, fallback = arg.fallback, nsSeparator = arg.nsSeparator, query = arg.query;
    if (!directory) {
      throw new Error("you hava to specify directory for locales");
    }
    if (!fallback) {
      throw new Error("you hava to specify a fallback language");
    }
    if (cookie == null) {
      cookie = 'lang';
    }
    if (query == null) {
      query = 'set-lang';
    }
    if (nsSeparator == null) {
      nsSeparator = ':';
    }
    env = process.env.NODE_ENV || 'development';
    translator = getInstance(nsSeparator);
    translator.load(directory);
    debug("languages loaded: " + (translator.speaks()));
    return function(req, res, next) {
      var lang;
      if (!req.cookies) {
        throw new Error("cookies not accessible");
      }
      if (env === "development") {
        translator.load(directory);
      }
      lang = req.query[query] || req.cookies[cookie] || translator["try"](getAcceptLanguage(req.headers['accept-language']));
      if (!translator.knows(lang)) {
        lang = fallback;
        debug("fallback to " + lang);
      }
      req.tr = res.locals._ = function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return translator.translate.apply(translator, [lang].concat(slice.call(args)));
      };
      req.tp = res.locals.__ = function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return translator.translatePlural.apply(translator, [lang].concat(slice.call(args)));
      };
      req.lang = res.locals.lang = lang;
      if (req.cookies[cookie] !== lang) {
        res.cookie(cookie, lang, {
          maxAge: 31536000000
        });
        debug("set cookie lang=" + lang);
      }
      return next();
    };
  };

  module.exports = {
    middleware: middleware
  };

}).call(this);
