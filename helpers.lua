local api = require("api")
local defaultSettings = require('role_identifier/util/default_settings')
local classes = require('role_identifier/util/classes')
local CANVAS
local function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if string.lower(value) == string.lower(val) then return true end
    end

    return false
end

local function getSettings(cnv)
    if cnv ~= nil then CANVAS = cnv end
    local settings = api.GetSettings("role_identifier")
    -- loop for set default settings if not exists
    for k, v in pairs(defaultSettings) do
        if settings[k] == nil then settings[k] = v end
    end
    -- set settings page
    -- settings.s_options = {
    --     show_class_name = {
    --         titleStr = "Show class name",
    --         controlStr = {"0", "1"}
    --     },
    --     font_size = {
    --         titleStr = "Class name font size",
    --         controlStr = {"8", "30"}
    --     },
    --     icon_size = {titleStr = "Icon size", controlStr = {"10", "100"}},

    --     icon_offset_x = {
    --         titleStr = "Icon offset X",
    --         controlStr = {"-200", "200"}
    --     },
    --     icon_offset_y = {
    --         titleStr = "Icon offset Y",
    --         controlStr = {"-200", "200"}
    --     },
    --     class_name_ofsset_x = {
    --         titleStr = "Class name offset X",
    --         controlStr = {"-100", "100"}
    --     },
    --     class_name_ofsset_y = {
    --         titleStr = "Class name offset Y",
    --         controlStr = {"-100", "100"}
    --     }
    -- }
    return settings
end

local function updateSettings()
    api.SaveSettings()
    api.Log:Info('[RI] Settings saved')
    local settings = getSettings()
    CANVAS.OnSettingsSaved()
    return settings
end

local function getClassName(classTable)
    local className = ''
    local tree1, tree2, tree3 = classTable['1'] - 1, classTable['2'] - 1,
                                classTable['3'] - 1
    local knownClassName = classes[tree1 .. tree2 .. tree3]
    if knownClassName ~= nil then return knownClassName end
    return className
end

-- trim string function 
local function trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

local function splitString(input, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for word in string.gmatch(input, pattern) do
        table.insert(result, trim(word))
    end
    return result
end

local helpers = {
    hasValue = hasValue,
    getSettings = getSettings,
    updateSettings = updateSettings,
    getClassName = getClassName,
    splitString = splitString
}
return helpers
