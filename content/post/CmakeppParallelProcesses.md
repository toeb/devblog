---
title: "Parallel Processes in CMake"
date: 2014-12-16
description: ""
draft: true
---


If you need to check out multiple large repositories or build and install large separate projects you might want to use parallel processes in CMake. Dividing your tasks to use multiple CMake and or other processes can speed up your build and configuration steps immensely.

Since all cmake host OSs support multitasking from the command line it is possible to use cmake to contol them in turn. Using this approach I implemented a ‘platform independent’ control mechanism for starting, killing, querying and waiting for processes. Only the very basic functions are platform specific and the others are based on the abstraction layer that they provide.

As of now platforms which support bash or powershell are supported.

The functions are part of my cmake enhancement suite – oocmake and can be found at my github repository https://github.com/toeb/oo-cmake. Please report any issues you might have or contribute. (I am also happy if you just give me feedback)

Installation is very easy and described in the README.md

Examples

Of course example are the easiest to show what is possible therefore I provided two:

This example starts a script into three separate cmake processes. The program ends when all scripts are done executing.

```cmake
# define a script which counts to 10 and then 
# note that a fresh process means that cmake has not loaded oocmake
set(script "
foreach(i RANGE 0 10)
  message(\${i})
  execute_process(COMMAND \${CMAKE_COMMAND} -E sleep 1)
endforeach()
message(end)
")

# start each script - fork_script returns without waiting for the process to finish.
# a handle to the created process is returned.
process_start_script("${script}")
ans(handle1)
process_start_script("${script}")
ans(handle2)
process_start_script("${script}")
ans(handle3)

# wait for every process to finish. returns the handles in order in which the process finishes
process_wait_all(${handle1} ${handle2} ${handle3})
ans(res)

## print the process handles in order of completion
json_print(${res})
This example shows a slightly less useless case: Downloading multiple ‘large’ files in parallel to save time

  ## define a function which downloads  
  ## all urls specified to the current dir
  ## returns the path for every downloaded files
  function(download_files_parallel)
    ## get current working dir
    pwd()
    ans(target_dir)

    ## process start loop 
    ## starts a new process for every url to download
    set(handles)
    foreach(url ${ARGN})
      ## start download by creating a cmake script
      process_start_script("
        include(${oocmake_base_dir}/oo-cmake.cmake) # include oocmake
        download(\"${url}\" \"${target_dir}\")
        ans(result_path)
        message(STATUS ${target_dir}/\${result_path})
        ")
      ans(handle)
      ## store process handle 
      list(APPEND handles ${handle})
    endforeach()

    ## wait for all downloads to finish
    process_wait_all(${handles})

    set(result_paths)
    foreach(handle ${handles})
      ## get process stdout
      process_stdout(${handle})
      ans(output)

      ## remove '-- ' from beginning of output which is
      ## automatically prependend by message(STATUS) 
      string(SUBSTRING "${output}" 3 -1 output)

      ## store returned file path
      list(APPEND result_paths ${output})

    endforeach()

    ## return file paths of downloaded files
    return_ref(result_paths)
  endfunction()


  ## create and goto ./download_dir
  cd("download_dir" --create)

  ## start downloading files in parallel by calling previously defined function
  download_files_parallel(
    http://www.cmake.org/files/v3.0/cmake-3.0.2.tar.gz
    http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
  )
  ans(paths)


  ## assert that every the files were downloaded
  foreach(path ${paths})
    assert(EXISTS "${path}")
  endforeach()


```



## Functions and Datatypes

```
datatypes
<process handle> ::= { state:<process state> , pid:<process id> } process handle is a runtime unique map which is used to address a process. The process handle may contain more properties than specified – only the specified ones are available on all systems – these properties contain values which are implementation specific.
<process info> ::= { } a map containing verbose information on a proccess. only the specified fields are available on all platforms. More are available depending on the OS you use. You should not try to use these without examining their origin / validity.
<process state> ::= "running"|"terminated"|"unknown"
<process id> ::= <string> a unspecified systemwide unique string which identifies a process (normally a integer)
platform specific low level functions
process_start(<process start info?!>):<process handle> platfrom specific function which starts a process and returns a process handle
process_kill(<process handle?!>) platform specific function which stops a process.
process_list():<process handle ...> platform specific function which returns a process handle for all running processes on OS.
process_info(<process handle?!>):<process info> platform specific function which returns a verbose process info
process_isrunning(<process handle?!>):<bool> returns true iff process is running.
process_timeout(<n:<seconds>>):<process handle> starts a process which times out in <n> seconds.
process_wait(<process handle~> [--timeout <n:seconds>]):<process handle> waits for the specified process to finish or the specified timeout to run out. returns null if timeout runs out before process finishes.
process_wait_all(<process handle?!...> <[--timeout <n:seconds>] [--quietly]):<process handle ...> waits for all specified process handles and returns them in the order that they completed. If the --timeout <n> value is specified the function returns as soon as the timeout is reached returning only the process finished up to that point. The function normally prints status messages which can be supressed via the --quietly flag.
process_wait_any(<process handle?!...> <?"--timeout" <n:<seconds>>> <?"--quietly">):<?process handle> waits for any of the specified processes to finish, returning the handle of the first one to finished. If --timeout <n> is specified the function will return null after n seconds if no process completed up to that point in time. You can specify --quietly if you want to suppress the status messages.
process_stdout(<process handle~>):<string> returns all data written to standard output stream of the process specified up to the current point in time
process_stderr(<process handle~>):<string> return all data written to standard error stream of the process specified up to the current point in time
process_return_code(<process handle~>):<int?> returns nothing or the process return code if the process is finished
process_start_script(<cmake code>):<process handle> starts a separate cmake process which runs the specified cmake code.
Inter Process Communication
To communicate with you processes you can use any of the following well known mechanisms

Environment Variables
the started processes have access to you current Environment. So when you call set(ENV{VAR} value) before starting a process that process will have read access to the variable $ENV{VAR}
Command Line Arguments
all variables passed to start_process will be passed allong
Command Line Variables are sometimes problematic as they must be escaped correctly and this does not always happen as expected. So you might want to choose another mechanism to transmit complex data to your process
Command Line Variables are limited by their string length depending on you host os.
Files
Files are the easiest and safest way to communicate large amounts of data to another process. If you can try to use file communication
stderr, stdout
The output of a process started with start_process becomes available to you when the process ends at latest, You can choose to poll stdout and take data as soon as it is written to the output streams
return code
the returns code tells you how you process finished and is often enough result information for a process you start
Caveats
process starting is slow – it can take seconds (it takes 900ms on my machine). The task needs to be a very large one for it to compensate the overhead.
parallel processes use platform specific functions – It might cause problems on less well tested OSs and some may not be supported. (currently only platforms with bash or powershell are supported ie Windows and Linux)
```