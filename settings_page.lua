local api = require("api")
local helpers = require('role_identifier/helpers')
local playerId = api.Unit:GetUnitId("player")
local checkButton = require('role_identifier/util/check_button')
local settingsWindow
local settings
local settingsControls = {}

local labelHeight = 20
local textareaHeight = 100
local padding = 15
local editWidth = 100

local commands = {'settings'}
-- Controls
local function createLabel(id, parent, text, offsetY, fontSize)
    local label = api.Interface:CreateWidget('label', id, parent)
    label:AddAnchor("TOPLEFT", padding, offsetY)
    label:SetExtent(255, labelHeight)
    label:SetText(text)
    label.style:SetColor(FONT_COLOR.TITLE[1], FONT_COLOR.TITLE[2],
                         FONT_COLOR.TITLE[3], 1)
    label.style:SetAlign(ALIGN.LEFT)
    label.style:SetFontSize(fontSize or 18)

    return label
end

local function createTextarea(id, parent, text, offsetY, wW)
    local field = W_CTRL.CreateMultiLineEdit(id, parent)
    field:SetExtent(wW - (padding * 2), textareaHeight)
    field:AddAnchor("TOPLEFT", padding, offsetY)
    field:SetText(text)
    field.style:SetColor(0, 0, 0, 1)
    field.style:SetAlign(ALIGN.LEFT)
    field.style:SetFontSize(14)
    field:SetMaxTextLength(700)
    field:SetInset(10, -65, 10, 5)
    return field
end

local function createEdit(id, parent, text, offsetY)
    local field = W_CTRL.CreateEdit(id, parent)
    field:SetExtent(editWidth, labelHeight)
    field:AddAnchor("TOPLEFT", padding, offsetY)
    field:SetText(tostring(text))
    field.style:SetColor(0, 0, 0, 1)
    field.style:SetAlign(ALIGN.LEFT)
    -- field:SetDigit(true)
    field:SetInitVal(text)
    field:SetMaxTextLength(4)
    return field
end

local function createCheckbox(id, parent, text, offsetY)
    local checkBox = checkButton.CreateCheckButton(id, parent, text)
    checkBox:AddAnchor("TOPLEFT", padding, offsetY)
    checkBox:SetButtonStyle("default")
    return checkBox
end

local function createButton(id, parent, text, x, y)
    local button = api.Interface:CreateWidget('button', id, parent)
    button:AddAnchor("TOPLEFT", x, y)
    button:SetExtent(55, 26)
    button:SetText(text)
    api.Interface:ApplyButtonSkin(button, BUTTON_BASIC.DEFAULT)
    return button
end

local function createComboBox(parent, values, x, y)
    local dropdownBtn = W_CTRL.CreateComboBox(parent)
    dropdownBtn:AddAnchor("TOPLEFT", parent, x, y)
    dropdownBtn:SetExtent(200, 24)
    dropdownBtn.dropdownItem = values
    return dropdownBtn
end

-- Settings
local function saveSettings()
    settings.healers = helpers.splitString(
                           settingsControls.healersField:GetText(), ',')
    settings.tanks = helpers.splitString(settingsControls.tanksField:GetText(),
                                         ',')

    settings.icon_offset_x = tonumber(
                                 settingsControls.iconOffsetXField:GetText())
    settings.icon_offset_y = tonumber(
                                 settingsControls.iconOffsetYField:GetText())

    settings.icon_size = tonumber(settingsControls.iconSizeField:GetText())

    settings.class_name_offset_x = tonumber(
                                       settingsControls.fontOffsetXField:GetText())
    settings.class_name_offset_y = tonumber(
                                       settingsControls.fontOffsetYField:GetText())
    settings.font_size = tonumber(settingsControls.fontSizeField:GetText())

    settings.show_class_name = settingsControls.showClassName:GetChecked()

    settings.only_specified = settingsControls.onlySpecified:GetChecked()

    settings.icon_type = settingsControls.iconType:GetSelectedIndex()

    helpers.updateSettings()

end
local function openSettingsWindow() settingsWindow:Show(true) end
local function toggleMode(state)
    local curMode = settingsControls.iconType:GetSelectedIndex()
    if not state then
        if (curMode == 1) then settingsControls.iconType:Select(2) end
    end
end

