---
title: "Typescript in V2013"
description: "How to enable Typescript Compilation for a VS2013 Class Library Project"
date: 2013-12-18
draft: true
tags: ["ts"]
categories: ["frontend", "obsolete"]
---

I know its a little obscure, but I recently needed to find out how to enable Typescript in a Visual Studio 2013 Class Library project, because per default this is not enabled. (probably a bug)

Vanilla way of enabling TypeScript:

Create a “Class Library” project
Add a Typescript file (.ts)
This is were the bug occurs, normally the TypeScript file should compile on save.  However it does not. So after searching around and looking at the csproj file and comparing it to a MvcApplication csproj file I found out what the problem is:

Visual Studio correctly adds the TypeScript props file at the top of your csproj. file:

```xml

<?xml version="1.0" encoding="utf-8"?>
<Project 
  ToolsVersion="12.0" 
  DefaultTargets="Build" 
  xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" />
  <Import Project="$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props" Condition="Exists('$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props')" />
…


```

(see first project import)

This allows your csproj file to use the <TypeScriptCompile> tag

e.g.

```xml
<TypeScriptCompile Include="Angular\Accounting\AccountingTestDirective.ts" />

```
Enabling compile on save is done by adding the missing

```xml
<Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" />
 
```

after …

```xml
  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />

```

… at the end of the csproj file, before your own custom build tasks.

I believe this should have been done automatically. But now I know how to do it manually >D