var compileToString = require('node-elm-compiler').compileToString;
var UglifyJS = require('uglify-js');

module.exports = function elmLoader(content, map, meta) {
    var callback = this.async();

    var optimize = this.query.optimize;
    var opts = {};
    if (optimize) {
        opts.optimize = true;
    } else {
        opts.debug = true;
    }

    compileToString([this.resourcePath], opts).then(function (data) {
        if (optimize) {
            var result = minify(data);
            if (result.error) {
                console.log(result.error);
                data = "";
            } else {
                data = result.code;
            }
        };
        callback(null, data, map, meta);
    }).catch(function (err) {
        console.log(err);
        callback(null, "", map, meta);
    });
}

function minify(jsString) {
    const options = {
        compress: {
            pure_funcs: ['F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9'],
            keep_fargs: false,
            pure_getters: true,
            unsafe_comps: true,
            unsafe: true
        },
    };
    return UglifyJS.minify(jsString, options);
}


// const { exec } = require('child_process');
// var fs = require('fs'),
//     path = require('path'),
//     os = require('os')
// const filePath = path.join(os.tmpdir(), 'elmOutput.js')

// module.exports = function elmLoader(content, map, meta) {
//     var callback = this.async();
//     execPromise(`elm make ${this.resourcePath} --debug --output="${filePath}"`)
//         .then(() => {
//             var result = readElmFile()
//             callback(null, result, map, meta);
//         });
// }

// function readElmFile() {
//     var result = fs.readFileSync(filePath, { encoding: 'utf-8' })
//     return result;
// }

// function execPromise(command, args) {
//     return new Promise((resolve, reject) => {
//         var child = exec(command, args);

//         child.on('error', (error) => {
//             console.log(error);
//         })

//         child.stdout.on('data', (data) => {
//             console.log(`stdout: ${data}`);
//         });

//         child.stderr.on('data', (data) => {
//             console.log(`stderr: ${data}`);
//         });

//         child.on('close', (code) => {
//             if (code !== 0) {
//                 console.log(`Command execution failed with code: ${code}`);
//             }
//             else {
//                 console.log(`Command execution completed with code: ${code}`);
//             }
//             resolve();
//         });
//     })
// }