using Test, ToggleableAsserts


function foo(u, v)
    @toggled_assert length(u) == length(v)
    1
end

@test_throws AssertionError foo([1, 2], [1])

@toggle false

@test foo([1, 2], [1]) == 1