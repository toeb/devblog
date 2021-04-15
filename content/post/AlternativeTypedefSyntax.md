---
title: "Alternative `typedef` Syntax"
description: "An Alternative typedef Syntax using the C++ Preprocessor"
date: 2014-10-13
tags: ["C++", "Preprocessor", "deprecated"]
categorie: ["C++"]
draft: true
---

**Disclaimer: This post will be more interesting to you if you work with the preprocessor.**

Here you can find a preprocessor only solution for changing the `typedef` syntax from `typedef int number_type`; to `int typedef_as number_type`; – an alternative `typedef` Syntax.

If your wondering where this might be useful let me tell you why I needed it: I was working on a preprocessor macro which defines a property – a field, a getter and a setter. The easiest syntax I was able to achieve was the following: `typedef int property(MyValue)` which expanded into something similar to this:

```C++
typedef int MyValuePropertyType;
MyValuePropertyType _MyValue;
MyValuePropertyType getMyValue()const{return _MyValue;}
void setMyValue(const MyValuePropertyType & value){_MyValue = value;}
```


The `typedef` at the beginning was not aesthetically pleasing and I wanted to get rid of it so that I would get the same functionality but with this syntax: `int property(MyValue)`. (By the way – I do not like passing the name to the macro either, but there is no workaround for that) So I am terribly proud that I can now present to you the solution for my `typedef_as` macro. /s (seriously: someone might find it useful for similar situations while working with the preprocessor):


```C++
// helper for getting preceeding type
#define TYPEDEF_AS_HELPER_NAME(NAME) __hiddenHelper_##NAME

// inner macro for preceeding type typedef
#define TYPEDEF_AS_(NAME)\
  static inline TYPEDEF_AS_HELPER_NAME(NAME)(){throw "never call me";};\
  typedef decltype(TYPEDEF_AS_HELPER_NAME(NAME)()) 

// typedef_as
// changes the original typdef syntax from: `typedef <type> <type alias>` to `<type> typedef_as <type_alias>`
#define typedef_as TYPEDEF_AS_(__##__LINE__)

```

What this code does basically is to declare a static method method which returns the specified type. Then it takes this method’s decltype to start a typedef statement which you only need to complete with the name of the type alias. It uses the __LINE__ macro to create a unqiue name for the static helper method.

Caveats:

you should not use it in multiple header files outside of a class as naming conflicts can occur if you have two headerfiles and define the typedef at the same line and the namespace is the same.
Feel free to use it (no dependencies, public domain) wherever you want. I’m always happy for feedback and upvotes :)