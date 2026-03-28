local selectedUnit = nil
local selectedName = nil
local buttonSize = 20
local cooldownElapsed = 0

local function EnsureDB()
    if not RaidTrinketHelperDB then
        RaidTrinketHelperDB = {}
    end

    if RaidTrinketHelperDB.buttonSize == nil then
        RaidTrinketHelperDB.buttonSize = 20
    end

    if RaidTrinketHelperDB.isShown == nil then
        RaidTrinketHelperDB.isShown = true
    end
end

local function SaveFramePosition(frame)
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    RaidTrinketHelperDB.point = point
    RaidTrinketHelperDB.relativePoint = relativePoint
    RaidTrinketHelperDB.xOfs = xOfs
    RaidTrinketHelperDB.yOfs = yOfs
end

local function RestoreFramePosition(frame)
    frame:ClearAllPoints()

    if RaidTrinketHelperDB.point
       and RaidTrinketHelperDB.relativePoint
       and RaidTrinketHelperDB.xOfs ~= nil
       and RaidTrinketHelperDB.yOfs ~= nil then
        frame:SetPoint(
            RaidTrinketHelperDB.point,
            UIParent,
            RaidTrinketHelperDB.relativePoint,
            RaidTrinketHelperDB.xOfs,
            RaidTrinketHelperDB.yOfs
        )
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local frame = CreateFrame("Frame", "RaidTrinketHelperFrame", UIParent)
frame:SetWidth(60)
frame:SetHeight(36)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetMovable(true)
frame:EnableMouse(true)

local leftColumn = CreateFrame("Frame", "RaidTrinketHelperLeftColumn", frame)
leftColumn:SetWidth(18)
leftColumn:SetHeight(36)
leftColumn:SetPoint("LEFT", frame, "LEFT", 0, 0)

local dropdownMenu = CreateFrame("Frame", "RaidTrinketHelperDropdownMenu", UIParent, "UIDropDownMenuTemplate")

local selectButton = CreateFrame("Button", "RaidTrinketHelperSelectButton", leftColumn)
selectButton:SetWidth(16)
selectButton:SetHeight(16)
selectButton:SetPoint("TOPLEFT", leftColumn, "TOPLEFT", 1, -1)
selectButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
selectButton:SetBackdropColor(0.15, 0.15, 0.15, 0.9)

local selectText = selectButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
selectText:SetPoint("CENTER", selectButton, "CENTER", 0, 0)
selectText:SetText("v")

local dragButton = CreateFrame("Button", "RaidTrinketHelperDragButton", leftColumn)
dragButton:SetWidth(16)
dragButton:SetHeight(16)
dragButton:SetPoint("BOTTOMLEFT", leftColumn, "BOTTOMLEFT", 1, 1)
dragButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
dragButton:SetBackdropColor(0.15, 0.15, 0.15, 0.9)

local dragText = dragButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dragText:SetPoint("CENTER", dragButton, "CENTER", 0, 0)
dragText:SetText("+")

dragButton:RegisterForDrag("LeftButton")
dragButton:SetScript("OnDragStart", function()
    frame:StartMoving()
end)
dragButton:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    SaveFramePosition(frame)
end)

dragButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Drag")
    GameTooltip:AddLine("Hold left mouse button and drag", 1, 1, 1)
    GameTooltip:Show()
end)

dragButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local trinketButton = CreateFrame("Button", "RaidTrinketHelperTrinketButton", frame)
trinketButton:RegisterForClicks("LeftButtonUp")
trinketButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
trinketButton:SetBackdropColor(0, 0, 0, 1)

local trinketIcon = trinketButton:CreateTexture(nil, "ARTWORK")
trinketButton.icon = trinketIcon

local cooldownText = trinketButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
cooldownText:SetText("")

