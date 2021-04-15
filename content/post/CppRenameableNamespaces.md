---
title: "Renameable Namespaces using the Preprocessor"
date: 2016-08-30T23:24:46+02:00
draft: true
---

Renameable Namespaces using the Preprocessor
by thetoeb • 2014/10/14 • 0 Comments

Motivation
If you are starting to work on a library and do not know exactly how your namespaces are going end up these macro helper are for you. I have written helpers that simplify using namespaces and lets you build up your namespaces with preprocessor defines. This allows you to quickly rename your namespaces which in turn makes it alot more flexible. You can find the code on github. It is licensed under the MIT license.

The reason why I wanted to have renameable, dynamically generated namespaces was to allow me to statically link multiple versions of the same library and to achieve this I needed to to prepend a versioned namespace e.g. wrap all namespaces in another namespace. This could have been achieved by wrapping the all include files in another namespace but some edge cases did not allow me to do it this way. So I chose to make the namespaces “dynamic” (as in compile time dynamic) which I could control with a single preprocessor define.

Documentation
I provide you with the following macros:

NS_BEGIN(...)
NS_END(...)
NS(...)
NS_USE(...)  
Instead of using namespace X{ namespace Y{ ... } } you write NS_BEGIN(X,Y) ... NS_END(X,Y) these macros expand to the namespace definitions and allow you to use preprocessor defines to name your namespaces.

A nice side effect is that your code is not indented anymore by your IDE which, in my opinion, makes the code harder to read as get more and more nested namespaces. Also you can explicitly see where your namespace ends which is very helpful in long files – I always seem to get mixed up with too many braces…

Of course your personal preferences may differ, but if you refactor without expensive tools defining your namespaces with these macros helps a lot as you only have to change it once. Furthermore you could easily add a build task that replaces these macros with the hard coded namespaces if you release your source code/ headers. (or leave them in, especially if you want your library users to be able to change the namespace as well).

Besides beginning and ending a namespace you can also use NS(X,Y) to reference a namespace as it is expanded to X::Y. Another shorthand which is useful is NS_USE(X,Y) which just creates a using namespace statement: using namespace X::Y.

Of course you can also mix the macro based namespace and hard coded namespace statement to your hearts content.

Example
Here is an example application that shows you how to use these macros:

#include <cppnamespace/cppnamespace.h>
/// defines which for naming the namespaces, allows the parameterized buildup of naming schemes 
#define BASE_NAMESPACE matlib  
#define MATRIX_NAMESPACE BASE_NAMESPACE, matrix
#define VECTOR_NAMESPACE BASE_NAMESPACE, vector

NS_BEGIN(MATRIX_NAMESPACE)
// equivalent to namespace matlib{ namespace matrix{ 
struct Matrix{
  auto operator()(int i, int j)->double;
};
NS_END(MATRIX_NAMESPACE)
//equivalent to }}

NS_BEGIN(VECTOR_NAMESPACE)
struct Vector : public NS(MATRIX_NAMESPACE)::Matrix{ // a vector is a matrix the namespace is accessed via NS(...) macro
 auto operator()(int i)->double;
};

NS_END(VECTOR_NAMESPACE)

int main(){
// using directive to access Vector
 NS_USE(VECTOR_NAMESPACE);

 Vector v;
 //global qualification for matrix - also works without using the preprocessor (but makes the code more brittle) 
 ::matlib::matrix::Matrix m;

}
Limitations:

Due to NS_REDUCE you can at most nest 100 namespaces (which is in itself absurd ;))
I am happy for any critiques in form of comments, stars, upvotes, likes, etc. Especially if you find this useful let me know! I am aware there is only a niche audience for this kind of preprocessor stuff – but I do like to share :)