function ternary(c, t, f)
  if c then
    return t
  else
    return f
  end
end

function toboolean(v)
  if type(v) == "string" then
    return ternary(v=="true", true, false)
  end
end

function booleanToString(v)
  if type(v) == "boolean" then
    return ternary(v, "true", "false")
  end
end

function table.convert2Dto1D(t)
  local tmp = {}
  for y=1, table.length(t) do
    for x=1, table.length(t[y]) do
      tmp[table.length(tmp)+1] = t[y][x]
    end
  end
  return tmp
end

function table.convert1Dto2D(t, w)
  local tmp = {}
  for i=1, #t do
    local x, y = math.wrap(i, 1, w), math.ceil(i/w)
    if tmp[y] == nil then tmp[y] = {} end
    tmp[y][x] = t[i]
  end
  return tmp
end

function table.numbertostringkeys(t)
  local result = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      result[k] = table.numbertostringkeys(v)
    else
      result[k] = v
    end
    if type(k) == "number" then
      result[tostring(k)] = result[k]
      result[k] = nil
    end
  end
  return result
end

function table.stringtonumberkeys(t)
  local result = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      result[k] = table.stringtonumberkeys(v)
    else
      result[k] = v
    end
    if type(k) == "string" and tonumber(k) ~= nil then
      result[tonumber(k)] = result[k]
      result[k] = nil
    end
  end
  return result
end

function string.split(self, inSplitPattern, outResults)
  if not outResults then
    outResults = {}
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
  while theSplitStart do
    table.insert(outResults, string.sub(self, theStart, theSplitStart-1))
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
  end
  table.insert(outResults, string.sub(self, theStart))
  return outResults
end

function io.scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function table.merge(tables)
  local result = {}
  for k, v in pairs(tables) do
    for i, j in pairs(v) do
      result[#result+1] = j
    end
  end
  return result
end

function math.approach(v, to, am)
  if v < to then 
		v = math.min(v + am, to)
  elseif v > to then
    v = math.max(v - am, to)
  end
  return v
end

function math.clamp(val, min, max)
  if min < max then
    return math.max(math.min(max, val), min)
  else
    return math.max(math.min(min, val), max)
  end
end

function math.roundDecimal(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function math.between(val, min, max)
  return val >= min and val <= max
end

function math.lerp(a,b,t)
  return (1-t)*a + t*b
end

function math.sign(x)
  if x<0 then
    return -1
  elseif x>0 then
    return 1
  else
    return 0
  end
end

function math.round(x)
  if x-math.floor(x) >= 0.5 then
    return math.ceil(x)
  else
    return math.floor(x)
  end
end

function math.randomboolean()
  return love.math.random(0, 1) == 0
end

function math.wrap(v, min, max)
  local range = max - min + 1
  v = ((v-min) % range)
  if v < 0 then
    return max + 1 + v
  else
    return min + v
  end
end

function table.contains(t, va)
  for k, v in pairs(t or {}) do
    if v == va then return true end
  end
  return false
end

function table.clone(t, cache)
  if type(t) ~= 'table' then
    return t
  end
  table.copycache = cache or {}
  if table.copycache[t] then
    return table.copycache[t]
  end
  local new = {}
  table.copycache[t] = New
  for key, value in pairs(t) do
    new[table.clone(key, table.copycache)] = table.clone(value, table.copycache)
  end
  return new
end

function table.length(t)
  local n = 0
  for k, v in pairs(t) do
    n = n + 1
  end
  return n
end

function table.containskey(t, ke)
  for k, v in pairs(t or {}) do
    if k == ke then return true end
  end
  return false
end

function table.stringtonumbervalues(t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = type(v) ~= "number" and tonumber(v) or v
  end
  return result
end

function table.removevalue(t, va)
  for k, v in pairs(t) do
    if v == va then
      t[k] = nil
    end
  end
end

function table.removevaluearray(t, va)
  local call = false
  for i=1, #t do
    if t[i] == va then
      table.remove(t, i)
      call = true
      break
    end
  end
  if call then call = nil table.removevaluearray(t, va) end
end