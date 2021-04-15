---
title: "Heterogeneous Package Search and Retrieval in CMake"
decriptions: ""
date: 2015-02-04
draft: true
---


Finding and Retrieving third party sources, tools and binaries is currently a hot subject for C++. There are quite a few solutions (biicode, cpm, hunter, …) Also there is github, bitbucket, source balls etc. Further there are many package managers for many different platforms which also can contain packages (apt-get, chocolatey, nuget, npm, pip, ….). So everything is very decentralized and heterogeneous.

On the other hand there is CMake the standard when it comes to creating platform independent projects for various build and developer environments. (of course it is not the only build tool but it is the standard for platform independent C/C++ projects) Most notably it generates MSBuild for Visual Studio and MAKE output which are the most commonly used build systems. CMake is as platform independent as it comes.

For me the need arose to get multiple packages for a project I am working on. My list of dependencies were partially local and partially remote (local project a, local project b, Eigen3, tinyxml2, boost, etc…) I wanted to write my project configuration files in a way that I do not have to copy all the third party tools and sources into my repository but also I did not want the client to be responsible for retrieving them either.

The first part of solving this problem is to be able to find and retrieve packages with platform independent CMake code from all kinds of package sources and that is what this blog post is about. The second part of the solution is to be able not only to retrieve packages but also their dependencies (package management). The third part is the only part specific to C++ – Combining packages in a way that everything builds correctly without tons of testing and configuration.

So my Idea is to abstract over all package sources (current existing ones and ones which do not exist yet) and allow the CMake user to easily query for them as well as to download the data and meta data necessary to configure them.

In the rise of this task I created a cmake library (formerly known as oo-cmake and now audaciously called cmakepp) It has now reached a state which will make it a very useful tool for all users of CMake it is written in pure cmake >=2.8.12 and extends CMake’s capabilities quite considerably (see my other blog posts or the README file).

cmakepp now contains package sources for github bitbucket web archives local archives local directorys git subversion mercurial and more to come (apt get, nuget, npm, are planned)

These can be used to simply search and download packages.

After all of this text I’m sure you want to see how to use it. So I’ll show you a simple Example:


```cmake

cmake_minimum_required(VERSION 2.8.12)
## CMakeLists.txt for a simple project 
set(current_dir "${CMAKE_CURRENT_SOURCE_DIR}")
## get cmakepp
if(NOT EXISTS "${current_dir}/cmakepp.cmake")
  file(DOWNLOAD "https://github.com/toeb/cmakepp/releases/download/v0.0.3/cmakepp.cmake" "${current_dir}/cmakepp.cmake")
endif()

include("${current_dir}/cmakepp.cmake")

if(NOT EXISTS ${current_dir}/dependencies/eigen3)
 message("installing Eigen3 from bitbucket")
 pull_package(eigen/eigen?tag=3.1.0 dependencies/eigen3)
 ans(package_handle)
 if(NOT package_handle)
  message(FATAL_ERROR "could not pull Eigen3")
 endif()
 ## print the package information returned
 json_print(${package_handle})
endif()

## from here on everything can be a normal cmakelists file
project(myproject)

include_directories("dependencies/eigen3")

fwrite("main.cpp" "
#include <iostream>
#include <Eigen/Dense>
using Eigen::MatrixXd;
int main()
{
  MatrixXd m(2,2);
  m(0,0) = 3;
  m(1,0) = 2.5;
  m(0,1) = -1;
  m(1,1) = m(1,0) + m(0,1);
  std::cout << m << std::endl;
}
")

add_executable(myexe "main.cpp")
```

After you write and configure this CMakeLists.txt you are able to work with you project as before. Of course the sample is overly simple – because I do not show you how this works with non-header-only libraries and installing and multiple targets,… But it is just to give you an idea of how things work.

The only prerequisites are cmake >= 2.8.12 and a build system e.g. MSVC or GCC

To get this to work copy paste the code into a new directory in a file called CMakeLists.txt then type:

