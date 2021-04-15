---
title: "`is_callable` type trait"
decription: "is_callable type trait"
date: 2014-07-12
draft: true
---


I’ve developed a `type_trait` for checking if a type is callable, ie has defined a single `operator()`. Also on ideone

Tell me if you like it or if you know of a better version :D

```C++
/// function traits for member functions 
// gives you the class_type, return_type and arguments tuple for any member function (const and not const)
  template<typename T>
  struct func_traits{
    static const bool is_const_call = false;
    typedef void class_type;
    typedef void return_type;
    typedef void args_tuple;
  };
  // specialization for non const call member functions
  template < typename TClass ,typename TRet, typename ... TArgs>
  struct func_traits<TRet(TClass::*)(TArgs...)>
  {
    static const bool is_const_call = false;
    typedef TClass class_type;
    typedef TRet return_type;
    typedef std::tuple<TArgs...> args_tuple;
  };
  // specialization for const call member function
  template < typename TClass, typename TRet, typename ... TArgs>
  struct func_traits<TRet(TClass::*)(TArgs...)const>
  {
    static const bool is_const_call = true;
    typedef TClass class_type;
    typedef TRet return_type;
    typedef std::tuple<TArgs...> args_tuple;
  };

// checks wether a single call operator exists by sfinae ideom
  template<typename T>
  struct is_callable{

  private:
    // if the argument type is deducable this function is used
    template<typename TX = T>
    static char check(typename func_traits<decltype(&TX::operator())>::class_type);
    // else this function is used
    static double check(...);
    static T t;
    // if first function is used the call operator exists and the size is sizeof(char) instead of sizeof(double)
    enum{ _value = sizeof(check(t)) == sizeof(char) };
  public:
    const static bool value = _value;
  };


int main() {
    // B is a functor class, A not callable
  class B{ public:void operator()(int i)const{} };
  class A{};
  // this order works  in MSVC 2013
   static_assert(is_callable<B>::value == true, "should be true");
   static_assert(is_callable<A>::value == false, "should be false");
    // 
    return 0;
}
```

Some Sources I queried when developing:

http://stackoverflow.com/questions/5100015/c-metafunction-to-determine-whether-a-type-is-callable
http://functionalcpp.wordpress.com/2013/08/05/function-traits/
… some more, can’t find…