[![Build Status](https://travis-ci.com/MasonProtter/ToggleableAsserts.jl.svg?branch=master)](https://travis-ci.com/MasonProtter/ToggleableAsserts.jl)

To install, simply do
```julia
using Pkg; pkg"add https://github.com/MasonProtter/ToggleableAsserts.jl.git"
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
julia> @toggle false
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