```
> mkdir build
> cd build
build> cmake ..
build> cmake --build .
build> <code to run executable e.g. ./Debug/myexe.exe under windows>
This might seem a bit of overkill – however when you install cmakepp you are not limited to using it in your CMakeLists.txt you can also invoke it through the commandline. Consider the following console log which work on your console of choice like bash powershell cmd.
```

The following lists all packages available which match the uri toeb

```
PS> cmakepp query_package toeb
[
 "github:toeb/adolc",
 "github:toeb/autogui",
 "github:toeb/Blocks",
 "github:toeb/cgen",
 "github:toeb/CMake",
 "github:toeb/cmakepp",
 "github:toeb/core.common",
 "github:toeb/core.filesystem",
 "github:toeb/Core.FileSystem.PathUtilities",
 "github:toeb/cpm",
 "github:toeb/cpm-adolc",
 "github:toeb/cpm-boost",
 "github:toeb/cpm-boost-config",
 "github:toeb/cpm-boost-graph",
 "github:toeb/cpm-eigen",
 "github:toeb/cpm-module",
 "github:toeb/cpm-modules",
 "github:toeb/cpp.reflect",
 "github:toeb/cppaccessor",
 "github:toeb/cppdynamic",
 "github:toeb/cppnamespace",
 "github:toeb/cps",
 "github:toeb/cps-example",
 "github:toeb/cps_sample",
 "github:toeb/CTestTestAdapter",
 "github:toeb/ctmpl",
 "github:toeb/cts",
 "github:toeb/cutil",
 "github:toeb/cutil-playground",
 "github:toeb/cutil-templates",
 "bitbucket:toeb/cmodule",
 "bitbucket:toeb/rbdl",
 "bitbucket:toeb/rbdl",
 "bitbucket:toeb/test_repo_hg",
 "bitbucket:toeb/test_repo_git"
]
```

