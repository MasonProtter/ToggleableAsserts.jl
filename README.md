[![Build Status](https://travis-ci.com/MasonProtter/ToggleableAsserts.jl.svg?branch=master)](https://travis-ci.com/MasonProtter/ToggleableAsserts.jl)

To install, simply do
```julia
julia> ]

(v1.x) pkg> add ToggleableAsserts
```
at the julia prompt.

# ToggleableAsserts

Suppose we have a function with an assertion we only want to be on while debugging:
```julia
using ToggleableAsserts

function foo(u, v)
    @toggled_assert length(u) == length(v)
    1
end
```
We can now make sure our assertions work:
```julia
julia> foo([1, 2], [1])
ERROR: AssertionError: length(u) == length(v)
Stacktrace:
 [1] foo(::Array{Int64,1}, ::Array{Int64,1}) at ./REPL[1]:2
 [2] top-level scope at REPL[2]:1

```
and also turn them off
```julia
julia> toggle(false)
[ Info: Toggleable asserts turned off.

julia> foo([1, 2], [1])
1
```
Once assertions are turned off, any function depending on them is recompiled with the assertions removed. For instance, the LLVM code for `foo` now simply returns `1` without any bounds checking at runtime:
```julia
julia> @code_llvm foo([1,2], [1])
;  @ REPL[1]:2 within `foo'
define i64 @julia_foo_16854(%jl_value_t addrspace(10)* nonnull align 16 dereferenceable(40), %jl_value_t addrspace(10)* nonnull align 16 dereferenceable(40)) {
top:
  ret i64 1
}

```


________

Just like the standard `@assert` macro, you can add custom error text to a `@toggled_assert`:

```julia
julia> @toggled_assert iseven(3) "3 is an odd number!"
ERROR: AssertionError: 3 is an odd number!
Stacktrace:
 [1] top-level scope at REPL[21]:1
```

### Safety
If you try to set `toggle` outside of the global scope, you may suffer world-age issues until you return to the global scope. e.g.
```julia
julia> function bar()
           toggle(false)
           foo([1, 2], [1])
           toggle(true)
           foo([1, 2], [1])    
       end
bar (generic function with 1 method)

julia> bar()
[ Info: Toggleable asserts turned off.
[ Info: Toggleable asserts turned on.
1

julia> foo([1, 2], [1])
ERROR: AssertionError: length(u) == length(v)
Stacktrace:
 [1] foo(::Array{Int64,1}, ::Array{Int64,1}) at ./REPL[45]:2
 [2] top-level scope at REPL[48]:1
```
Hence, it should be preferred to only use `toggle` in the global scope.

### Attribution

This isn't my idea, I just packaged it up. The idea came from [this Julia Discourse thread](https://discourse.julialang.org/t/assert-alternatives/24775/14)
