var exec = require('cordova/exec');

var EmbeddedWebView = {

    showEmbeddedWebView: function(successCallBack, errorCallBack, options) {
        exec(successCallBack, errorCallBack, "EmbeddedWebView", "showEmbeddedWebView", [options]);
    },

    closeEmbeddedWebView: function(successCallBack, errorCallBack) {
        exec(successCallBack, errorCallBack, "EmbeddedWebView", "closeEmbeddedWebView", []);
    },

    webviewHistoryBack: function(successCallBack, errorCallBack) {
        exec(successCallBack, errorCallBack, "EmbeddedWebView", "webviewHistoryBack", []);
    },

    webviewHistoryForward: function(successCallBack, errorCallBack) {
        exec(successCallBack, errorCallBack, "EmbeddedWebView", "webviewHistoryForward", []);
    }
};

module.exports = EmbeddedWebView;