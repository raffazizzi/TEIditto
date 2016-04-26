# TEIditto

## Work in progress - the library is not completed yet. You're welcome to contribute!

TEIditto is a ODD-driven JavaScript library to load a TEI XML document and register it as HTML5 custom elements.

For now it can load any single-namespace TEI document, register its elements, and return HTML5 elements. 

Still working on the ODD driven part:
* register elements via a compiled ODD rather than a TEI document
* convert TEI XML to HTML5 based on talbe built from the ODD

To build you'll need `npm`. Then run:
```
$ npm install
$ npm run test
```

If the tests run without errors, the compiled library will be in `dist/TEIditto.js`.