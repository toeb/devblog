---
title: "Object Oriented CMake: Next Iteration"
date: 2014-02-25
description: "New Version of Cmakepp, old blogpost"
tags: ["cmakepp", "cmake"]
categories: ["cmake"]
draft: true
---



I worked on my object oriented extensions for CMake  and am on a much higher level of usability than before!

try it at https://github.com/toeb/oo-cmake 

and as always: Feedback is most welcome

See the following object tutorial for ease of use: (for the current version look at the readme.md on github)

```cmake
### using objects
### =============
# oo-cmake is very similar to javascript
# I actually used the javascript reference to figure out how things could be done :)
# oo-cmake is a pure object oriented language like javascript (only objects no types per se)
# oo-cmake is currently file based and relies heavily on dynamic functions to be upfron about it:
# oo-cmake is very slow (depending on what your doing)

## creating a object
## =================
obj_new(myobject)
# ${myobject} now is a reference to an object
obj_exists(${myobject} _exists)
assert(_exists)

## deleting a object
## =================
# oo-cmake does not contains automatic memory management
# you can however remove all objects by calling obj_cleanup 
# (a very crude way of garbage collection) I would suggest calling it at the end of cmake.
obj_new(object_to_delete)
obj_delete(${object_to_delete})
# object_to_delete still contains the same reference
# but the object does not exists anymore and the following returns false
obj_exists(${object_to_delete} _exists)
assert(NOT _exists)

## setting and setting property
## ==================
obj_new(myobject)
# call obj_set passing the object reference
# the propertyname 'key1' and the value 'val1'
# everything beyond 'key1' is saved (as a list)
obj_set(${myobject} key1 "val1")
#call obj_get passing the object refernce the result variable and
# the key which is to be gotten
obj_get(${myobject} theValue key1)
assert(theValue)
assert(${theValue} STREQUAL "val1")

## setting a function and calling it
## =================================
obj_new(obj)
obj_set(${obj} last_name "Becker")
obj_set(${obj} first_name "Tobias")
#obj_setfunction accepts any function (cmake command, string function, file function, unique function (see function tutorial))
# if you use a cmake function be sure that it will not be overwritten
# the safest way to add a function is to use obj_declarefunction
# you can either specify the key where it is to be stored or not
# if you do not specify it the name of the function is used
function(greet result)
    # in the function you have read access to all fields of the proeprty
    # as will as to 'this' which contains the reference to the object

    # this sets the variable ${result} in PARENT_SCOPE (returning values in cmake)
    set(${result} "Hello ${first_name} ${last_name}!" PARENT_SCOPE)

endfunction()
obj_setfunction(${obj} greet)
obj_callmember(${obj} greet res)
assert(res)
assert(${res} STREQUAL "Hello Tobias Becker!")
# alternatively you can also use obj_declarefunction
# this is actually the easiest way to define a function in code
obj_declarefunction(${obj} say_goodbye)
function(${say_goodbye} result)
    set(${result} "Goodbye ${first_name} ${last_name}!" PARENT_SCOPE)
endfunction()
obj_callmember(${obj} say_goodbye res)
assert(res)
assert(res STREQUAL "Goodbye Tobias Becker!")

## built in methods
## ================
# obj_new creates a object which automatically inherits Object
# Object contains some functions e.g. to_string, print, ...
# 
obj_new(obj)
obj_callmember(${obj} print)

# this prints all members
# ie
#{
# print: [function], 
# to_string: [function], 
# __ctor__: [object :object_Y3dVWkChKi], 
# __proto__: [object :object_AztQwnKoE7], 
#}

## constructors
## ============
# you can easily define a object type via constructor
function(MyObject)
    # declare a function on the prototype (which is accessible for all objects)
    # inheriting from MyObject
    obj_declarefunction(${__proto__} myMethod)
    function(${myMethod} result)
        set(${result} "myMethod: ${myValue}" PARENT_SCOPE)
        this_set(myNewProperty "this is a text ${myValue}")
    endfunction()

    # set a field for the object
    this_set(myValue "hello")
endfunction()

obj_new(obj MyObject)
# type of object will now be MyObject
obj_gettype(${obj} type)
assert(type)
assert(${type} STREQUAL MyObject)
# call
obj_callmember(${obj} myMethod res)
assert(res)
assert(${res} STREQUAL "myMethod: hello")
obj_set(${obj} myValue "othervalue")
obj_callmember(${obj} myMethod res)
assert(res)
assert(${res} STREQUAL "myMethod: othervalue")
obj_get(${obj} res myNewProperty)
assert(res)
assert(${res} STREQUAL "this is a text othervalue")

## functors
## ========

## binding a function
## ==================
# you can bind any function to an object without
# setting it as property
# causing the function to get access to 'this'
# and all defined properties
function(anyfunction)
    this_callmember(print)
endfunction()
obj_new(obj)
obj_bindcall(${obj} anyfunction)
## print the object
# alternatively you can bind the function to the object
obj_bind(boundfu ${obj} anyfunction)
call_function(${boundfu})
# prints the object
# alternatively you can bind and import then function
# beware that you might overwrite a defined function if you append REDEFINE
# 
obj_bindimport(${obj} anyfunction myBoundFunc REDEFINE)
myBoundFunc()
# print the object

```