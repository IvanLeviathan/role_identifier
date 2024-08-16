local api = require("api")
local helpers = require('role_identifier/helpers')
local settingspage = require('role_identifier/settings_page')

local role_identifier = {
    name = "Role Identifier",
    author = "Misosoup",
    desc = "Addon for detecting tank/healers classes",
    version = "0.5"
}
local CANVAS

local tankIconPath = 'Game\\ui\\icon\\icon_skill_adamant01.dds'
local healerIconPath = 'Game\\ui\\icon\\icon_skill_love28.dds'

local playersClasses = {}
local curIcon
local icon
local canvasUI
local settings

-- Renders
local function renderIcons(target)

    local offsetX, offsetY, offsetZ = api.Unit:GetUnitScreenNameTagOffset(
                                          'target')
    local classNameOffsetX = math.ceil(offsetX + settings.class_name_offset_x)
    local classNameOffsetY = math.ceil(offsetY + settings.class_name_offset_y)

    offsetX = math.ceil(offsetX + settings.icon_offset_x)
    offsetY = math.ceil(offsetY + settings.icon_offset_y)

    if playersClasses[target.name] == nil then
        -- Calc role
        local className = helpers.getClassName(target.class)
        local playerIcon

        if helpers.hasValue(settings.tanks, className) then
            playerIcon = tankIconPath
        end

        if helpers.hasValue(settings.healers, className) then
            playerIcon = healerIconPath
        end

        playersClasses[target.name] = {className = className, icon = playerIcon}
    end

    if canvasUI == nil then
        icon = CreateItemIconButton('roleIcon', CANVAS)
        -- Create Icon
        F_SLOT.ApplySlotSkin(icon, icon.back, SLOT_STYLE.DEFAULT)

        icon:SetHeight(settings.icon_size)
        icon:SetWidth(settings.icon_size)
        icon:Clickable(false)

        -- Create Text
        local className = CANVAS:CreateChildWidget("label", "label", 0, true)
        className.style:SetFontSize(settings.font_size)

        -- Save info
        canvasUI = {icon = icon, text = className}
    end

    if offsetZ < 0 or offsetZ > 100 then
        canvasUI.icon:Show(false)
        canvasUI.text:Show(false)
    else
        if (curIcon ~= playersClasses[target.name].icon) then
            curIcon = playersClasses[target.name].icon
            F_SLOT.SetIconBackGround(icon, curIcon)
        end
        if curIcon ~= nil then
            canvasUI.icon:AddAnchor("CENTER", CANVAS, "CENTER", offsetX, offsetY)
            canvasUI.icon:Show(true)

            if settings.show_class_name then
                canvasUI.text:AddAnchor("CENTER", CANVAS, "CENTER",
                                        classNameOffsetX, classNameOffsetY)
                canvasUI.text:SetText(playersClasses[target.name].className)
                canvasUI.text:Show(true)
            end

        else
            canvasUI.icon:Show(false)
            canvasUI.text:Show(false)
        end

    end
end

local lastUpdate = 0
local function OnUpdate(dt)
    lastUpdate = lastUpdate + dt
    -- 20 is ok
    if lastUpdate < 20 then return end
    lastUpdate = dt

    -- checking target
    local playerId = api.Unit:GetUnitId('player')
    local targetId = api.Unit:GetUnitId('target')
    local targetInfo = api.Unit:GetUnitInfoById(targetId)

    -- no target
    if targetInfo == nil then
        canvasUI.text:Show(false)
        canvasUI.icon:Show(false)
        return
    end
    -- checking if target is valid
    if targetInfo.type == 'character' and playerId ~= targetId then
        renderIcons(targetInfo)
    else
        canvasUI.text:Show(false)
        canvasUI.icon:Show(false)
    end
end

local function OnSettingsSaved()
    canvasUI.icon:SetHeight(settings.icon_size)
    canvasUI.icon:SetWidth(settings.icon_size)

    canvasUI.text.style:SetFontSize(settings.font_size)
    if settings.show_class_name then
        canvasUI.text:Show(true)
    else
        canvasUI.text:Show(false)
    end
    playersClasses = {}
end

local function Load()
    -- Initiate Canvas
    CANVAS = api.Interface:CreateEmptyWindow("RoleIdentifier")
    CANVAS:Show(true)
    CANVAS.OnSettingsSaved = OnSettingsSaved
    settings = helpers.getSettings(CANVAS)

    -- Initiate Settings
    settingspage.init(CANVAS)

    api.Log:Info(
        "[RI] Roles Identifier loaded. Use \"/ri settings\" for settings page.")
    api.On("UPDATE", OnUpdate)
end

local function Unload()
    if CANVAS ~= nil then
        CANVAS:Show(false)
        CANVAS = nil
    end
    settingspage.Unload()
end

role_identifier.OnLoad = Load
role_identifier.OnUnload = Unload

return role_identifier
