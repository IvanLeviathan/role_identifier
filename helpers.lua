local api = require("api")
local defaultSettings = require('role_identifier/util/default_settings')
local classes = require('role_identifier/util/classes')
local sets = require('role_identifier/util/set_buffs')
local CANVAS
local function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if string.lower(value) == string.lower(val) then return true end
    end

    return false
end

local function getGearIconForTarget()
    local buffCount = api.Unit:UnitBuffCount("target")
    for i = 1, buffCount do
        local buff = api.Unit:UnitBuff("target", i)
        if buff and buff.buff_id then
            if sets[buff.buff_id] then return sets[buff.buff_id] end
        end
    end
    return nil;
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
    api.Log:Info('Role Identifier settings saved')
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
-- Checking if a table contains a value by pairs, not ipairs
local function tableContainsPairs(tbl, checkFor)
    for i, value in pairs(tbl) do if value == checkFor then return true end end
    return false
end

local function getMainSkillsetName(unitClassTable)
    local classMappings = {
        "Battlerage", "Witchcraft", "Defense", "Auramancy", "Occultism",
        "Archery", "Sorcery", "Shadowplay", "Songcraft", "Vitalism"
    }
    -- Prioritizing different skill icons
    if tableContainsPairs(unitClassTable, 6) then
        return 6
    elseif tableContainsPairs(unitClassTable, 10) then
        return 10
    elseif tableContainsPairs(unitClassTable, 7) then
        return 7
    elseif tableContainsPairs(unitClassTable, 1) then
        return 1
    elseif tableContainsPairs(unitClassTable, 3) then
        return 3
    end
    return 0
end

local function getSkillsetIcon(skillsetId)
    local size = 12
    if skillsetId < 1 or skillsetId > 10 then return nil end
    local coords = {
        -- Battlerage Icon
        {480, 498, size, size}, -- Witchcraft Icon
        {534, 483, size, size}, -- Defense Icon
        {492, 498, size, size}, -- Auramancy Icon
        {510, 483, size, size}, -- Occultism Icon
        {522, 471, size, size}, -- Archery Icon
        {528, 454, size, size}, -- Sorcery Icon
        {504, 498, size, size}, -- Shadowplay Icon
        {522, 483, size, size}, -- Songcraft Icon
        {534, 471, size, size}, -- Vitalism Icon
        {510, 471, size, size}
    }
    local iconCoords = coords[skillsetId]
    return iconCoords
end

local helpers = {
    hasValue = hasValue,
    getSettings = getSettings,
    updateSettings = updateSettings,
    getClassName = getClassName,
    splitString = splitString,
    getGearIconForTarget = getGearIconForTarget,
    getMainSkillsetName = getMainSkillsetName,
    getSkillsetIcon = getSkillsetIcon
}
return helpers
