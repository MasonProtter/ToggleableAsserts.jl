module ToggleableAsserts

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

macro toggle(bool)
    bool ∈ [:true, :false] || error("Toggle only takes true or false literals.")
    quote
        lock(toggle_lock) do
            @assert $bool isa Bool
            @eval ToggleableAsserts assert_toggle() = $bool
            on_or_off = $bool ? "on." : "off."
            @info "Toggleable asserts turned "*on_or_off
        end
    end
end

export @toggled_assert, @toggle

end # module