The following returns all available package information for a specific package uri.
```
PS> cmakepp resolve_package toeb/cmakepp
{
 "package_descriptor":{
  "id":"cmakepp",
  "version":"0.0.0",
  "description":"a cmake enhancement suite",
  "license":"MIT",
  "author":"Tobias P. Becker"
 },
 "uri":"github:toeb/cmakepp",
 "repo_descriptor":{
  "id":16892201,
  "name":"cmakepp",
  "full_name":"toeb/cmakepp",
  "owner":{
   "login":"toeb",
   "id":1451956,
   "avatar_url":"https://avatars.githubusercontent.com/u/1451956?v=3",
   "gravatar_id":null,
   "url":"https://api.github.com/users/toeb",
   "html_url":"https://github.com/toeb",
   "followers_url":"https://api.github.com/users/toeb/followers",
   "following_url":"https://api.github.com/users/toeb/following{/other_user}",
   "gists_url":"https://api.github.com/users/toeb/gists{/gist_id}",
   "starred_url":"https://api.github.com/users/toeb/starred{/owner}{/repo}",
   "subscriptions_url":"https://api.github.com/users/toeb/subscriptions",
   "organizations_url":"https://api.github.com/users/toeb/orgs",
   "repos_url":"https://api.github.com/users/toeb/repos",
   "events_url":"https://api.github.com/users/toeb/events{/privacy}",
   "received_events_url":"https://api.github.com/users/toeb/received_events",
   "type":"User",
   "site_admin":false
  },
  "private":false,
  "html_url":"https://github.com/toeb/cmakepp",
  "description":"An Enhancement Suite for the CMake Build System",
  "fork":false,
  "url":"https://api.github.com/repos/toeb/cmakepp",
  "forks_url":"https://api.github.com/repos/toeb/cmakepp/forks",
  "keys_url":"https://api.github.com/repos/toeb/cmakepp/keys{/key_id}",
  "collaborators_url":"https://api.github.com/repos/toeb/cmakepp/collaborators{/collaborator}",
  "teams_url":"https://api.github.com/repos/toeb/cmakepp/teams",
  "hooks_url":"https://api.github.com/repos/toeb/cmakepp/hooks",
  "issue_events_url":"https://api.github.com/repos/toeb/cmakepp/issues/events{/number}",
  "events_url":"https://api.github.com/repos/toeb/cmakepp/events",
  "assignees_url":"https://api.github.com/repos/toeb/cmakepp/assignees{/user}",
  "branches_url":"https://api.github.com/repos/toeb/cmakepp/branches{/branch}",
  "tags_url":"https://api.github.com/repos/toeb/cmakepp/tags",
  "blobs_url":"https://api.github.com/repos/toeb/cmakepp/git/blobs{/sha}",
  "git_tags_url":"https://api.github.com/repos/toeb/cmakepp/git/tags{/sha}",
  "git_refs_url":"https://api.github.com/repos/toeb/cmakepp/git/refs{/sha}",
  "trees_url":"https://api.github.com/repos/toeb/cmakepp/git/trees{/sha}",
  "statuses_url":"https://api.github.com/repos/toeb/cmakepp/statuses/{sha}",
  "languages_url":"https://api.github.com/repos/toeb/cmakepp/languages",
  "stargazers_url":"https://api.github.com/repos/toeb/cmakepp/stargazers",
  "contributors_url":"https://api.github.com/repos/toeb/cmakepp/contributors",
  "subscribers_url":"https://api.github.com/repos/toeb/cmakepp/subscribers",
  "subscription_url":"https://api.github.com/repos/toeb/cmakepp/subscription",
  "commits_url":"https://api.github.com/repos/toeb/cmakepp/commits{/sha}",
  "git_commits_url":"https://api.github.com/repos/toeb/cmakepp/git/commits{/sha}",
  "comments_url":"https://api.github.com/repos/toeb/cmakepp/comments{/number}",
  "issue_comment_url":"https://api.github.com/repos/toeb/cmakepp/issues/comments/{number}",
  "contents_url":"https://api.github.com/repos/toeb/cmakepp/contents/{+path}",
  "compare_url":"https://api.github.com/repos/toeb/cmakepp/compare/{base}...{head}",
  "merges_url":"https://api.github.com/repos/toeb/cmakepp/merges",
  "archive_url":"https://api.github.com/repos/toeb/cmakepp/{archive_format}{/ref}",
  "downloads_url":"https://api.github.com/repos/toeb/cmakepp/downloads",
  "issues_url":"https://api.github.com/repos/toeb/cmakepp/issues{/number}",
  "pulls_url":"https://api.github.com/repos/toeb/cmakepp/pulls{/number}",
  "milestones_url":"https://api.github.com/repos/toeb/cmakepp/milestones{/number}",
  "notifications_url":"https://api.github.com/repos/toeb/cmakepp/notifications{?since,all,participating}",
  "labels_url":"https://api.github.com/repos/toeb/cmakepp/labels{/name}",
  "releases_url":"https://api.github.com/repos/toeb/cmakepp/releases{/id}",
  "created_at":"2014-02-16T19:26:18Z",
  "updated_at":"2015-02-04T15:15:40Z",
  "pushed_at":"2015-02-04T15:15:40Z",
  "git_url":"git://github.com/toeb/cmakepp.git",
  "ssh_url":"git@github.com:toeb/cmakepp.git",
  "clone_url":"https://github.com/toeb/cmakepp.git",
  "svn_url":"https://github.com/toeb/cmakepp",
  "homepage":null,
  "size":2936,
  "stargazers_count":49,
  "watchers_count":49,
  "language":"Shell",
  "has_issues":true,
  "has_downloads":true,
  "has_wiki":true,
  "has_pages":false,
  "forks_count":6,
  "mirror_url":null,
  "open_issues_count":11,
  "forks":6,
  "open_issues":11,
  "watchers":49,
  "default_branch":"master",
  "network_count":6,
  "subscribers_count":8
 },
 "package_source":{
  "source_name":"github",
  "pull":"package_source_pull_github",
  "query":"package_source_query_github",
  "resolve":"package_source_resolve_github"
 }
}
```

This concludes this simple blog post – It just scrapes at the edges of what you can do and if I have piqued your interest please visit the the project’s github package https://github.com/toeb/cmakepp were I try to document everything vigorously and also try to explain my reasoning for the choices I make in the README file. Please let me know if you have any suggestions or bugs or feature requests or if you want to help 🙂 This software is free and under the MIT license.