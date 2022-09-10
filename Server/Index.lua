local convars = Package.GetPersistentData().convars or {}
local convars_meta = {}

local function savePersistent() 
    Package.SetPersistentData("convars", convars)
end

local function getDefaultVal(type)
    if type == TYPE_BOOL then
        return false
    elseif type == TYPE_NUMBER then
        return 0
    elseif type == TYPE_STRING then
        return ""
    end
end

local function isValType(t, val)
    if type(val) == "number" then
        return t == TYPE_NUMBER
    elseif type(val) == "boolean" then
        return t == TYPE_BOOL
    elseif type(val) == "string" then
        return t == TYPE_STRING
    else
        return false
    end
end

local function typeToName(type)
    if type == TYPE_BOOL then
        return "BOOL"
    elseif type == TYPE_STRING then
        return "STRING"
    elseif type == TYPE_NUMBER then
        return "NUMBER"
    else
        return "UNKNOWN"
    end
end

local function parseType(type, s)
    if not s then
        return nil
    end

    if type == TYPE_BOOL then
        return s == "true"
    elseif type == TYPE_STRING then
        return s
    elseif type == TYPE_NUMBER then
        return tonumber(s)
    end
end

-- [[ API FUNCTIONS ]] --

TYPE_BOOL   = 0
TYPE_STRING = 1
TYPE_NUMBER = 2

function DefineConvar(type, key, name, description, default_val)
    if not type or (type < 0 and type > 2) then
        return error("Type cannot be nil or is invalid")
    end

    if not key or key == "" then
        return error("Key cannot be nil or empty")
    end
    
    if default_val and not isValType(type, default_val) then
        return error("Default value is not allowed for this type")
    end

    name = name or key
    description = description or ""
    default_val = default_val or getDefaultVal(type)

    convars_meta[key] = {
        name = name,
        description = description
    };

    if convars[key] == nil then
        convars[key] = {val = default_val, type = type}
        savePersistent()
    end

    local function get()
        return convars[key]
    end

    local function set(val)
        if not isValType(type, val) then
            return error("Given value is invalid for the convar type")
        end

        convars[key].val = val
        savePersistent()
    end

    return {get = get, set = set}
end

function GetConvars()
    local arr = {}
    for k, _ in pairs(convars_meta) do table.insert(arr, k) end
    return arr
end

function GetConvarMeta(key)
    return convars_meta[key]
end

-- [[ CONSOLE COMMANDS ]] --

Server.Subscribe("Console", function (text)
    local parts = {}
    for part in text:gmatch("%w+") do table.insert(parts, part) end

    local name = table.remove(parts, 1)
    if name:lower() ~= "convars" then
        return
    end

    if #parts <= 0 then
        local convars = GetConvars()
        print("Available ConVars: " .. table.concat(convars, ", "))
    elseif #parts == 1 then
        local key = parts[1]
        if not convars[key] then
            print("No ConVar found")
            return
        end

        local convar = convars[key]
        print(key .. " (" .. typeToName(convar.type) .. ") = " .. tostring(convar.val))
    elseif #parts == 2 then
        local key = parts[1]
        if not convars[key] then
            print("No ConVar found")
            return
        end

        local convar = convars[key]
        local val = parseType(convar.type, parts[2])
        if not val then
            print("Invalid value")
            return
        end

        convar.val = val
        savePersistent()
        print("ConVar set")
    end
end)