local function UpdateCooldownFont()
    local font, _, flags = cooldownText:GetFont()
    if not font then
        font = "Fonts\\FRIZQT__.TTF"
    end

    local size = math.floor(buttonSize * 0.38)
    if size < 8 then
        size = 8
    end
    if size > 36 then
        size = 36
    end

    cooldownText:SetFont(font, size, flags)
end

local function ApplyLayout()
    local leftWidth = math.floor(buttonSize * 0.55)
    if leftWidth < 18 then
        leftWidth = 18
    end

    local smallButtonSize = math.floor(buttonSize * 0.45)
    if smallButtonSize < 16 then
        smallButtonSize = 16
    end

    local totalHeight = buttonSize
    if totalHeight < (smallButtonSize * 2 + 4) then
        totalHeight = smallButtonSize * 2 + 4
    end

    frame:SetWidth(leftWidth + buttonSize + 6)
    frame:SetHeight(totalHeight)

    leftColumn:SetWidth(leftWidth)
    leftColumn:SetHeight(totalHeight)
    leftColumn:ClearAllPoints()
    leftColumn:SetPoint("LEFT", frame, "LEFT", 0, 0)

    selectButton:ClearAllPoints()
    selectButton:SetPoint("TOPLEFT", leftColumn, "TOPLEFT", 1, -1)
    selectButton:SetWidth(smallButtonSize)
    selectButton:SetHeight(smallButtonSize)

    selectText:ClearAllPoints()
    selectText:SetPoint("CENTER", selectButton, "CENTER", 0, 0)

    dragButton:ClearAllPoints()
    dragButton:SetPoint("BOTTOMLEFT", leftColumn, "BOTTOMLEFT", 1, 1)
    dragButton:SetWidth(smallButtonSize)
    dragButton:SetHeight(smallButtonSize)

    dragText:ClearAllPoints()
    dragText:SetPoint("CENTER", dragButton, "CENTER", 0, 0)

    trinketButton:ClearAllPoints()
    trinketButton:SetPoint("LEFT", frame, "LEFT", leftWidth + 2, 0)
    trinketButton:SetWidth(buttonSize)
    trinketButton:SetHeight(buttonSize)

    trinketIcon:ClearAllPoints()
    trinketIcon:SetPoint("TOPLEFT", trinketButton, "TOPLEFT", 2, -2)
    trinketIcon:SetPoint("BOTTOMRIGHT", trinketButton, "BOTTOMRIGHT", -2, 2)

    cooldownText:ClearAllPoints()
    cooldownText:SetPoint("CENTER", trinketButton, "CENTER", 0, 0)

    UpdateCooldownFont()
end

local function UpdateTrinketIcon()
    local texture = GetInventoryItemTexture("player", 13)
    if texture then
        trinketIcon:SetTexture(texture)
        trinketIcon:SetVertexColor(1, 1, 1)
    else
        trinketIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        trinketIcon:SetVertexColor(0.4, 0.4, 0.4)
    end
end

local function UpdateTrinketCooldown()
    if not GetInventoryItemLink("player", 13) then
        cooldownText:SetText("")
        return
    end

    local start, duration, enable = GetInventoryItemCooldown("player", 13)

    if start and duration and enable and enable == 1 and duration > 1.5 then
        local remaining = start + duration - GetTime()

        if remaining > 0 then
            if remaining >= 10 then
                cooldownText:SetText(math.floor(remaining + 0.5))
            else
                cooldownText:SetText(string.format("%.1f", remaining))
            end
        else
            cooldownText:SetText("")
        end
    else
        cooldownText:SetText("")
    end
end

local function SetSelected(unit, name)
    selectedUnit = unit
    selectedName = name
end

local function GetGroupList()
    local list = {}

    if GetNumRaidMembers() and GetNumRaidMembers() > 0 then
        local i
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                table.insert(list, {
                    unit = "raid" .. i,
                    name = name,
                })
            end
        end
    elseif GetNumPartyMembers() and GetNumPartyMembers() > 0 then
        table.insert(list, {
            unit = "player",
            name = UnitName("player"),
        })

        local i
        for i = 1, GetNumPartyMembers() do
            if UnitExists("party" .. i) then
                table.insert(list, {
                    unit = "party" .. i,
                    name = UnitName("party" .. i),
                })
            end
        end
    else
        table.insert(list, {
            unit = "player",
            name = UnitName("player"),
        })
    end

    return list
