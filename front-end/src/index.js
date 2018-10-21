'use strict';

import ElmRuntime from './elm/Main.elm'

(function () {
    var node = document.getElementById('elm');
    var app = ElmRuntime.Elm.Main.init({
        node: node
    });
})();