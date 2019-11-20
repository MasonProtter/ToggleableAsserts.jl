using Test, ToggleableAsserts

function foo(u, v)
    @toggled_assert length(u) == length(v)
    1
end

@test_throws AssertionError foo([1, 2], [1])
@test_throws AssertionError("3 is an odd number!") @toggled_assert iseven(3) "3 is an odd number!"

@toggle false # toggle off assertions

@test foo([1, 2], [1]) == 1

Threads.@threads for i in 1:20
    @toggle rand(Bool)
end