end

local function Dropdown_OnClick()
    SetSelected(this.value, this.arg1)
end

local function InitializeDropdown()
    local list = GetGroupList()
    local foundCurrent = nil
    local i

    for i = 1, table.getn(list) do
        local entry = list[i]
        local info = {}

        info.text = entry.name
        info.value = entry.unit
        info.arg1 = entry.name
        info.func = Dropdown_OnClick
        info.checked = (selectedUnit == entry.unit)
        UIDropDownMenu_AddButton(info)

        if selectedUnit == entry.unit then
            foundCurrent = 1
        end
    end

    if not foundCurrent then
        if table.getn(list) > 0 then
            SetSelected(list[1].unit, list[1].name)
        else
            SetSelected(nil, nil)
        end
    end
end

UIDropDownMenu_Initialize(dropdownMenu, InitializeDropdown, "MENU")

selectButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, dropdownMenu, selectButton, 0, 0)
end)

selectButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Select Target")
    if selectedName then
        GameTooltip:AddLine("Current: " .. selectedName, 1, 1, 1)
    else
        GameTooltip:AddLine("No target selected", 1, 0.2, 0.2)
    end
    GameTooltip:Show()
end)

selectButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

trinketButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    GameTooltip:AddLine("Raid Trinket Helper")

    if selectedName then
        GameTooltip:AddLine("Selected: " .. selectedName, 1, 1, 1)
    else
        GameTooltip:AddLine("No target selected", 1, 0.2, 0.2)
    end

    if GetNumRaidMembers() and GetNumRaidMembers() > 0 then
        GameTooltip:AddLine("Mode: Raid", 0.7, 0.7, 0.7)
    elseif GetNumPartyMembers() and GetNumPartyMembers() > 0 then
        GameTooltip:AddLine("Mode: Party", 0.7, 0.7, 0.7)
    else
        GameTooltip:AddLine("Mode: Solo", 0.7, 0.7, 0.7)
    end

    if GetInventoryItemLink("player", 13) then
        GameTooltip:AddLine(" ")
        GameTooltip:SetInventoryItem("player", 13)
    else
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("No trinket equipped in slot 13", 1, 0.2, 0.2)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Top left: select target", 0.6, 0.6, 0.6)
    GameTooltip:AddLine("Bottom left: drag widget", 0.6, 0.6, 0.6)
    GameTooltip:AddLine("/rth opens settings", 0.6, 0.6, 0.6)

    GameTooltip:Show()
end)

trinketButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

trinketButton:SetScript("OnClick", function()
    if not selectedUnit or not UnitExists(selectedUnit) then
        print("RaidTrinketHelper: No valid target selected.")
        return
    end

    if not GetInventoryItemLink("player", 13) then
        print("RaidTrinketHelper: No trinket in slot 13.")
        return
    end

    local previousTargetName = nil
    if UnitExists("target") then
        previousTargetName = UnitName("target")
    end

    TargetUnit(selectedUnit)
    UseInventoryItem(13)

    if SpellIsTargeting() then
        SpellTargetUnit(selectedUnit)
    end

    if previousTargetName and previousTargetName ~= "" then
        TargetByName(previousTargetName, 1)
    else
        ClearTarget()
    end

    UpdateTrinketCooldown()
end)

local function RefreshDropdown()
    UIDropDownMenu_Initialize(dropdownMenu, InitializeDropdown, "MENU")
end

local configFrame = CreateFrame("Frame", "RaidTrinketHelperConfigFrame", UIParent)
configFrame:SetWidth(210)
configFrame:SetHeight(150)
configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
configFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
configFrame:SetBackdropColor(0, 0, 0, 0.9)
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", function()
    this:StartMoving()
