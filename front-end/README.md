# Project Structure

  

All the source files can be found under /src

All tests can be found under /tests

All custom webpack loaders can be found under /loaders

  

# Building from Source

  

* Ensure that [Elm is installed](https://guide.elm-lang.org/install.html). If you're new to Elm, feel free to read https://guide.elm-lang.org/ for a quick overview.

* Run `npm i` or `yarn` in the root folder

* Run any of the following in the root folder

	* Running `yarn dev` will compile a new unoptimized app.js in dist with elm set to debug mode

	* Running `yarn serve` will start a devserver on localhost:8080 (if available) running an unoptimized debug build

	* Running `yarn prod` will create an optimized production build in dist

  

# Running Tests

  

* Run `npm i` or `yarn` in the root folder if you have not already done so

* Run `elm-test` in the root folder