local function initSettingsPage()
    settings = api.GetSettings("role_identifier")
    settingsWindow = api.Interface:CreateWindow("RiSettings",
                                                'Role Identifier Settings', 800,
                                                600)
    settingsWindow:AddAnchor("CENTER", 'UIParent', 0, 0)
    local wW, wH = settingsWindow:GetExtent()
    local labelsOffsetY = 70
    -- mode
    local iconTypeLabel = createLabel('iconTypeLabel', settingsWindow, 'Mode:',
                                      labelsOffsetY, 15)
    labelsOffsetY = labelsOffsetY + 20
    local iconType = createComboBox(settingsWindow,
                                    {'Tank/Healer', 'Set', 'Skillset'}, padding,
                                    labelsOffsetY)
    iconType:Select(settings.icon_type)
    settingsControls.iconType = iconType
    local onlySpecified = createCheckbox('onlySpecified', settingsWindow,
                                         "Show only specified classes",
                                         labelsOffsetY)

    onlySpecified:AddAnchor("TOPLEFT", settingsWindow, 225, labelsOffsetY)
    function onlySpecified:OnCheckChanged() toggleMode(self:GetChecked()) end
    onlySpecified:SetHandler("OnCheckChanged", onlySpecified.OnCheckChanged)
    onlySpecified:SetChecked(settings.only_specified)
    toggleMode(settings.only_specified)
    settingsControls.onlySpecified = onlySpecified

    -- tanks
    labelsOffsetY = 120
    local tanksLabel = createLabel('tanksLabel', settingsWindow, 'Tanks:',
                                   labelsOffsetY)
    local tanksField = createTextarea('tanksField', settingsWindow,
                                      table.concat(settings.tanks, ', '),
                                      labelsOffsetY + 25, wW)
    settingsControls.tanksField = tanksField
    -- healers
    labelsOffsetY = 255
    local healersLabel = createLabel('healersLabel', settingsWindow, 'Healers:',
                                     labelsOffsetY)
    local healersField = createTextarea('healersField', settingsWindow,
                                        table.concat(settings.healers, ', '),
                                        labelsOffsetY + 25, wW)
    settingsControls.healersField = healersField

    -- icon settings
    labelsOffsetY = 390;
    createLabel('iconCategoryLabel', settingsWindow, 'Icon', labelsOffsetY)
    labelsOffsetY = labelsOffsetY + 20
    local iconOffsetXLabel = createLabel('iconOffsetXLabel', settingsWindow,
                                         'offset X:', labelsOffsetY, 15)
    local iconOffsetXField = createEdit('iconOffsetXField', settingsWindow,
                                        settings.icon_offset_x, labelsOffsetY)
    settingsControls.iconOffsetXField = iconOffsetXField
    iconOffsetXField:AddAnchor("TOPLEFT", 80, labelsOffsetY)

    local iconOffsetYLabel = createLabel('iconOffsetYLabel', settingsWindow,
                                         'offset Y:', labelsOffsetY, 15)
    iconOffsetYLabel:AddAnchor("TOPLEFT", 190, labelsOffsetY)
    local iconOffsetYField = createEdit('iconOffsetYField', settingsWindow,
                                        settings.icon_offset_y, labelsOffsetY)
    settingsControls.iconOffsetYField = iconOffsetYField
    iconOffsetYField:AddAnchor("TOPLEFT", 250, labelsOffsetY)

    local iconSizeLabel = createLabel('iconSizeLabel', settingsWindow, 'size:',
                                      labelsOffsetY, 15)
    iconSizeLabel:AddAnchor("TOPLEFT", 360, labelsOffsetY)
    local iconSizeField = createEdit('iconSizeField', settingsWindow,
                                     settings.icon_size, labelsOffsetY)
    settingsControls.iconSizeField = iconSizeField
    iconSizeField:AddAnchor("TOPLEFT", 395, labelsOffsetY)
    iconSizeField:SetDigit(true)
    iconSizeField:SetMaxTextLength(2)
    iconSizeField:SetText(tostring(settings.icon_size))

    -- class name settings
    labelsOffsetY = 440
    createLabel('classNameCategoryLabel', settingsWindow, 'Classname',
                labelsOffsetY)
    labelsOffsetY = labelsOffsetY + 20
    local showClassName = createCheckbox('showClassName', settingsWindow,
                                         "Show classname", labelsOffsetY)
    showClassName:SetChecked(settings.show_class_name)
    settingsControls.showClassName = showClassName
    labelsOffsetY = labelsOffsetY + 20

    local fontOffsetXLabel = createLabel('fontOffsetXLabel', settingsWindow,
                                         'offset X:', labelsOffsetY, 15)
    local fontOffsetXField = createEdit('fontOffsetXField', settingsWindow,
                                        settings.class_name_offset_x,
                                        labelsOffsetY)
    fontOffsetXField:AddAnchor("TOPLEFT", 80, labelsOffsetY)
    settingsControls.fontOffsetXField = fontOffsetXField

    local fontOffsetYLabel = createLabel('iconOffsetYLabel', settingsWindow,
                                         'offset Y:', labelsOffsetY, 15)
    fontOffsetYLabel:AddAnchor("TOPLEFT", 190, labelsOffsetY)
    local fontOffsetYField = createEdit('fontOffsetYField', settingsWindow,
                                        settings.class_name_offset_y,
                                        labelsOffsetY)
    fontOffsetYField:AddAnchor("TOPLEFT", 250, labelsOffsetY)
    settingsControls.fontOffsetYField = fontOffsetYField

    local fontSizeLabel = createLabel('fontSizeLabel', settingsWindow, 'size:',
                                      labelsOffsetY, 15)
    fontSizeLabel:AddAnchor("TOPLEFT", 360, labelsOffsetY)
    local fontSizeField = createEdit('fontSizeField', settingsWindow,
                                     settings.font_size, labelsOffsetY)
    settingsControls.fontSizeField = fontSizeField
    fontSizeField:AddAnchor("TOPLEFT", 395, labelsOffsetY)
    fontSizeField:SetDigit(true)
    fontSizeField:SetMaxTextLength(2)
    fontSizeField:SetText(tostring(settings.font_size))

    -- save button
    local saveButton = createButton('saveButton', settingsWindow, 'Save', 0, 0)
    saveButton:AddAnchor("TOPLEFT", settingsWindow, "BOTTOMLEFT", padding, -45)

    -- copyrights
    local copyright = createLabel('copyright', settingsWindow,
                                  'from Misosoup with love for AAC', 0, 14)
    copyright:AddAnchor("TOPLEFT", settingsWindow, "BOTTOMRIGHT", -275, -45)
    copyright.style:SetAlign(ALIGN.BOTTOM_RIGHT)

    -- controls are done, now events
    saveButton:SetHandler("OnClick", saveSettings)
end

local function createSettingsPage() initSettingsPage() end

local function Unload()
    if settingsWindow ~= nil then
        settingsWindow:Show(false)
        settingsWindow = nil
    end
end

local settings_page = {
    init = createSettingsPage,
    Unload = Unload,
    openSettingsWindow = openSettingsWindow
}
return settings_page
