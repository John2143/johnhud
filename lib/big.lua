--library for large numbers
--its not pretty but it works

local   sub,        len,        lower =
        string.sub, string.len, string.lower

local   max     =
        math.max

local alpha = {}
do --allow alphabet to be garbage collected
    local alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    for i = 1, alphabet:len() do
        alpha[sub(alphabet, i, i)] = i - 1 --0 = 0, 1 = 1, ..., a = 10, b = 11, ...
    end
end

local xor = function(a, b)
    return a and not b or not a and b
end


local _num = {}
local numfunc = {}
local function emptyNumber(base)
    local t = {
        base = base,
        neg = false,
        maxind = 0,
    }
    setmetatable(t, _num)
    return t
end
local function copy(number)
    local new = {}
    for i,v in pairs(number) do
        new[i] = v
    end
    setmetatable(new, _num)
    return new
end

local num = function(strrep, base)
    strrep = lower(strrep)
    local ret = emptyNumber(base or 10)
    for i = 1, len(strrep) do
        local value = alpha[sub(strrep, -i, -i)] or 0--use -i to index from end
        if value > base then error(2) end
        ret[i] = value
    end
    return ret
end

local function getn(a)
    if a.maxind and a[a.maxind] ~= 0 then
        return a.maxind
    end
    local maxn = 0
    for i,v in pairs(a) do
        if type(i) == "number" then
            if v ~= 0 then
                maxn = max(maxn, i)
            end
        end
    end
    return maxn
end

local function size(a, b)
    return max(getn(a), getn(b))
end

function numfunc.mul(a, b)
    if type(b) == "number" then
        b = num(tostring(b), 10)
    end
    local base = max(a.base, b.base)
    local carry = 0
    local bsize = getn(b)
    local tosum = {}
    for i = 1, getn(a) do
        if a[i] > 0 then
            local lsum = emptyNumber(base)
            for v = 1, bsize do
                local add = a[i] * b[v] + carry
                if add >= base then
                    carry = math.floor(add/base)
                    add = add % base
                else
                    carry = 0
                end
                lsum[v + i - 1] = add
            end
            if carry ~= 0 then
                local startop = bsize + i
                repeat
                    lsum[startop] = carry % base
                    carry = math.floor(carry/base)
                until carry == 0
            end
            table.insert(tosum, lsum)
        end
    end
    local product = emptyNumber(base)
    product.neg = xor(a.neg, b.neg)
    for i,v in ipairs(tosum) do
        product = product + v
    end
    return product
end
function numfunc.doadd(a, b)
    if type(b) == "number" then
        b = num(tostring(b), 10)
    end
    local base = max(a.base, b.base)
    local product = emptyNumber(base)
    local carry = 0
    local endop = size(a, b)

    for i = 1, endop do
        local add = a[i] + b[i] + carry
        if add >= base then
            carry = 1
            add = add % base
        else
            carry = 0
        end
        product[i] = add
    end
    if carry ~= 0 then
        product[endop + 1] = 1
    end
    return product
end
function numfunc.dosub(arg1, arg2)
    local a,b,endneg
    if arg1:compare(arg2) == -1 then
        a,b = arg2, arg1
        endneg = true
    else
        a,b = arg1, arg2
    end
    if type(b) == "number" then
        b = num(tostring(b), 10)
    end
    local base = max(a.base, b.base)
    local product = emptyNumber(base)
    local take = 0
    local endop = size(a, b)
    for i = 1, endop do
        local res = a[i] - b[i] - take
        if res < 0 then
            take = 1
            res = base + res
        else
            take = 0
        end
        product[i] = res
    end
    if take ~= 0 then
        product[endop + 1] = product[endop + 1] - 1
    end
    product.neg = endneg
    return product
end
function numfunc.div(a, b)
    local result = emptyNumber(a.base)
    local timesin = 0
    local curnum = 0
    local size = getn(a)
    local remainder
    for i = size, 1, -1 do
        curnum = curnum + a[i]
        local startnum = curnum
        local timesin = 0
        while(true) do
            local newval = curnum - b
            if newval >= 0 then
                curnum = curnum - b
                timesin = timesin + 1
            else
                break
            end
        end
        if timesin > 0 then
            result[i] = timesin
            curnum = startnum - b*timesin
        end
        if i ~= 1 then curnum = curnum * a.base end --if i == 1 then this is the remainder
    end
    result.neg = xor(a.neg, b < 0)
    return result, curnum
end
function numfunc.compare(a, b) --ignores negative for now
    for i = size(a, b), 1, -1 do
        if a[i] > b[i] then
            return 1
        elseif a[i] < b[i] then
            return -1
        end
    end
    return 0
end
function numfunc.value(a)
    local size = getn(a)
    local realvalue = 0
    for i = 1, size do
        realvalue = realvalue + a[i]*(a.base^(i-1)) -- this will overflow and be inaccurate
    end
    return realvalue
end
function numfunc.print(a)
    local size = getn(a)
    local tab = {}
    for i = size, 1, -1 do
        table.insert(tab, a[i])
    end
    return table.concat(tab)
end
function numfunc.unm(a)
    local ret = copy(a)
    ret.neg = not ret.neg
    return ret
end
function numfunc.lt(a, b)
    return a:compare(b) == -1
end
function numfunc.gt(a, b)
    return a:compare(b) == 1
end
function numfunc.ge(a, b)
    return not a:lt(b)
end
function numfunc.le(a, b)
    return not a:gt(b)
end
function numfunc.eq(a, b)
    return a:compare(b) == 0
end
function numfunc.makeneg(a, is)
    a.neg = is
    return a
end
local function chooseOP(a, b, sub)
    local same = not xor(a.neg, b.neg)
    if same then
        if sub then
            if a.neg then
                return numfunc.dosub(b, a) -- -a - -b = b - a
            else
                return numfunc.dosub(a, b) -- a - b
            end
        else
            if a.neg then
                return numfunc.doadd(a, b):makeneg(true) -- -a + -b = -(a + b)
            else
                return numfunc.doadd(a, b) -- b + a
            end
        end
    else
        if a.neg then
            if sub then
                return numfunc.doadd(a, b) -- -a - b
            else
                return numfunc.dosub(b, a) -- -a + b = b - a
            end
        else
            if sub then
                return numfunc.doadd(a, b) -- a - -b = a + b
            else
                return numfunc.dosub(a, b) -- a + -b = a - b
            end
        end
    end
end
numfunc.add = function(a, b)
    return chooseOP(a, b, false)
end
numfunc.sub = function(a, b)
    return chooseOP(a, b, true)
end

_num.__add = numfunc.add
_num.__sub = numfunc.sub
_num.__mul = numfunc.mul
_num.__div = numfunc.div

_num.__lt = numfunc.lt
_num.__gt = numfunc.gt
_num.__ge = numfunc.ge
_num.__le = numfunc.le
_num.__eq = numfunc.eq

_num.__tostring = function(t)
    return "("..(t.neg and "-" or "+")..("%sb%s)"):format(t:print(), t.base)
end

_num.__index = function(tab, ind)
    return numfunc[ind] or 0
end
_num.__newindex = function(tab, ind, val)
    if type(ind) == "number" then
        if ind > (tab.maxind or 0) then tab.maxind = ind end
    end
    rawset(tab, ind, val)
end

jhud.bignum = num
