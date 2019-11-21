module ToggleableAsserts

export @toggled_assert, toggle

assert_toggle() = true

macro toggled_assert(cond, text=nothing)
    if text==nothing
        assert_stmt = esc(:(@assert $cond))
    else
        assert_stmt = esc(:(@assert $cond $text))
    end
    :(assert_toggle() ? $assert_stmt  : nothing)
end

const toggle_lock = ReentrantLock()


function toggle(enable::Bool)
    lock(toggle_lock) do
        @eval ToggleableAsserts assert_toggle() = $enable
        on_or_off = enable ? "on." : "off."
        @info "Toggleable asserts turned "*on_or_off
    end
end

end # module
