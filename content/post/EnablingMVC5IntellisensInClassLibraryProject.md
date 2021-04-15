---
title: "Modern CMake Slides"
date: 2016-08-30T23:24:46+02:00
draft: true
---


Enabling MVC5 intellisense in a ClassLibrary Project
by thetoeb • 2014/01/05 • 3 Comments

I’ve been searching and searching the internet for someone, somewhere who might know how to enable correct IntelliSense for cshtml (MVC 5.0) in VS2013 when developing in a ClassLibrary type project.

This is the problem I was encountering:

Missing Intellisense

It’s all thanks to Mohammad Chehab, who was also stumped for a while (probably not as long as me), that I was able to find the solution.  His blog post explains that one must change the output path for the class library to bin/ (instead of bin/<release>)  for Intellisense  to work.

So now I can show you the steps for creating a ClassLibrary with cshtml (MVC5 Style):

Create or open an existing class library project (if you open an existing one be sure to remove the MVC5 nuget package)
Add the MVC (5.0) nuget package (right click project in solution explorer -> Manage NuGet Packages -> search for MVC and install “Microsoft ASP.NET MVC”)
Close any and all open .cshtml files
Right click project -> Properties -> Build -> change Output path to “bin/”
Add the following minimal Web.config to the root of your class library project ( the web config file is solely needed for intellisense. Configuration (via Web.config) should be done in the WebApplication hosting your ClassLibrary assembly)
Clean and Build the solution.
Open cshtml file
Voila
Web.config

<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <sectionGroup name="system.web.webPages.razor" type="System.Web.WebPages.Razor.Configuration.RazorWebSectionGroup, System.Web.WebPages.Razor, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35">
      <section name="host" type="System.Web.WebPages.Razor.Configuration.HostSection, System.Web.WebPages.Razor, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35" requirePermission="false" />
      <section name="pages" type="System.Web.WebPages.Razor.Configuration.RazorPagesSection, System.Web.WebPages.Razor, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35" requirePermission="false" />
    </sectionGroup>
  </configSections>
  <appSettings>
    <add key="webpages:Version" value="3.0.0.0" />
    <add key="webpages:Enabled" value="false" />
  </appSettings>

  <system.web>
    <compilation debug="true" targetFramework="4.5" />
  </system.web> 
  
  <system.web.webPages.razor>
    <host factoryType="System.Web.Mvc.MvcWebRazorHostFactory, System.Web.Mvc, Version=5.0.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35" />
    <pages pageBaseType="System.Web.Mvc.WebViewPage">
      <namespaces>
        <add namespace="System.Web.Mvc" />
        <add namespace="System.Web.Mvc.Ajax" />
        <add namespace="System.Web.Mvc.Html" />
        <add namespace="System.Web.Optimization"/>
        <add namespace="System.Web.Routing" />
        <!-- add other namespaces for views here -->
        <!-- e.g. your own project's, Lib.Views.Etc -->
      </namespaces>
    </pages>
  </system.web.webPages.razor>
</configuration>
One would expect for intellisense for a .cshtml files to work after step 2. However the other steps need to be performed before Intellisense works for  directives like @model or the base page (which contains Model, ViewBag, etc. )

The result looks like it is supposed to:

Correct Intellisense

You may download an example solution here: http://goo.gl/Jx2cXg

As to the reason why this does not work correctly:  I believe the intellisense provider for cshtml files compiles these in the background using the web.config s it finds in the solution and expects the resulting .dll s to be stored in the bin directory (which is the default output directory for WebApplication projects) However Class libraries have different subfolders depending on the build type  (bin/Debug, bin/Release, bin/<buildtype> ) and thus the IntellisenseProvider cannot find these files.  I think the Intellisense/MVC/Razor/ASP.NET developement team could fix this easily, however it is a rare bug because putting Views into separate assemblies is currently an edge case for MVC.  (hopefully not in the future)