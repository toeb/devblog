---
title: "A Fluent Way of Exception Handling"
description: "Strategies to handle exceptions"
date: 2013-12-09
draft: true
---


While doing some filesystem work I encountered alot of AccessViolationExceptions because a file is being opened to write multiple times.  Even after closing the file explicitly a short timeframe exists in which the file could not be opened again.  The simplest approach for me was to retry openening the file until it worked.  To allow a more easy and more general way to handle exceptions I developed a small extensible try-repeat-framework which allows me to configure waiting and repeating strategies and also to only react to specific exceptions.  I have written it with a fluent interface which allows easy usage:

New: I created a Repository on Github : https://github.com/toeb/fluentexceptions Even newer: you can now install it via nuget:  `PM> Install-Package Core.Trying`

Example 1:
```C#
var configuration = new Try()
  // do not throw exceptions 
  // when action continouosly fails
  .BeQuiet(true)
  // only expectAccessViolationExceptions
  .Expect<AccessViolationException>()
  // repeat at most 5 times or until 
  // 1s of waiting time has passed
  .Repeat(5, 1000)
  // when actions fails backoff exponentially
  // e.g. first wait 10 ms then 100 ms then 1000ms
  .BackoffExponentially();

//configuration is reusable
var result = configuration.Execute(() =>
{
  /*something which potentially throws */
});

if (result)
{
  // success
  Console.Write("number of retries: ");
  Console.WriteLine(result.FailedCount);
}
else
{
  // failure
  Console.Write("time spent waiting [ms]: ");
  Console.WriteLine(result.WaitedTime);
  Console.Write("number of retries: ");
  Console.WriteLine(result.FailedCount);
  Console.Write("last throw exception message: ");
  Console.WriteLine(result.LastException.Message);
}

```
Example 2:


```C#
// default configuration handles any exception
  // repeats 4 times at most and exponentially backs off
  Try.Default.Execute(() => {
    /*some action which potentially throws*/
  });

```

let me know if you think it is useful…  Be warned that this type of repeat on exception strategy should not be applied blindly …

I developed the library because I needed it but some terminology was researched.  consulted sources:

http://msdn.microsoft.com/en-us/library/hh680905(v=pandp.50)
http://stackoverflow.com/questions/1563191/c-sharp-cleanest-way-to-write-retry-logic