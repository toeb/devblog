---
title: "cmakepp: Reading and Writing JSON"
decription: "cmakepp: Reading and Writing JSON"
date: 2014-03-05
tags: ["cmake", "cmakepp"]
categories: ["cmake"]
draft: true
---


While working on a package manager for CMake I came across the problem of finding a suitable format for my package descriptor files. First I thought about and tried using plain old CMake file that simply sets variables and can be included to access its contents. It was very quick and easy to implement. Hierarchical data structures however where hard to implement and a none standard format makes it harder to exchange data with a webservice/other programs. So I opted for using JSON as my import/export format. JSON is alot easier to parse than XML and is still ubiquitous in software developement so I cast aside XML (for now).

You can grab my implementation for reading and writing JSON with CMake at Github. Its part of my object oriented CMake library and uses my implementation for CMake maps and references.

Note: Because CMake only understands strings the deserializer only accepts string , array or object values. Also all keys and values have to be double quoted.

As always: feedback is most welcome if you feel like it you can tell me if you find it usefull, have ideas, or think that I have reinvented the wheel.

Here are some examples for serialization and deserialization:

```cmake

# serialize empty value
json_serialize(res "")
assert(NOT res)


# serialze simple value
json_serialize(res "hello!")
assert(res)
assert("\"hello!\"" STREQUAL ${res})

# serialize a cmake list value
json_serialize(res "a;b;c")
assert(res)
assert(EQUALS "\"a\\\\;b\\\\;c\"" ${res})

#empty object
element(uut MAP)
element(END)
json_serialize(res ${uut})
assert("{}" STREQUAL ${res})

# empty list
element(uut LIST)
element(END)
json_serialize(res ${uut})
assert("[]" STREQUAL ${res})

# ref
ref_new(uut)
ref_set(${uut} "a b c")
json_serialize(res ${uut})
assert("\"a b c\"" STREQUAL ${res})

# list with one element
element(uut LIST)
value(1)
element(END)
json_serialize(res ${uut})
assert("[\"1\"]" STREQUAL ${res})

# list with multiple elements element
element(uut LIST)
value(1)
value(2)
element(END)
json_serialize(res ${uut})
assert("[\"1\",\"2\"]" STREQUAL ${res})

# object with single value
element(uut MAP)
value(KEY k1 val1)
element(END)
json_serialize(res ${uut})
assert("{\"k1\":\"val1\"}" STREQUAL ${res})

# object with multiple value
element(uut MAP)
value(KEY k1 val1)
value(KEY k2 val2)
element(END)
json_serialize(res ${uut})
assert("{\"k1\":\"val1\",\"k2\":\"val2\"}" STREQUAL ${res})

# list with single map
element(uut LIST)
element()
value(KEY k1 1)
element(END)
element(END)
json_serialize(res ${uut})
assert("[{\"k1\":\"1\"}]" STREQUAL ${res})


# deserialize a empty value
json_deserialize(res "")
assert(NOT res)

# deserialize a empty object
json_deserialize(res "{}")
assert(res)
ref_isvalid( ${res}  is_ref)
assert(is_ref MESSAGE "expected res to be a ref")

# desirialize a empty array
json_deserialize(res "[]")
assert(res)
ref_isvalid( ${res} is_ref)
assert(is_ref MESSAGE "expected res to be a ref")

# deserialize a simple value
json_deserialize(res "\"teststring\"")
assert(${res} STREQUAL "teststring")

# deserialize a array with one value
json_deserialize(res "[\"1\"]")
map_navigate(val "res[0]")
assert(${val} STREQUAL "1")

#deserialize a array with multiple values
json_deserialize(res "[\"1\", \"2\"]")
map_navigate(val "res[0]")
assert(${val} STREQUAL "1")
map_navigate(val "res[1]")
assert(${val} STREQUAL "2")

# deserialize a simple object with one value
json_deserialize(res "{ \"key\" : \"value\"}")
map_navigate(val "res.key")
assert(${val} STREQUAL "value")

# deserialize a simple object with multiple values
json_deserialize(res "{ \"key\" : \"value\", \"key2\" : \"val2\"}")
map_navigate(val "res.key")
assert(${val} STREQUAL "value")
map_navigate(val "res.key2")
assert(${val} STREQUAL "val2")


# deserialize a simple nested structure
json_deserialize(res "{ \"key\" : {\"key3\":\"myvalue\" }, \"key2\" : \"val2\"}")
map_navigate(val "res.key2")
assert(${val} STREQUAL "val2")
map_navigate(val "res.key.key3")
assert(${val} STREQUAL "myvalue")

# deserialize a nested structure containing both arrays and objects
json_deserialize(res "{ \"key\" : [\"1\", \"2\"], \"key2\" : \"val2\"}")
map_navigate(val "res.key2")
assert(${val} STREQUAL "val2")
map_navigate(val "res.key[0]")
assert(${val} STREQUAL "1")
map_navigate(val "res.key[1]")
assert(${val} STREQUAL "2")

# deserialize a 'deeply' nested structure and get a value
json_deserialize(res "{ \"key\" : [{\"k1\":\"v1\"}, \"2\"], \"key2\" : \"val2\"}")
map_navigate(val "res.key[0].k1")
assert(${val} STREQUAL "v1")
```