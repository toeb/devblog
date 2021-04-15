---
title: "dynamically calling “any” thing in C++"
date: 2016-08-30T23:24:46+02:00
draft: true
---

dynamically calling “any” thing in C++
by thetoeb • 2014/07/15 • 0 Comments

Extending upon boost’s any class which stores a type and a void ptr to any type of value, I created a callable version were you can assign any function, lambda, memberfunction etc. to the any and call it dynamically. This is a basic and important step for runtime reflection which I’m currently working on. Tell me if you like what I did and if you have any improvements.

You can look at the running example at ideone

// example
#include<assert.h>
using namespace nspace;
int add(int i, int j){
  return i + j;
}
int main(){

  // call a lambda (or any other functor)
  {
    any uut = [](int i, int j){ return i + j; };
    assert(uut(4, 1).as<int>() == 5);
  }
  // call a std function
  {
    any uut = std::function<int(int, int)>([](int i, int j){ return i + j; });
    assert(uut(3, 2).as<int>() == 5); // uut(3,2) is equivalent to uut({3,2}), uut(std::vector<any>{3,2})
  }
  // call a standard c function
  {
    any uut = &add;
    assert(uut(4, 2).as<int>() == 6);
  }
  // call a member function
  {
    struct MyType{ int val; MyType(int val) :val(val){} int add(int i, int j){ return i + j + val; } };
    any uut = &MyType::add;
    // need to specify an object to bind for member function pointer
    auto result = uut(std::make_shared<MyType>(3), 2, 1);
    assert(result.as<int>() == 6);
  }


}