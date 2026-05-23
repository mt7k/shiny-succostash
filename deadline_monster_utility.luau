-- # Utility
local utility_module = {}

-- Constants
local MAX_INDENT_LENGTH = 28

-- Functions
function utility_module:recursivePrint(data, indent)
    indent = indent or ""
    for key, value in data do
        local valueType = type(value)

        if string.len(indent) > MAX_INDENT_LENGTH then
            print("-- -- -- MAX DEPTH REACHED ... going back")
        elseif valueType == "table" and key ~= "changed" then
            print(indent .. tostring(key) .. ": {")
            self:recursivePrint(value, indent .. "    ")
            print(indent .. "}")
        else
            -- Otherwise, print the key-value pair
            print(indent .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function utility_module:recursiveSearchToString(data, indent)
    local finalOutput = ""
    indent = indent or ""
    for key, value in data do
        local valueType = type(value)

        if string.len(indent) > MAX_INDENT_LENGTH then
            finalOutput = finalOutput.. "-- -- -- MAX DEPTH REACHED ... going back\n"
        elseif valueType == "table" and key ~= "changed" then
            finalOutput = finalOutput.. indent .. tostring(key) .. ": {" .. "\n"
            finalOutput = finalOutput.. self:recursiveSearchToString(value, indent .. "    ")
            finalOutput = finalOutput.. indent .. "}" .. "\n"
        else
            finalOutput = finalOutput.. indent .. tostring(key) .. ": " .. tostring(value) .. "\n"
        end
    end

    return finalOutput
end

return utility_module