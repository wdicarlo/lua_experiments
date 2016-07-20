-- Test lazy evaluation of function parameters


local enabled = false
local counter = 1
local lprint = print

function _print(...)
    lprint(counter..": ",...)
    counter = counter + 1
end

local print = _print

function astring()
    print"gen astring"
    return "astring"
end

function afunct(a,b)
    print( "gen "..(a or "").." "..(b or ""))
    return "gen "..(a or "").." "..(b or "")
end

function lazy_concat(...)
    if enabled then
        if select("#", ...) > 1 then
            --concat
            local pars = {}
            for i,v in ipairs({...}) do
                if type(v) == "function" then
                    pars[#pars+1] = v()
                elseif type(v) == "table" and type(v[1]) == "function" then
                    local n = #v
                    pars[#pars+1] = v[1](unpack(v,2,n))
                else
                    pars[#pars+1] = v
                end
            end
            return table.concat(pars)
        else
            return ...
        end
    end
end

function test(flag)
    counter = 1
    enabled = flag
    print"---------------------------------------------------------"
    print("Test: enabled = "..tostring(flag))
    print"hello lua"
    print( enabled and "hello short circuit" or "")
    print(lazy_concat("hello world"))
    print(lazy_concat("hello world ",3," this is a good day"))
    print(lazy_concat("hello world ",3," this is a good day ", " for ", astring()))
    print(lazy_concat("hello world ",3," this is another good day ", " for ", astring))
    print(lazy_concat("hello world ",3," this is another good day for the world", " for ", {afunct, "hello", "funct"}))
    print"---------------------------------------------------------"
end

test(false)
test(true)
