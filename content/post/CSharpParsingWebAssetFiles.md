---
title: "A Quick Way of Parsing versioned Web Asset Files"
date: 2016-08-30T23:24:46+02:00
draft: true
---
A Quick Way of Parsing versioned Web Asset Files
by thetoeb • 2013/12/04 • 0 Comments

To parse versioned web asset filenames ala
jquery-1.4.min.js
I wrote a simple class 

/// <summary>
/// simple class for describing a file library like 
/// jquery-1.4.min.js
/// bootstrap.min.css
/// libname-1.0.0.0.tag1.tag2.tag3.extension
/// ... etc
/// contains methods for parsing these kind of filenames
/// </summary>
public class FileLib
{
  /// <summary>
  /// regular expression for parsing the filename
  /// </summary>
  public static readonly string libRegex = @"((?<libname>[^.-]*)-?)((?<major>d+))?(.(?<minor>d+)(.(?<revision>d+)(.(?<build>d+))?)?)?(.(?<tags>.+))*";
  /// <summary>
  /// parses a path as a lib
  /// </summary>
  /// <param name="path"></param>
  /// <returns></returns>
  public static FileLib ParsePath(string path)
  {
    var filename = Path.GetFileName(path);
    return Parse(filename);
  }
  /// <summary>
  /// parses a filename as a file lib 
  /// </summary>
  /// <param name="filename"></param>
  /// <returns></returns>
  public static FileLib Parse(string filename)
  {
    var match = Regex.Match(filename, libRegex);
    match.NextMatch();
    var lib = match.Groups["libname"].Value ?? "";
    var major = match.Groups["major"].Value ?? "";
    var minor = match.Groups["minor"].Value ?? "";
    var revision = match.Groups["revision"].Value ?? "";
    var build = match.Groups["build"].Value ?? "";
    var tags = match.Groups["tags"].Value.Split('.');
    var extension = tags.LastOrDefault() ?? "";
    tags = tags.Reverse().Skip(1).Reverse().ToArray();
    var result = new FileLib()
    {
      Extension = extension,
      LibName = lib,
      Major = major,
      Minor = minor,
      Revision = revision,
      Build = build,
      Tags = tags

    };
    return result;
  }
  /// <summary>
  /// Major version number
  /// </summary>
  public string Major { get; set; }
  /// <summary>
  /// Minor version number
  /// </summary>
  public string Minor { get; set; }
  /// <summary>
  /// Revision Number
  /// </summary>
  public string Revision { get; set; }

  /// <summary>
  /// Build number
  /// </summary>
  public string Build { get; set; }

  /// <summary>
  /// Creates a version object for the Filelib. returns null if this is not possible
  /// </summary>
  /// <returns></returns>
  public Version GetVersion()
  {

    Version parsedVersion = null;
    try
    {
      var version = Major + "." + Minor + "." + Revision + "." + Build;
      while (version.EndsWith(".")) version = version.Substring(0, version.Length - 1);
      if (version == "") return parsedVersion;
      parsedVersion = new Version(version);
    }
    catch (Exception exception) { }
    return parsedVersion;

  }
  /// <summary>
  /// the name of the lib
  /// </summary>
  public string LibName { get; set; }
  /// <summary>
  /// the tags of the lib.  e.g. min, intellisense, etc
  /// </summary>
  public IEnumerable<string> Tags { get; set; }
  /// <summary>
  /// the extension of the lib
  /// </summary>
  public string Extension { get; set; }
}