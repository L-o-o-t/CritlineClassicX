-- Define a table to hold the highest hits data.
CritMaticData = CritMaticData or {}

A = LibStub("AceAddon-3.0"):NewAddon("CritMatic", "AceConsole-3.0")



local function GetGCD()
  local _, gcdDuration = GetSpellCooldown(78) -- 78 is the spell ID for Warrior's Heroic Strike
  if gcdDuration == 0 then
    return 1.5 -- Default GCD duration if not available (you may adjust this value if needed)
  else
    return gcdDuration
  end
end

local function AddHighestHitsToTooltip(self, slot)
  if (not slot) then return end

  local actionType, id = GetActionInfo(slot)
  if actionType == "spell" then
    local spellName, _, _, castTime = GetSpellInfo(id)
    if CritMaticData[spellName] then
      local cooldown = (GetSpellBaseCooldown(id) or 0) / 1000
      local effectiveCastTime = castTime > 0 and (castTime / 1000) or GetGCD()
      local effectiveTime = max(effectiveCastTime, cooldown)

      local critDPS = CritMaticData[spellName].highestCrit / effectiveTime
      local normalDPS = CritMaticData[spellName].highestNormal / effectiveTime

      local CritMaticLeft = "Highest Crit: "
      local CritMaticRight = tostring(CritMaticData[spellName].highestCrit) .. " (" .. format("%.1f", critDPS) .. " DPS)"
      local normalMaticLeft = "Highest Normal: "
      local normalMaticRight = tostring(CritMaticData[spellName].highestNormal) .. " (" .. format("%.1f", normalDPS) .. " DPS)"

      -- Check if lines are already present in the tooltip.
      local critMaticExists = false
      local normalMaticExists = false

      for i=1, self:NumLines() do
        local gtl = _G["GameTooltipTextLeft"..i]
        local gtr = _G["GameTooltipTextRight"..i]
        if gtl and gtr then
          if gtl:GetText() == CritMaticLeft
          and gtr:GetText() == CritMaticRight then
            critMaticExists = true
          elseif gtl:GetText() == normalMaticLeft and gtr:GetText() == normalMaticRight then
            normalMaticExists = true
          end
        end
      end

      -- If lines don't exist, add them.
      if not critMaticExists then
        self:AddDoubleLine(CritMaticLeft, CritMaticRight)
        _G["GameTooltipTextLeft"..self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
        _G["GameTooltipTextRight"..self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (white)
      end

      if not normalMaticExists then
        self:AddDoubleLine(normalMaticLeft, normalMaticRight)
        _G["GameTooltipTextLeft"..self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
        _G["GameTooltipTextRight"..self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (white)
      end

      self:Show()
    end
  end
end

-- Register an event that fires when the player hits an enemy.
local f = CreateFrame("FRAME")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
  -- Get information about the combat event.
  local timestamp, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount, overkill, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

  if eventType == "SWING_DAMAGE" then
    amount = spellID
    spellName = "Auto Attack"
    spellIcon = 6603 -- or specify the path to a melee icon, if you have one
  else
    spellName, _, spellIcon = GetSpellInfo(spellID)
  end

  -- Check if the event is a player hit or a player heal and update the highest hits/heals data if needed.
  if sourceGUID == UnitGUID("player") and destGUID ~= UnitGUID("player") and 
    (eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL") 
    and amount > 0 then

    if spellName then
      CritMaticData[spellName] = CritMaticData[spellName] or {
        highestCrit = 0,
        highestNormal = 0,
        highestHeal = 0,
        highestHealCrit = 0,
        spellIcon = spellIcon,
      }
      if critical then
        if eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
          if amount > CritMaticData[spellName].highestHealCrit then
            if spellName == "Auto Attack" then
              return
            end
            CritMaticData[spellName].highestHealCrit = amount
            PlaySound(888, "SFX")
            CritMatic.ShowNewHealCritMessage(spellName , amount)
            print("New highest crit heal for " .. spellName .. ": " .. CritMaticData[spellName].highestHealCrit)
          end
        else
          if amount > CritMaticData[spellName].highestCrit then
            if spellName == "Auto Attack" then
              return
            end
            CritMaticData[spellName].highestCrit = amount
            PlaySound(888, "SFX")
            CritMatic.ShowNewCritMessage(spellName , amount)
            print("New highest crit hit for " .. spellName .. ": " .. CritMaticData[spellName].highestCrit)
          end
        end
      else
        if eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
          if amount > CritMaticData[spellName].highestHeal then
            if spellName == "Auto Attack" then
              return
            end
            CritMaticData[spellName].highestHeal = amount
            PlaySound(10049, "SFX")
            CritMatic.ShowNewHealMessage(spellName , amount)
            print("New highest normal heal for " .. spellName .. ": " .. CritMaticData[spellName].highestHeal)
          end
        else
          if amount > CritMaticData[spellName].highestNormal then
            if spellName == "Auto Attack" then
              return
            end
            CritMaticData[spellName].highestNormal = amount
            PlaySound(10049, "SFX")
            CritMatic.ShowNewNormalMessage(spellName , amount)
            print("New highest normal hit for " .. spellName .. ": " .. CritMaticData[spellName].highestNormal)
          end
        end
      end
    end
  end
end)
local function A:OnInitialize()
  -- Called when the addon is loaded
  print("CritMatic Loaded!")
  CritMaticData = _G["CritMaticData"]
  -- Add the highest hits data to the spell button tooltip.
  hooksecurefunc(GameTooltip, "SetAction", AddHighestHitsToTooltip)
end

-- Register an event that fires when the player logs out or exits the game.
local function OnSave(self, event)
  -- Save the highest hits data to the saved variables for the addon.
  _G["CritMaticData"] = CritMaticData
end
local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", OnSave)

local function ResetData()
  CritMaticData = {}
  print("CritMatic data reset.")
end

SLASH_CRITLINERESET1 = '/cmreset'
function SlashCmdList.CRITLINERESET(msg, editBox)
    ResetData()
end