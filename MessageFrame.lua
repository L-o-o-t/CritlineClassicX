local AceGUI = LibStub("AceGUI-3.0")

function CritlineClassicX.CreateMessageFrame(color)
  local f = AceGUI:Create("Frame")
  f:SetTitle("")
  f:SetStatusText("")
  f:SetLayout("Flow")
  f:SetWidth(400)
  f:SetHeight(50)
  f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

  -- Set the frame level to a high value.
  f.frame:SetFrameStrata("TOOLTIP")  -- This is the highest built-in strata.
  f.frame:SetFrameLevel(20)  -- Increase this number if necessary.

  local text = AceGUI:Create("Label")
  text:SetFont(fontPath, 20, "THICKOUTLINE")
  text:SetColor(1, 1, 1)
  text:SetShadowOffset(3, -3)
  text:SetJustifyH("CENTER")
  text:SetJustifyV("CENTER")
  text:SetText("")
  f:AddChild(text)

  -- Add shake animation to the frame
  local shake = AceGUI:Create("AnimationGroup")
  local shake1 = shake:Create("Translation")
  shake1:SetDuration(0.05)
  shake1:SetOffset(5, 0)
  local shake2 = shake:Create("Translation")
  shake2:SetDuration(0.05)
  shake2:SetOffset(-5, 0)
  local shake3 = shake:Create("Translation")
  shake3:SetDuration(0.05)
  shake3:SetOffset(0, 5)
  local shake4 = shake:Create("Translation")
  shake4:SetDuration(0.05)
  shake4:SetOffset(0, -5)
  shake:SetLooping("REPEAT")
  shake:AddChild(shake1)
  shake:AddChild(shake2)
  shake:AddChild(shake3)
  shake:AddChild(shake4)
  f.shake = shake

  -- Add the shake animation to the text label
  text:SetCallback("OnEnter", function(widget)
    widget:GetParent().shake:Play()
  end)
  text:SetCallback("OnLeave", function(widget)
    widget:GetParent().shake:Stop()
    widget:GetParent().frame:ClearAllPoints()
    widget:GetParent().frame:SetPoint("CENTER", UIParent, "CENTER")
  end)

  return f
end