---
title: "Objects and Maps in CMake"
date: 2016-08-30T23:24:46+02:00
draft: true
---


Objects and Maps in CMake
by thetoeb • 2014/02/16 • 7 Comments

Get it at https://github.com/toeb/oo-cmake and tell me if you like it

For more complex build system features oo programming would be a major boon. So I took it upon myself to create a usable and tested oo-extension for cmake (in pure CMake) so I could continue developing and extending my plattform independent tooling support (cutil) .

It’s too bad that Kitware decided to use their own language (with very little high level language features) for their build system product because CMakes project generation capabilties are unparalleled .  I can understand that it seemed like a good idea at first ( the CMake scripting Language is platform independent and easier to use than make or bash or cmd also it was not intended to do complicated things). I however strongly believe that building a programm should be as easy as possible and therefore a high level language should have been used. CMake’s creators Bill Hoffman and Kenneth Martin have said that they would have done this differently if they had to do it again (http://www.aosabook.org/en/cmake.html)

Of course CMake does not offer language features for a very sleak usage but the with these functions you can use prototypical inheritance, maps, methods, objects, lists, properties, references, etc. which are at the basis of every oo language.

Even if you do not want to do inheritance in CMake you can use these functions for Maps (Dictionaries)

People familiar with JavaScript will be familiar with this approach to object orientation.

Here is a simple example

cmake_minimum_required(VERSION 2.8)
# include standalone version of oo-cmake
# when not using cutil this  includes the function files as well as
# the dependent functions
include("../oo-cmake.cmake")

message("creating a simple inheritance example")

#create animal object
obj_create(animal)

# set object method eat
# this method prints out which food the animal is eating
# existing functions can also be appliead via obj_bindcall(${ref} func arg1 arg2 arg3)
obj_set(
    ${animal}   #reference to animal object
    "eat"       #name of property
    RAW         # RAW indictates that the data is to be treated as a raw string not a list (hinders evaluation)
    "function(eat this)
      obj_get(${this} food food) 
      message("I am eating ${food}") 
     endfunction()"
)

# create mamal object
obj_create(mamal)
obj_setprototype(${mamal} ${animal})

#create bird object
obj_create(bird)                    #create instance
obj_setprototype(${bird} ${animal}) #set prototype animal
obj_set(${bird} food Birdfood)      #set bird's food property to "Birdfood"

#create dog object
obj_create(dog)                     #create instance
obj_setprototype(${dog} ${mamal})   #set prototype mamal
obj_set(${dog} food Dogfood)        #set dogs food property to "Dogfood"

#create cat object
obj_create(cat)                     #create instance
obj_setprototype(${cat} ${mamal})   #set prototype mamal
obj_set(${cat} food Catfood)        #set cat's food property to "Catfood"

# call eat function for different objects
obj_callmember(${bird} eat) 
obj_callmember(${dog} eat)
obj_callmember(${cat} eat)

#output should be
#I am eating Birdfood
#I am eating Dogfood
#I am eating Catfood
You can use the following commands

 
obj_create(out_ref [objectpath]) #returns a ref to a new object. this object is persistent and will exist until obj_delete is called, internally the object is represented by a folder
obj_delete(in_ref) # deletes a object (deletes the folder internally)
obj_find(refOrId) # searches for a named object or id
obj_get(ref value key) # gets a property ${value} = ref[key] the prototype chain is considered
obj_set(ref key value) # sets a property ref[key] = value
obj_getref(ref prop_ref key) # returns the reference to a property (a file)
obj_getownproperty(ref value key) # returns the value for property if the property belongs to ref 
obj_setownproperty(ref key value) # sets the own property ref[key] =value
obj_has(ref result key) # sets result to true if ref[key] exists
obj_hasownproperty(ref result key) # sets result to true if ref[key] exists and is owned by ref
obj_callmember(ref methodname args...) # calls a stored memberfunction (first argument passed is ref)
obj_bindcall(ref methodname args...) # calls a defined function setting first argument to ref
obj_setprototype(ref proto_ref) # sets the prototype for ref
obj_getprototype(ref proto_ref) # returns the prototyp for ref
obj_settype(ref type) # sets the type for ref
obj_gettype(ref type) # gets the type for ref
obj_getkeys(ref keys) # returns all defined properties for ref
obj_getownkeys(ref keys) # returns all defined properties that ref owns