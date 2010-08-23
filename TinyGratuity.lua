local _G = getfenv(0)
local LibStub = _G.LibStub
local pairs = _G.pairs
local setmetatable = _G.setmetatable

local Heatsink = LibStub("AceAddon-3.0"):GetAddon("Heatsink")
Heatsink.tooltip = _G.CreateFrame("GameTooltip")
Heatsink.tooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
local tooltip = Heatsink.tooltip

local lcache, rcache = {}, {}
for i=1,30 do
	lcache[i] = tooltip:CreateFontString()
	rcache[i] = tooltip:CreateFontString()
	lcache[i]:SetFontObject(_G.GameFontNormal)
	rcache[i]:SetFontObject(_G.GameFontNormal)
	tooltip:AddFontStrings(lcache[i], rcache[i])
end


-- GetText cache tables, provide fast access to the tooltip's text
tooltip.R = setmetatable({}, {
	__index = function(t, key)
		if tooltip:NumLines() >= key and rcache[key] then
			local v = rcache[key]:GetText()
			t[key] = v
			return v
		end
		return nil
	end,
})


local orig = tooltip.SetSpell
tooltip.SetSpell = function(self, ...)
	self:ClearLines() -- Ensures tooltip's NumLines is reset
	for i in pairs(self.R) do self.R[i] = nil end -- Flush the metatable cache
	if not self:IsOwned(_G.WorldFrame) then self:SetOwner(_G.WorldFrame, "ANCHOR_NONE") end
	return orig(self, ...)
end