end)
configFrame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
end)
configFrame:Hide()

local configTitle = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
configTitle:SetPoint("TOP", configFrame, "TOP", 0, -10)
configTitle:SetText("Raid Trinket Helper")

local sizeLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
sizeLabel:SetPoint("TOP", configTitle, "BOTTOM", 0, -10)
sizeLabel:SetText("Button Size: " .. buttonSize)

local helpLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
helpLabel:SetPoint("TOP", sizeLabel, "BOTTOM", 0, -6)
helpLabel:SetText("Resize whole widget")

local sizeSlider = CreateFrame("Slider", "RaidTrinketHelperSizeSlider", configFrame, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOP", helpLabel, "BOTTOM", 0, -10)
sizeSlider:SetWidth(150)
sizeSlider:SetHeight(16)
sizeSlider:SetMinMaxValues(16, 100)
sizeSlider:SetValueStep(1)

getglobal("RaidTrinketHelperSizeSliderLow"):SetText("16")
getglobal("RaidTrinketHelperSizeSliderHigh"):SetText("100")
getglobal("RaidTrinketHelperSizeSliderText"):SetText("")

sizeSlider:SetScript("OnValueChanged", function()
    local value = math.floor(this:GetValue() + 0.5)
    if value ~= buttonSize then
        buttonSize = value
        RaidTrinketHelperDB.buttonSize = buttonSize
        sizeLabel:SetText("Button Size: " .. buttonSize)
        ApplyLayout()
    else
        sizeLabel:SetText("Button Size: " .. buttonSize)
    end
end)

local showCheckbox = CreateFrame("CheckButton", "RaidTrinketHelperShowCheckbox", configFrame, "UICheckButtonTemplate")
showCheckbox:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -4)

local showLabel = showCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
showLabel:SetPoint("LEFT", showCheckbox, "RIGHT", 4, 0)
showLabel:SetText("Show Widget")

showCheckbox:SetScript("OnClick", function()
    if this:GetChecked() then
        frame:Show()
        RaidTrinketHelperDB.isShown = true
    else
        frame:Hide()
        RaidTrinketHelperDB.isShown = false
    end
end)

local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
closeButton:SetWidth(60)
closeButton:SetHeight(20)
closeButton:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 3)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    configFrame:Hide()
end)

frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:RegisterEvent("VARIABLES_LOADED")

frame:SetScript("OnEvent", function()
    
    if event == "VARIABLES_LOADED" then
        EnsureDB()

        buttonSize = RaidTrinketHelperDB.buttonSize or 20
        ApplyLayout()
        RestoreFramePosition(frame)

        if RaidTrinketHelperDB.isShown then
            frame:Show()
        else
            frame:Hide()
        end

        
    end

    RefreshDropdown()
    UpdateTrinketIcon()
    UpdateTrinketCooldown()
end)



frame:SetScript("OnUpdate", function()
    cooldownElapsed = cooldownElapsed + arg1
    if cooldownElapsed > 0.1 then
        UpdateTrinketCooldown()
        cooldownElapsed = 0
    end
end)

SLASH_RAIDTRINKETHELPER1 = "/rth"
SlashCmdList["RAIDTRINKETHELPER"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "" then
        sizeSlider:SetValue(buttonSize)
        sizeLabel:SetText("Button Size: " .. buttonSize)

        if frame:IsShown() then
            showCheckbox:SetChecked(1)
        else
            showCheckbox:SetChecked(nil)
        end

        if configFrame:IsShown() then
            configFrame:Hide()
        else
            configFrame:Show()
        end
    elseif msg == "reset" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        SaveFramePosition(frame)
        frame:Show()
        RaidTrinketHelperDB.isShown = true
        print("RaidTrinketHelper reset.")
    else
        print("RaidTrinketHelper commands:")
        print("/rth")
        print("/rth reset")
    end
end

RefreshDropdown()
UpdateTrinketIcon()
UpdateTrinketCooldown()
