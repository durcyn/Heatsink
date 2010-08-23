local _G = getfenv(0)
local LibStub = _G.LibStub
local Heatsink = LibStub("AceAddon-3.0"):NewAddon("Heatsink", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
_G.Heatsink = Heatsink

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Heatsink")
local candy = LibStub("LibCandyBar-3.0")
local icd = LibStub("LibInternalCooldowns-1.0")
local media = LibStub("LibSharedMedia-3.0")
local anchor, db, class

local RUNE_COOLDOWN = 10
local GCD = 1.5

local BOOKTYPE_PET = _G.BOOKTYPE_PET
local BOOKTYPE_SPELL = _G.BOOKTYPE_SPELL
local CreateFrame = _G.CreateFrame
local GameFontNormal = _G.GameFontNormal
local GetContainerItemCooldown = _G.GetContainerItemCooldown
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetInventoryItemCooldown = _G.GetInventoryItemCooldown
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetInventorySlotInfo = _G.GetInventorySlotInfo
local GetItemInfo = _G.GetItemInfo
local GetNumSpellTabs = _G.GetNumSpellTabs
local GetRealZoneText = _G.GetRealZoneText
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local GetSpellName = _G.GetSpellName
local GetSpellTabInfo = _G.GetSpellTabInfo
local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local UnitGUID = _G.UnitGUID
local ipairs = _G.ipairs
local pairs = _G.pairs
local unpack = _G.unpack
local wipe = _G.wipe

local format = _G.string.format
local find = _G.string.find
local random = _G.math.random
local tinsert = _G.table.insert
local tsort = _G.table.sort


local defaults = {
	profile = {
		min = 3,
		max = 3600,
		growup = true,
		texture = "Blizzard",
		font = "ABF",
		fontsize = 10,
		justify = "CENTER",
		width = 250,
		height = 14,
		scale = 1,
		pos = {
			p = "CENTER",
			rp = "CENTER",
			x = 0,
			y = 0,
		},
		color = {
			bg = { 0.5, 0.5, 0.5, 0.3 },
			text = { 1, 1, 1 },
			bar = { 0.25, 0.33, 0.68, 1 },
		},
		show = {
			school = true,
			spells = true,
			pet = true,
			items = true,
			inventory = true,
			proc = true,
		},
	},
}

-- Credit to the BigWigs team (Rabbit, Ammo, et al) for the anchor code 
local createAnchor, toggleAnchor, updateAnchor, runTest, startBar, stopBar
do
	local GameTooltip = _G.GameTooltip

	local function sortBars(a, b)
		return (a.remaining > b.remaining and db.growup) and true or false
	end

	local function rearrangeBars(anchor)
		local tmp = {}
		for bar in pairs(anchor.active) do
			tinsert(tmp, bar)
		end
		tsort(tmp, sortBars)
		local lastBar = nil
		for i, bar in ipairs(tmp) do
			bar:ClearAllPoints()
			if db.growup then
				bar:SetPoint("BOTTOMLEFT", lastBar or anchor, "TOPLEFT")
				bar:SetPoint("BOTTOMRIGHT", lastBar or anchor, "TOPRIGHT")
			else
				bar:SetPoint("TOPLEFT", lastBar or anchor, "BOTTOMLEFT")
				bar:SetPoint("TOPRIGHT", lastBar or anchor, "BOTTOMRIGHT")
			end
			lastBar = bar
		end
		wipe(tmp)
	end

	local function onDragHandleMouseDown(self)
		self:GetParent():StartSizing("BOTTOMRIGHT")
	end
	
	local function onDragHandleMouseUp(self, button)
		self:GetParent():StopMovingOrSizing()
	end
	
	local function onResize(self, width)
		db.width = width
		rearrangeBars(self)
	end
	
	local function onDragStart(self)
		self:StartMoving()
	end
	
	local function onDragStop(self)
		self:StopMovingOrSizing()
		local p, _, rp, x, y = self:GetPoint()
		db.pos.p = p
		db.pos.rp = rp
		db.pos.x = x
		db.pos.y = y
	end

	local function onControlEnter(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(self.tooltipHeader)
		GameTooltip:AddLine(self.tooltipText, 1, 1, 1, 1)
		GameTooltip:Show()
	end
	
	local function onControlLeave()
		GameTooltip:Hide()
	end
	
	local function getBar(text)
		local bar
		for k in pairs(anchor.active) do
			if k.candyBarLabel:GetText() == text then
				bar = true
				break
			end
		end
		return bar
	end
	
	function stopBar(text)
		local bar
		for k in pairs(anchor.active) do
			if (not text or k.candyBarLabel:GetText() == text) then
				k:Stop()
				bar = true
			end
		end
		if bar then rearrangeBars(anchor) end
		return bar
	end
	
	function startBar(text, start, duration, icon, update)
		if getBar(text) and not update then
			return
		elseif duration >= db.min and duration <= db.max then
			stopBar(text)
			local bar = candy:New(media:Fetch("statusbar", db.texture), db.width, db.height)
			bar:Set("anchor", anchor)
			anchor.active[bar] = true
			bar.candyBarBackground:SetVertexColor(unpack(db.color.bg))
			bar:SetColor(unpack(db.color.bar))
			bar.candyBarLabel:SetJustifyH(db.justify)
			bar.candyBarLabel:SetTextColor(unpack(db.color.text))
			bar.candyBarLabel:SetFont(media:Fetch("font", db.font), db.fontsize)
			bar.candyBarDuration:SetFont(media:Fetch("font", db.font), db.fontsize)
			bar:SetLabel(text)
			bar:SetDuration(start and (duration-(GetTime()-start)) or duration)
			bar:SetTimeVisibility(true)
			bar:SetIcon(icon)
			bar:SetScale(db.scale)
			bar:Start()
			rearrangeBars(anchor)
		end
	end
	
	function runTest(anchor)
		local tmp = {}
		for i = 2, GetNumSpellTabs() do
			local name, texture, offset, numSpells = GetSpellTabInfo(i)
			if offset then
				for s = offset + 1, offset + numSpells do
					tinsert(tmp, (GetSpellName(s, BOOKTYPE_SPELL)))
				end
			end
		end
		local spell = tmp[random(1, #tmp)]
		local name, rank, icon = GetSpellInfo(spell)
		local duration = random(10, 30)
		startBar(name, nil, duration, icon)
		wipe(tmp)
	end
	
	function toggleAnchor(anchor)
		if anchor:IsShown() then
			anchor:Hide()
		else
			anchor:Show()
		end
	end
	
	function createAnchor(frameName, title)
		local display = CreateFrame("Frame", frameName, _G.UIParent)
		display:EnableMouse(true)
		display:SetMovable(true)
		display:SetResizable(true)
		display:RegisterForDrag("LeftButton")
		display:SetWidth(db.width)
		display:SetHeight(20)
		display:SetMinResize(80, 20)
		display:SetMaxResize(1920, 20)
		display:ClearAllPoints()
		display:SetPoint(db.pos.p, _G.UIParent, db.pos.rp, db.pos.x, db.pos.y)
	
		local bg = display:CreateTexture(nil, "PARENT")
		bg:SetAllPoints(display)
		bg:SetBlendMode("BLEND")
		bg:SetTexture(0, 0, 0, 0.3)
	
		local header = display:CreateFontString(nil, "OVERLAY")
		header:SetFontObject(GameFontNormal)
		header:SetText(title)
		header:SetAllPoints(display)
		header:SetJustifyH("CENTER")
		header:SetJustifyV("MIDDLE")
	
		local drag = CreateFrame("Frame", nil, display)
		drag:SetFrameLevel(display:GetFrameLevel() + 10)
		drag:SetWidth(16)
		drag:SetHeight(16)
		drag:SetPoint("BOTTOMRIGHT", display, -1, 1)
		drag:EnableMouse(true)
		drag:SetScript("OnMouseDown", onDragHandleMouseDown)
		drag:SetScript("OnMouseUp", onDragHandleMouseUp)
		drag:SetAlpha(0.5)
	
		local tex = drag:CreateTexture(nil, "BACKGROUND")
		tex:SetTexture("Interface\\AddOns\\Heatsink\\Textures\\draghandle")
		tex:SetWidth(16)
		tex:SetHeight(16)
		tex:SetBlendMode("ADD")
		tex:SetPoint("CENTER", drag)
	
		local test = CreateFrame("Button", nil, display)
		test:SetPoint("BOTTOMLEFT", display, "BOTTOMLEFT", 3, 3)
		test:SetHeight(14)
		test:SetWidth(14)
		test.tooltipHeader = L["Test"]
		test.tooltipText = L["Creates a new test bar"]
		test:SetScript("OnEnter", onControlEnter)
		test:SetScript("OnLeave", onControlLeave)
		test:SetScript("OnClick", function() runTest() end)
		test:SetNormalTexture("Interface\\AddOns\\Heatsink\\Textures\\test")
	
		local close = CreateFrame("Button", nil, display)
		close:SetPoint("BOTTOMLEFT", test, "BOTTOMRIGHT", 4, 0)
		close:SetHeight(14)
		close:SetWidth(14)
		close.tooltipHeader = L["Hide"]
		close.tooltipText = L["Hides the anchor"]
		close:SetScript("OnEnter", onControlEnter)
		close:SetScript("OnLeave", onControlLeave)
		close:SetScript("OnClick", function() toggleAnchor(anchor) end)
		close:SetNormalTexture("Interface\\AddOns\\Heatsink\\Textures\\close")
	
		display:SetScript("OnSizeChanged", onResize)
		display:SetScript("OnDragStart", onDragStart)
		display:SetScript("OnDragStop", onDragStop)
		display.active = {}
		display:Hide()
		return display
	end
	
	function updateAnchor(anchor)
		anchor:SetWidth(db.width)
		for bar in pairs(anchor.active) do
			bar.candyBarBar:SetStatusBarTexture(media:Fetch("statusbar", db.texture))
			bar.candyBarBackground:SetTexture(media:Fetch("statusbar", db.texture))
			bar.candyBarBackground:SetVertexColor(unpack(db.color.bg))
			bar.candyBarBar:SetStatusBarColor(unpack(db.color.bar))
			bar.candyBarLabel:SetJustifyH(db.justify)
			bar.candyBarLabel:SetTextColor(unpack(db.color.text))
			bar.candyBarLabel:SetFont(media:Fetch("font", db.font), 10)
			bar.candyBarDuration:SetFont(media:Fetch("font", db.font), 10)
			bar:SetScale(db.scale)
			bar:SetWidth(db.width)
			bar:SetHeight(db.height)
		end	
		rearrangeBars(anchor)
	end
end

function Heatsink:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HeatsinkDB", defaults, "Default")
	db = self.db.profile
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateProfile")
	self:SetupOptions()
	anchor = createAnchor("HeatsinkAnchor", "Heatsink")
end

function Heatsink:OnEnable()
	local _, english = UnitClass("player")
	class = english

	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterBucketEvent("PET_BAR_UPDATE_COOLDOWN", 0.1)
	self:RegisterBucketEvent("SPELL_UPDATE_COOLDOWN", 1.0)
	self:RegisterBucketEvent("UNIT_INVENTORY_CHANGED", 0.1, "ScanItems")
	self:RegisterBucketEvent("BAG_UPDATE_COOLDOWN", 0.1,"ScanItems")

	icd.RegisterCallback(self, "InternalCooldowns_Proc")
	candy.RegisterCallback(self, "LibCandyBar_Stop")

	self:ScanPlayer()
	self:ScanPet()
	self:ScanItems()
end

function Heatsink:OnDisable()
	self:UnregisterAllEvents()

	icd.UnregisterCallback(self, "InternalCooldowns_Proc")
	candy.UnregisterCallback(self, "LibCandyBar_Stop")
end

function Heatsink:UpdateProfile()
	db = self.db.profile
	updateAnchor(anchor)
end

function Heatsink:RunTest()
	runTest(anchor)
end

function Heatsink:ToggleAnchor()
	toggleAnchor(anchor)
end

function Heatsink:UpdateAnchor()
	updateAnchor(anchor)
end

function Heatsink:LibCandyBar_Stop(callback, bar)
	local a = bar:Get("anchor")
	if a == anchor and anchor.active and anchor.active[bar] then
		anchor.active[bar] = nil
	end
end

function Heatsink:InternalCooldowns_Proc(callback, item, spell, start, duration, source)
	if db.show.proc then
		local name, icon, _
		if source == "ENCHANT" then
			name, _, icon = GetSpellInfo(spell)
		else
			name, _, _, _, _, _, _, _, _, icon = GetItemInfo(item)
		end
		startBar(name, start, duration, icon)
	end
end

function Heatsink:SPELLS_CHANGED()
	self:ScanPlayer()
	self:ScanPet()
end

function Heatsink:SPELL_UPDATE_COOLDOWN()
	if db.show.spells then
		if db.show.school and self.schoolspell[class] then
			for school,id in pairs(self.schoolspell[class]) do
				local name, rank, icon = GetSpellInfo(id)
				local start, duration = GetSpellCooldown(name)
				if duration and duration > GCD then
					startBar(school, start, duration, icon)
					self.lockout[school] = true
				else
					self.lockout[school] = false
				end

			end
		end
		for spell, data in pairs(self.player) do
			local start, duration, active = GetSpellCooldown(data.id, BOOKTYPE_SPELL)
			if class == "DEATHKNIGHT" and duration == RUNE_COOLDOWN and not self.whitelist[spell] then
				duration = -1
			end
			if db.show.school and data.schoolname and self.lockout[data.schoolname] then
				duration = -1
			end
			if active ==1 and duration > GCD then
				startBar(self.spellsub[spell] or spell, start, duration, data.icon)
			elseif start == 0 and duration == 0 then
				stopBar(spell)
			end
		end
	end
end

function Heatsink:PET_BAR_UPDATE_COOLDOWN()
	if db.show.pet then
		for spell, data in pairs(self.pet) do
			local start, duration = GetSpellCooldown(data.id, BOOKTYPE_PET)
			if duration > 0 then
				startBar(spell, start, duration, data.icon)
			elseif duration == 0 then
				stopBar(spell)
			end
		end
	end
end

function Heatsink:ScanItems()
	if db.show.inventory then
		for bag = 0,4 do
			local slots = GetContainerNumSlots(bag)
			for slot = 1,slots do
				local start, duration, enabled = GetContainerItemCooldown(bag,slot)
				if enabled == 1 and duration > 0 then
					local link = GetContainerItemLink(bag, slot)
					local _,_,name = link:find("%|h%[(.-)%]%|h")
					local icon = GetContainerItemInfo(bag, slot)
					for k,v in pairs(self.itemsub) do
						if name:find(k) then
							name = v
						end
					end
					startBar(name, start, duration, icon)
				end
			end
		end
	end
	if db.show.items then
		for _, slotName in pairs(Heatsink.slots) do
			local slot = GetInventorySlotInfo(slotName)
			local start, duration, enabled = GetInventoryItemCooldown("player", slot)
			if enabled == 1 and duration > 0 then
				local _,_,name = GetInventoryItemLink("player", slot):find("%|h%[(.-)%]%|h")
				if duration > db.min and duration <= db.max then
					local icon = GetInventoryItemTexture("player", slot)
					startBar(name, start, duration, icon, true)
				end
			end
		end
	end
end

function Heatsink:ScanPlayer()
	self.player = self.player or {}
	wipe(self.player)
	local id
	for i = 1, GetNumSpellTabs() do
		local tab, texture, offset, numSpells = GetSpellTabInfo(i)
		for j = 1, numSpells do
			id = j + offset
			local name, rank, icon = GetSpellInfo(id, BOOKTYPE_SPELL)
			for f in pairs(self.notooltip) do
				if name == f then
					self.player[name] = {
						id = id,
						icon = icon,
					}
				end
			end
			if not self.player[name] then
				self.tooltip:SetSpell(id, BOOKTYPE_SPELL)
				for i = 1, Heatsink.tooltip:NumLines() do
					local line = Heatsink.tooltip.R[i]
					if line and line:find(L["cooldown$"]) then
						self.player[name] = {
							id = id,
							icon = icon,
						}
						if self.school[class] and self.player[name] then
							local school = self.school[class][name]
							if school then
								self.player[name].schoolname = school
							end
						end
					end
				end
			end
		end
	end
	self:SPELL_UPDATE_COOLDOWN()
end

function Heatsink:ScanPet()
	self.pet = self.pet or {}
	wipe(self.pet)
	local id = 1
	local previous
	local name, rank, icon = GetSpellInfo(id, BOOKTYPE_PET)
	while name do
		if name ~= previous then
			self.tooltip:SetSpell(id, BOOKTYPE_PET)
			for i = 1, self.tooltip:NumLines() do
				local line = self.tooltip.R[i] or ""
				if line:find(L["cooldown$"]) then
					self.pet[name] = {
						id = id,
						icon = icon,
					}
				break
				end
			end
		end
		id = id + 1
		previous = name
		name, rank, icon = GetSpellInfo(id, BOOKTYPE_PET)
	end
	self:PET_BAR_UPDATE_COOLDOWN()
end

