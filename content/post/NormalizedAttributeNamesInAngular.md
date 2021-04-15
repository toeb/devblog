---
title: "Normalized Attribute Names in Angular"
decription: "my very first blog post"
date: 2014-01-14
tags: ["angular", "js"]
categories: ["frontend"]
draft: true
---

I have been doing some hard directive/ html markup work and I came across a problem where I needed the normalized html tag attribute names.   (I was trying to create a html element but needed access to the normalized names without turning it into a directive)

Angular.js normalizes names like “test-name” and “data-test-name” to “testName”.  So I went ahead and extracted and wrapped the functions needed into the following function:


```js

/** normalizes attribute names ,  stolen from angular.js */
function normalizeAttributeName(attributeName) {
  // copied from angular.js v1.2.2
  // (c) 2010-2012 Google, Inc. http://angularjs.org
  // License: MIT
  // modified by me :D
  var SPECIAL_CHARS_REGEXP = /([:-_]+(.))/g;
  var MOZ_HACK_REGEXP = /^moz([A-Z])/;

  function camelCase(name) {
    return name.
      replace(SPECIAL_CHARS_REGEXP, function (_, separator, letter, offset) {
        return offset ? letter.toUpperCase() : letter;
      }).
      replace(MOZ_HACK_REGEXP, 'Moz$1');
  }

  var PREFIX_REGEXP = /^(x[:-_]|data[:-_])/i;

  function directiveNormalize(name) {
    return camelCase(name.replace(PREFIX_REGEXP, ''));
  }
  return directiveNormalize(attributeName);
}

```

I did not find out how this could be done by just calling an angular api so  if you know how, please let me know :D