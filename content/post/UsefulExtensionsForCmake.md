---
title: "Useful extensions for CMake"
description: "Initial Draft of cmakepp"
date: 2014-09-05
tags: ["cmakepp", "cmake"]
categories: ["cmake"]
draft: true
---


When using cmake for more than just simple projects it is lacking in various aspects. Some list and string functions are missing. Interaction with command line applications and the file system are harder than they need to be. Especially however using structured data (maps and objects) and more complex funtional programming is not easy at all. So a couple of months ago I started implementing some extensions for object oriented programming 1 2. I which I continued to refine and which are the basis for my pure cmake package manager. They have now reached a level which I am confident enough in to describe in another post which I will try to distribute around the internet a bit so I can see if others find this useful as well.

[Here](https://github.com/toeb/cmakepp) is the repository. (MIT License) Scroll down to look at the getting started documentation and feature list.

All features can be tested with the interactive cmake shell which is like running nodejs in interactive mode. You can also look at the unit tests which are numerous however not complete, for usage examples. Most functions which do something non-trivial are documented and every function is in its own file.

To use oocmake in your project you just have to download the repository and include the oo-cmake.cmake file which takes about 1 second to load 530 functions to which extend cmake.

So if you have questions suggestions or ideas I would be happy to hear them :D If you want to contribute go ahead I will review all merge requests happily.