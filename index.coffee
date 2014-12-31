server = require "./server"
client = require "./client"
angular = require "./angular"


module.exports =

    Translator: require("./translator").Translator

    middleware: server.middleware

    javascript: client.middleware
    bundleAsJavascript: client.bundle

    angular: angular.middleware
    bundleAsAngularModule: angular.bundle
