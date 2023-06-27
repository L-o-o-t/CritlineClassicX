local fontPath = "Interface\\AddOns\\CritMatic\\fonts\\8bit.ttf"
function CritMatic.CreateMessageFrame()
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
    f:SetSize(400, 50)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetScript("OnMouseDown", f.StartMoving)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    f:SetScript("OnHide", f.StopMovingOrSizing)

    -- Set the frame level to a high value.
    f:SetFrameStrata("TOOLTIP")  -- This is the highest built-in strata.
    f:SetFrameLevel(20)  -- Increase this number if necessary.

    local text = f:CreateFontString(nil, "OVERLAY")
    text:SetFont(fontPath, 20, "THICKOUTLINE")
    text:SetShadowOffset(3, -3)
    text:SetPoint("CENTER", f, "CENTER")
    f.text = text

    return f
end

function CritMatic.ShowNewCritMessage(spellName, amount)
    if spellName == "Auto Attack" then
        return
    end
    if not CritMaticMessageFrame then
        CritMaticMessageFrame = CritMatic.CreateMessageFrame()
    end
    CritMaticMessageFrame.text:SetTextColor(1, 0.84, 0) -- Set text color to gold
    CritMaticMessageFrame.text:SetText(string.upper(string.format("New %s crit: %d!", spellName, amount)))
    CritMaticMessageFrame:Show()
    C_Timer.After(8, function()
        CritMaticMessageFrame:Hide()
    end)
end

function CritMatic.ShowNewNormalMessage(spellName, amount)
    if spellName == "Auto Attack" then
        return
    end
    if not CritMaticMessageFrame then
        CritMaticMessageFrame = CritMatic.CreateMessageFrame()
    end
    CritMaticMessageFrame.text:SetTextColor(1, 1, 1)
    CritMaticMessageFrame.text:SetText(string.upper(string.format("New %s normal record: %d!", spellName, amount)))
    CritMaticMessageFrame:Show()
    C_Timer.After(8, function()
        CritMaticMessageFrame:Hide()
    end)
end

function CritMatic.ShowNewHealMessage(spellName, amount)
    if spellName == "Auto Attack" then
        return
    end
    if not CritMaticMessageFrame then
        CritMaticMessageFrame = CritMatic.CreateMessageFrame()
    end
    CritMaticMessageFrame.text:SetTextColor(1, 1, 1)
    CritMaticMessageFrame.text:SetText(string.upper(string.format("New %s normal heal record: %d!", spellName, amount)))
    CritMaticMessageFrame:Show()
    C_Timer.After(8, function()
        CritMaticMessageFrame:Hide()
    end)
end

function CritMatic.ShowNewHealCritMessage(spellName, amount)
    if spellName == "Auto Attack" then
        return
    end
    if not CritMaticMessageFrame then
        CritMaticMessageFrame = CritMatic.CreateMessageFrame()
    end
    CritMaticMessageFrame.text:SetTextColor(1, 0.84, 0) -- Set text color to gold
    CritMaticMessageFrame.text:SetText(string.upper(string.format("New %s crit heal: %d!", spellName, amount)))
    CritMaticMessageFrame:Show()
    C_Timer.After(8, function()
        CritMaticMessageFrame:Hide()
    end)
end