---
title: "CTest Integration for VisualStudio"
date: 2016-08-30T23:24:46+02:00
draft: true
---

CTest Integration for VisualStudio
by thetoeb • 2014/11/22 • 0 Comments

Motivation
I have long searched for an extension in VisualStudio which allows you to control kitware’s CTests via the Test Explorer. Since no such thing existed I have developed a workable proof of concept myself :D.

This software is currently not in its finished state, It still needs polishing because it can be slow and is not well tested. However it works so if you want to give it a ride – go ahead. Feedback is welcome. But even more welcome would be if you chose to work on it and make it better.

Check it out at my github https://github.com/toeb/CTestTestAdapter / a compiled version is available as vsix in the root directory of the repository

screenshot

Features
Discovers all tests which are visable in your CMakeLists.txt by running ctest -N in your binary_dir
Control of test execution through Test Explorer Window
Success or Fail based on Outcome of ctest run
Future
More Test MetaData (line number, file, etc)
More efficient Test Runs