local fontPath = "Interface\\AddOns\\CritlineClassicX\\fonts\\8bit.ttf" 
function CritlineClassicX.CreateMessageFrame(color)
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetPoint("CENTER", UIParent, "CENTER")
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

function CritlineClassicX.ShowNewCritMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end
  if not CritlineClassicXMessageFrame then
    CritlineClassicXMessageFrame = CritlineClassicX.CreateMessageFrame()
  end
  CritlineClassicXMessageFrame.text:SetTextColor(1, 0.84, 0) -- Set text color to gold
  CritlineClassicXMessageFrame.text:SetText(string.upper(string.format("New %s crit: %d!", spellName, amount)))
  CritlineClassicXMessageFrame:Show()
  C_Timer.After(8, function() CritlineClassicXMessageFrame:Hide() end)
end

function CritlineClassicX.ShowNewNormalMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end
  if not CritlineClassicXMessageFrame then
    CritlineClassicXMessageFrame = CritlineClassicX.CreateMessageFrame("white")
  end
  CritlineClassicXMessageFrame.text:SetTextColor(1, 1, 1)
  CritlineClassicXMessageFrame.text:SetText(string.upper(string.format("New %s normal record: %d!", spellName, amount)))
  CritlineClassicXMessageFrame:Show()
  C_Timer.After(8, function() CritlineClassicXMessageFrame:Hide() end)
end

function CritlineClassicX.ShowNewHealMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end
  if not CritlineClassicXMessageFrame then
    CritlineClassicXMessageFrame = CritlineClassicX.CreateMessageFrame("white")
  end
  CritlineClassicXMessageFrame.text:SetTextColor(1, 1, 1)
  CritlineClassicXMessageFrame.text:SetText(string.upper(string.format("New %s normal heal record: %d!", spellName, amount)))
  CritlineClassicXMessageFrame:Show()
  C_Timer.After(8, function() CritlineClassicXMessageFrame:Hide() end)
end

function CritlineClassicX.ShowNewHealCritMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end
  if not CritlineXClassicMessageFrame then
    CritlineClassicXMessageFrame = CritlineClassicX.CreateMessageFrame()
  end
  CritlineClassicXMessageFrame.text:SetTextColor(1, 0.84, 0) -- Set text color to gold
  CritlineClassicXMessageFrame.text:SetText(string.upper(string.format("New %s crit heal: %d!", spellName, amount)))
  CritlineClassicXMessageFrame:Show()
  C_Timer.After(8, function() CritlineClassicXMessageFrame:Hide() end)
end