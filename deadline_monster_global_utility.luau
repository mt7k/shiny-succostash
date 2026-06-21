-- # Utility
local utility_module = {}

-- Constants
local MAX_INDENT_LENGTH = 7

-- Functions
function utility_module:dictionaryToString(data: {[string]: any}, indent: string)
    indent = indent or ""
    local result = "{\n"

    if #indent / 4 > MAX_INDENT_LENGTH then
        result = result.. indent.. "MAX_INDENT_LENGTH reached - start your search here to see this value\'s contents\n"
    else
        for key: any, value: any in data do
            local keyType = type(key)
            local valueType = type(value)

            if valueType == "table" then
                local next_value = self:dictionaryToString(value, indent.. "    ")
                result = result.. string.format("%s    %s = %s", indent, key, next_value)
            else
                local formattedKey = keyType == "string" and ("\"".. key.. "\"") or tostring(key)
                local formattedValue = valueType == "string" and ("\"".. value.. "\"") or tostring(value)
                result = result.. string.format("%s    %s = %s,\n", indent, formattedKey, formattedValue)
            end
        end
    end
    
    result = result.. indent.. "}\n"
    
    return result
end

shared["utility_module"] = utility_module

return utility_module