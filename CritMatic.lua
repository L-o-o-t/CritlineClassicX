-- Define a table to hold the highest hits data.
CritMaticData = CritMaticData or {}

local function GetGCD()
  local _, gcdDuration = GetSpellCooldown(78) -- 78 is the spell ID for Warrior's Heroic Strike
  if gcdDuration == 0 then
    return 1.5 -- Default GCD duration if not available (you may adjust this value if needed)
  else
    return gcdDuration
  end
end

local function AddHighestHitsToTooltip(self, slot)
  if (not slot) then
    return
  end

  local actionType, id = GetActionInfo(slot)
  if actionType == "spell" then
    local spellName, _, _, castTime = GetSpellInfo(id)
    if CritMaticData[spellName] then
      local cooldown = (GetSpellBaseCooldown(id) or 0) / 1000
      local effectiveCastTime = castTime > 0 and (castTime / 1000) or GetGCD()
      local effectiveTime = max(effectiveCastTime, cooldown)

      local critHPS = CritMaticData[spellName].highestHealCrit / effectiveTime
      local normalHPS = CritMaticData[spellName].highestHeal / effectiveTime
      local critDPS = CritMaticData[spellName].highestCrit / effectiveTime
      local normalDPS = CritMaticData[spellName].highestNormal / effectiveTime

      -- Your code here to display tooltip for healing spells
      local CritMaticHealLeft = "Highest Heal Crit: "
      local CritMaticHealRight = tostring(CritMaticData[spellName].highestHealCrit) .. " (" .. format("%.1f", critHPS) .. " HPS)"
      local normalMaticHealLeft = "Highest Heal Normal: "
      local normalMaticHealRight = tostring(CritMaticData[spellName].highestHeal) .. " (" .. format("%.1f", normalHPS) .. " HPS)"
      local CritMaticLeft = "Highest Crit: "
      local CritMaticRight = tostring(CritMaticData[spellName].highestHealCrit) .. " (" .. format("%.1f", critDPS) .. " DPS)"
      local normalMaticLeft = "Highest Normal: "
      local normalMaticRight = tostring(CritMaticData[spellName].highestHeal) .. " (" .. format("%.1f", normalDPS) .. " DPS)"

      -- Check if lines are already present in the tooltip.
      local critHealMaticExists = false
      local normalHealMaticExists = false
      local critMaticExists = false
      local normalMaticExists = false

      for i = 1, self:NumLines() do
        local gtl = _G["GameTooltipTextLeft" .. i]
        local gtr = _G["GameTooltipTextRight" .. i]

        if gtl and gtr then
          -- Healing related
          if gtl:GetText() == CritMaticHealLeft and gtr:GetText() == CritMaticHealRight then
            critHealMaticExists = true
          elseif gtl:GetText() == normalMaticHealLeft and gtr:GetText() == normalMaticHealRight then
            normalHealMaticExists = true
          end
          -- Damage related
          if gtl:GetText() == CritMaticLeft and gtr:GetText() == CritMaticRight then
            critDamageMaticExists = true
          elseif gtl:GetText() == normalMaticLeft and gtr:GetText() == normalMaticRight then
            normalDamageMaticExists = true
          end
        end
      end
        -- If lines don't exist, add them.
        if not critHealMaticExists then
          self:AddDoubleLine(CritMaticHealLeft, CritMaticHealRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (white)
        end

        if not normalHealMaticExists then
          self:AddDoubleLine(normalMaticHealLeft, normalMaticHealRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (white)
        end

        if not critMaticExists then
          self:AddDoubleLine(CritMaticLeft, CritMaticRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (white)
        end
      if not normalMaticExists then
        self:AddDoubleLine(normalMaticLeft, normalMaticRight)
        _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
        _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (white)
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
  local eventInfo = { CombatLogGetCurrentEventInfo() }

  local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = unpack(eventInfo, 1, 11)
  local spellID, spellName, spellSchool, amount, overhealing, absorbed, critical

  if eventType == "SWING_DAMAGE" then
    spellName = "Auto Attack"
    spellID = 6603 -- or specify the path to a melee icon, if you have one
    amount, _, _, _, _, _, critical = unpack(eventInfo, 12, 18)
  elseif eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
    spellID, spellName, spellSchool = unpack(eventInfo, 12, 14)
    amount, overhealing, absorbed, critical = unpack(eventInfo, 15, 18)
  elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
    spellID, spellName, spellSchool = unpack(eventInfo, 12, 14)
    amount, overhealing, _, _, _, absorbed, critical = unpack(eventInfo, 15, 21)
  end

  if sourceGUID == UnitGUID("player") and destGUID ~= UnitGUID("player") and (eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" or eventType == "SPELL_PERIODIC_DAMAGE") and amount > 0 then
    if spellName then
      CritMaticData[spellName] = CritMaticData[spellName] or {
        highestCrit = 0,
        highestNormal = 0,
        highestHeal = 0,
        highestHealCrit = 0,
        spellIcon = GetSpellTexture(spellID)
      }

      --print(CombatLogGetCurrentEventInfo())

      if eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
        if critical then
          if spellName == "Auto Attack" then
            return
          end
          -- When the event is a heal and it's a critical heal.
          if amount > CritMaticData[spellName].highestHealCrit then
            CritMaticData[spellName].highestHealCrit = amount
            print("testing " .. spellName .. ": " .. CritMaticData[spellName].highestHealCrit)
            PlaySound(888, "SFX")
            CritMatic.ShowNewHealCritMessage(spellName, amount)
            print("New highest crit heal for " .. spellName .. ": " .. CritMaticData[spellName].highestHealCrit)
          end
        elseif not critical then
          -- When the event is a heal but it's not a critical heal.
          if spellName == "Auto Attack" then
            return
          end
          if amount > CritMaticData[spellName].highestHeal then
            CritMaticData[spellName].highestHeal = amount
            PlaySound(10049, "SFX")
            CritMatic.ShowNewHealMessage(spellName, amount)
            print("New highest normal heal for " .. spellName .. ": " .. CritMaticData[spellName].highestHeal)
          end
        end
      elseif eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
        if critical then
          -- When the event is damage and it's a critical hit.
          if spellName == "Auto Attack" then
            return
          end
          if amount > CritMaticData[spellName].highestCrit then
            CritMaticData[spellName].highestCrit = amount
            PlaySound(888, "SFX")
            CritMatic.ShowNewCritMessage(spellName, amount)
            print("New highest crit hit for " .. spellName .. ": " .. CritMaticData[spellName].highestCrit)
          end
        elseif not critical then
          -- When the event is damage but it's not a critical hit.
          if spellName == "Auto Attack" then
            return
          end
          if amount > CritMaticData[spellName].highestNormal then
            CritMaticData[spellName].highestNormal = amount
            PlaySound(10049, "SFX")
            CritMatic.ShowNewNormalMessage(spellName, amount)
            print("New highest normal hit for " .. spellName .. ": " .. CritMaticData[spellName].highestNormal)
          end
        end
      end

    end
  end
end)

-- Register an event that fires when the addon is loaded.
local function OnLoad(self, event, addonName)
  if addonName == "CritMatic" then
    print("CritMatic Loaded!")

    CritMaticData = _G["CritMaticData"]

    -- Add the highest hits data to the spell button tooltip.
    hooksecurefunc(GameTooltip, "SetAction", AddHighestHitsToTooltip)
  end
end
local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnLoad)

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

SLASH_CRITMATICRESET1 = '/cmreset'
function SlashCmdList.CRITMATICRESET(msg, editBox)
  ResetData()
end
