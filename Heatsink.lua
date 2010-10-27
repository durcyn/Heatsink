local _G = getfenv(0)
local LibStub = _G.LibStub
local Heatsink = LibStub("AceAddon-3.0"):NewAddon("Heatsink", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0", "AceHook-3.0")
_G.Heatsink = Heatsink

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Heatsink")
local candy = LibStub("LibCandyBar-3.0")
local icd = LibStub("LibInternalCooldowns-1.0")
local media = LibStub("LibSharedMedia-3.0")
local AceGUIWidgetLSMlists = _G.AceGUIWidgetLSMlists

local RUNECD = 10

local anchor, db, class, guid
local delay = {}
local player
local pet
local force

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
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local UnitGUID = _G.UnitGUID
local ipairs = _G.ipairs
local pairs = _G.pairs
local unpack = _G.unpack
local tostring = _G.tostring
local tonumber = _G.tonumber
local wipe = _G.wipe
local format = _G.string.format
local find = _G.string.find
local random = _G.math.random
local tinsert = _G.table.insert
local tremove = _G.table.remove
local tsort = _G.table.sort

local slots = {	
		[(GetInventorySlotInfo("HeadSlot"))] = true, -- Engineering Mind Control stuff
		[(GetInventorySlotInfo("NeckSlot"))] = true, -- Black Templte exalted quest neck, what else?
--		[(GetInventorySlotInfo("ShoulderSlot"))] = true,
		[(GetInventorySlotInfo("BackSlot"))] = true, -- Engineering parachutes
--		[(GetInventorySlotInfo("ChestSlot"))] = true,
--		[(GetInventorySlotInfo("ShirtSlot"))] = true,
		[(GetInventorySlotInfo("TabardSlot"))] = true, -- Argent Crusade teleporter
--		[(GetInventorySlotInfo("WristSlot"))] = true,
		[(GetInventorySlotInfo("HandsSlot"))] = true, -- Engineering Rockets
--		[(GetInventorySlotInfo("WaistSlot"))] = true,
--		[(GetInventorySlotInfo("LegsSlot"))] = true,
		[(GetInventorySlotInfo("FeetSlot"))] = true, -- Engineering Rocket Boots
		[(GetInventorySlotInfo("Finger0Slot"))] = true, -- Kirin Tor rings, et al
		[(GetInventorySlotInfo("Finger1Slot"))] = true,
		[(GetInventorySlotInfo("Trinket0Slot"))] = true, 
		[(GetInventorySlotInfo("Trinket1Slot"))] = true,
--		[(GetInventorySlotInfo("MainHandSlot"))] = true,
--		[(GetInventorySlotInfo("SecondaryHandSlot"))] = true,
--		[(GetInventorySlotInfo("RangedSlot"))] = true,
	}

local substitute = {
	[L["Mana Jade"]] = L["Stones"],
	[L["Mana Ruby"]] = L["Stones"],
	[L["Mana Citrine"]] = L["Stones"],
	[L["Mana Agate"]] = L["Stones"],
	[L["Mana Emerald"]] = L["Stones"],
	[L["Healthstone$"]] = L["Stones"],
	[L["Potion"]] = L["Potions"],
	[L["Injector"]] = L["Potions"],
	[L["Blue Ogre Brew Special"]]= L["Potions"],  --Ogri'la
	[L["Red Ogre Brew Special"]] = L["Potions"],  --Ogri'la
	[L["Blue Ogre Brew"]]= L["Potions"],  --Ogri'la
	[L["Red Ogre Brew"]] = L["Potions"],  --Ogri'la
	[L["Bottled Nethergon Energy"]] = L["Potions"],  --Tempest Keep
	[L["Bottled Nethergon Vapor"]] = L["Potions"],   --Tempest Keep
	[L["Cenarion Mana Salve"]] = L["Potions"],   --Cenarion Expedition
	[L["Cenarion Healing Salve"]] = L["Potions"],   --Cenarion Expedition
	[L["Major Healing Draught"]] = L["Potions"],   --PvP
	[L["Major Mana Draught"]] = L["Potions"],   --PvP
	[L["Superior Mana Draught"]] = L["Potions"],   --PvP
	[L["Superior Healing Draught"]] = L["Potions"],   --PvP
	[L["Noth's Special Brew"]] = L["Potions"], -- Deathknight Starting Area
}

local FIRE = L["%s School"]:format(_G.STRING_SCHOOL_FIRE)
local SHADOW = L["%s School"]:format(_G.STRING_SCHOOL_SHADOW)
local FROST = L["%s School"]:format(_G.STRING_SCHOOL_FROST)
local HOLY = L["%s School"]:format(_G.STRING_SCHOOL_HOLY)
local NATURE = L["%s School"]:format(_G.STRING_SCHOOL_NATURE)
local ARCANE = L["%s School"]:format(_G.STRING_SCHOOL_ARCANE)

local schools = {
	["WARLOCK"] = {
		[SHADOW] = (GetSpellInfo(686)), -- 686 Shadow Bolt 
		[FIRE]   = (GetSpellInfo(348)), -- 348 Immolate
	},
	["MAGE"] = {
		[ARCANE] = (GetSpellInfo(5143)), -- 5143 Arcane Missiles 
		[FIRE]   = (GetSpellInfo(133)),  -- 133 Fireball
		[FROST]  = (GetSpellInfo(116)), -- 116 Frostbolt
	},
	["DRUID"] = {
		[ARCANE] = (GetSpellInfo(8921)), -- 8921 Moonfire
		[NATURE] = (GetSpellInfo(5176)), -- 5176 Wrath
	},
	["SHAMAN"] = {
		[NATURE]   = (GetSpellInfo(403)), -- 403 Lightning Bolt
		[FIRE]     = (GetSpellInfo(8024)), -- 8024 Flametongue Weapon
		[FROST]    = (GetSpellInfo(8033)), -- 8033 Frostbrand Weapon
	},
	["PRIEST"] = {
		[HOLY] = (GetSpellInfo(585)), --585 Smite
		[SHADOW] = (GetSpellInfo(589)), -- 589 Shadow Word: Pain
	},
	["PALADIN"] = {
		[HOLY] = (GetSpellInfo(635)), -- 635 Holy Light
	},
}

local runewhitelist = { 
	[(GetSpellInfo(47528))] = true, -- 47528 Mind Freeze
} 

local resets = {
	[(GetSpellInfo(11958))] = true, -- 11958 Cold Snap
	[(GetSpellInfo(14185))] = true, -- 14185 Preparation
	[(GetSpellInfo(23989))] = true, -- 23989 Readiness
}

local chains = {
	[(GetSpellInfo(1856))] = (GetSpellInfo(1784)), -- 1856 Vanish -- 1784 Stealth
	[(GetSpellInfo(86213))] = (GetSpellInfo(86121)), -- 86213 Soul Swap Exhale, --86121 Soul Swap
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
	
	function startBar(text, start, duration, icon)
		if (duration >= db.min and duration <= db.max) then
			local bar = candy:New(media:Fetch("statusbar", db.texture), db.width, db.height)
			bar:Set("anchor", anchor)
			anchor.active[bar] = duration
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
		local duration = random(5, 20)
		startBar("Hourglass "..duration, nil, duration, "test")
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
			equipped = true,
			inventory = true,
			proc = true,
		},
	},
}

local options = {
	type = "group",
	args = {
		toggle = {
			type = "execute",
			name = L["Toggle anchor"],
			desc = L["Toggle the bar anchor frame"],
			func = function()
					Heatsink:ToggleAnchor()
				end,
			order = 10,
		},
		test = {
			type = "execute",
			name = L["Test"],
			desc = L["Test bars"],
			func = function()
					Heatsink:RunTest()
				end,
			order = 20,
		},
		duration = {
			name = "Duration settings",
			desc = "Duration settings",
			type = "group",
			args = {
				min = {
					type = "input",
					name = L["Minimum duration"],
					desc = L["Minimum cooldown duration to display"],
					pattern = "%d+",
					get = function() return tostring(Heatsink.db.profile.min) end,
					set = function(info, v) Heatsink.db.profile.min = tonumber(v) end,
					order = 1,
				},
				max = {
					type = "input",
					name = L["Maximum duration"],
					desc = L["Maximum cooldown duration to display"],
					pattern = "%d+",
					get = function() return tostring(Heatsink.db.profile.max) end,
					set = function(info, v) Heatsink.db.profile.max = tonumber(v) end,
					order = 2, 
				},
			},
		},
		bars = {
			order = 10,
			type = "group",
			name = L["Bar settings"],
			desc = L["Bar settings"],
			args = {
				growup = {
					type = "toggle",
					order = 10,
					name = L["Grow upwards"],
					desc = L["Toggle bars grow upwards/downwards from anchor"],
					get = function () return Heatsink.db.profile.growup end,
					set = function (info, v)
							Heatsink.db.profile.growup = v
							Heatsink:UpdateAnchor()
						end,
				},
				scale = {
					type = "range",
					order = 20,
					name = L["Scale"],
					desc = L["Set the scale of the bars"],
					get = function() return Heatsink.db.profile.scale end,
					set = function(info, v)
							Heatsink.db.profile.scale = v
							Heatsink:UpdateAnchor()
						end,
					min = 0.1,
					max = 5,
					step = 0.01,
					isPercent = true,
				},
				texture = {
					type = "select",
					dialogControl = "LSM30_Statusbar",
					order = 30,
					name = L["Texture"],
					desc = L["Set the texture for the timer bars"],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function() return Heatsink.db.profile.texture end,
					set = function(i,v)
							Heatsink.db.profile.texture = v
							Heatsink:UpdateAnchor()
						end,
				},
				barcolor = {
					type = "color",
					hasAlpha = true,
					order = 40,
					name = L["Bar Color"],
					desc = L["Set the bar color"],
					get = function() return unpack(Heatsink.db.profile.color.bar) end,
					set = function(i,r,g,b,a)
							Heatsink.db.profile.color.bar = { r, g, b, a }
							Heatsink:UpdateAnchor()
						end,
				},
				bgcolor = {
					type = "color",
					hasAlpha = true,
					order = 50,
					name = L["Background Color"],
					desc = L["Set the background color"],
					get = function() return unpack(Heatsink.db.profile.color.bg) end,
					set = function(i,r,g,b,a)
							Heatsink.db.profile.color.bg = { r, g, b, a }
							Heatsink:UpdateAnchor()
						end,
				},
				font = {
					type = "select",
					dialogControl = "LSM30_Font",
					order = 60,
					name = L["Font"],
					desc = L["Set the font"],
					values = AceGUIWidgetLSMlists.font,
					get = function() return Heatsink.db.profile.font end,
					set = function(i,v)
							Heatsink.db.profile.font = v
							Heatsink:UpdateAnchor()
						end,
				},
				fontsize = {
					type = "range",
					order = 70,
					name = L["Font Size"],
					desc = L["Set the font size"],
					min = 8,
					max = 24,
					step = 1,
					get = function() return Heatsink.db.profile.fontsize end,
					set = function(i,v)
							Heatsink.db.profile.fontsize = v
							Heatsink:UpdateAnchor()
						end,
				},
				justify = {
					type = "select",
					order = 80,
					name = L["Justify"],
					desc = L["Set the text position"],
					values = {["left"]="LEFT", ["center"]="CENTER"},
					get = function() return Heatsink.db.profile.justify end,
					set = function(i,v)
							Heatsink.db.profile.justify = v
							Heatsink:UpdateAnchor()
						end,
				},
				textcolor = {
					type = "color",
					order = 90,
					name = L["Text Color"],
					desc = L["Set the text color"],
					get = function() return unpack(Heatsink.db.profile.color.text) end,
					set = function(i,r,g,b,a)
							Heatsink.db.profile.color.text = { r, g, b, a }
							Heatsink:UpdateAnchor()
						end,
				},
			},
		},
		show = {
			type = "group",
			name = L["Show cooldowns"],
			desc = L["Toggle showing cooldown types"],
			args = {
				spells = {
					type = "group",
					name = L["Spells"],
					desc = L["Player spells cooldown options"],
					args = {
						enable = {
							type = "toggle",
							name = L["Enable player spells"],
							desc = L["Toggle showing player spells cooldowns"],
							get = function () return Heatsink.db.profile.show.spells end,
							set = function (info, v)
									Heatsink.db.profile.show.spells = v
									Heatsink:SPELL_UPDATE_COOLDOWN()
								end,
							order = 10,
						},
						school = {
							type = "toggle",
							name = L["Show school"],
							desc = L["Spawns single bar if a school is locked out"],
							get = function () return Heatsink.db.profile.show.school end,
							set = function (info, v)
									Heatsink.db.profile.show.school = v
								end,
							disabled = function ()
									   return not Heatsink.db.profile.show.school
								   end,
							order = 100,
						},
					},
					order = 10,
				},
				petspells = {
					type = "toggle",
					name = L["Pet spells"],
					desc = L["Toggle showing pet cooldowns"],
					get = function () return Heatsink.db.profile.show.pet end,
					set = function (info, v)
						Heatsink.db.profile.show.pet = v
						Heatsink:PET_BAR_UPDATE_COOLDOWN()
					end,
					order = 20,
				},
				equipped = {
					type = "toggle",
					name = L["Equipped items"],
					desc = L["Toggle showing equipped items cooldowns"],
					get = function () return Heatsink.db.profile.show.equipped end,
					set = function (info, v)
						Heatsink.db.profile.show.equipped = v
						Heatsink:UNIT_INVENTORY_CHANGED()
					end,
					order = 30,
				},
				bags = {
					type = "toggle",
					name = L["Inventory items"],
					desc = L["Toggle showing inventory items cooldowns"],
					get = function () return Heatsink.db.profile.show.inventory end,
					set = function (info, v)
						Heatsink.db.profile.show.inventory = v
						Heatsink:BAG_UPDATE_COOLDOWN()
					end,
					order = 40,
				},
				proc = {
					type = "toggle",
					name = L["Internal Cooldowns"],
					desc = L["Toggle showing item internal proc cooldowns"],
					get = function () return Heatsink.db.profile.show.proc end,
					set = function (info, v)
						Heatsink.db.profile.show.proc = v
					end,
					order = 50,
				},
			},
		},
	},
}

function Heatsink:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HeatsinkDB", defaults, "Default")
	db = self.db.profile
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateProfile")
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Heatsink", options)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Heatsink.db)
	local optFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Heatsink")
	LibStub("AceConsole-3.0"):RegisterChatCommand( "heatsink", function() InterfaceOptionsFrame_OpenToCategory("Heatsink") end )
	anchor = createAnchor("HeatsinkAnchor", "Heatsink")
end

function Heatsink:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self:RegisterBucketEvent("UNIT_INVENTORY_CHANGED", 0.5)
	self:RegisterBucketEvent("BAG_UPDATE_COOLDOWN", 0.5)

	icd.RegisterCallback(self, "InternalCooldowns_Proc")
	candy.RegisterCallback(self, "LibCandyBar_Stop")

	self:UNIT_INVENTORY_CHANGED()
	self:BAG_UPDATE_COOLDOWN()

	guid = UnitGUID("player")
	local unused, english = UnitClass("player")
	class = english
	if class == "SHAMAN" then
		self:SecureHook("UseSoulstone", function()
			force = 20608 -- 20608 Reincarnation
		end)
	end
end

function Heatsink:OnDisable()
	self:UnregisterAllEvents()
	self:UnhookAll()
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

function Heatsink:COMBAT_LOG_EVENT_UNFILTERED(callback, timestamp, subevent, srcGUID, src, srcFlags, dstGUID, dst, dstFlags, spellID, spell, spellSchool, extraID, extra, extraSchool, auratype)
	if subevent == "SPELL_INTERRUPT" and dstGUID == guid then
		if class and schools[class] then
			for school, spell in pairs(schools[class]) do
				local start, duration, enabled = GetSpellCooldown(school)
				if enabled == 1 then
					local name, rank, icon = GetSpellInfo(spell)
					startBar(school, start, duration, icon)
				end
			end
		end
	end
end

function Heatsink:UNIT_SPELLCAST_SUCCEEDED(callback, unit, spell)
	if db.show.spells then
		if unit == "player" then
			player = spell
			for k,v in pairs(chains) do
				if k == spell then
					tinsert(delay, v)
				end
			end
			for k,v in pairs(resets) do
				if k == spell then
					for bar, max in pairs(anchor.active) do
						local text = bar.candyBarLabel:GetText()
						local start, duration, enabled = GetSpellCooldown(text)
						if duration and duration <= 1.5 and max > 1.5 then
							stopBar(text)
						end
					end
				end
			end
		elseif unit =="pet" then
			pet = spell
		end
	end
end

function Heatsink:SPELL_UPDATE_COOLDOWN()
	if db.show.spells then
		for index, spell in pairs(delay) do
			local start, duration, enabled = GetSpellCooldown(spell)
			if enabled == 1 then
				local name, rank, icon = GetSpellInfo(spell)
				startBar(name, start, duration, icon)
				tremove(delay, index)
			end
		end
		if player then
			local start, duration, enabled = GetSpellCooldown(player)
			if class == "DEATHKNIGHT" and duration == RUNECD and not runewhitelist[player] then enabled = -1 end
			if enabled == 1 then
				local name, rank, icon = GetSpellInfo(player)
				startBar(name, start, duration, icon)
				player = nil
			elseif enabled == 0 and duration > 0 then
				tinsert(delay, player)
			end
		end
	end
	if force then
		local name, rank, icon = GetSpellInfo(force)
		local start, duration, enabled = GetSpellCooldown(name)
		if enabled == 1 then
			startBar(name, start, duration, icon)
			force = nil
		end
	end
	for bar in pairs(anchor.active) do
		local name = bar.candyBarLabel:GetText() or nil
		if name then
			local start, duration, enabled = GetSpellCooldown(name)
			if enabled == 0 then
				stopBar(name)
			end
		end
	end
end

function Heatsink:PET_BAR_UPDATE_COOLDOWN()
	if db.show.spells and pet then
		local start, duration, enabled = GetSpellCooldown(pet)
		if enabled == 1 then
			local name, rank, icon = GetSpellInfo(pet)
			startBar(name, start, duration, icon)
			pet = nil
		end
	end
end

function Heatsink:UNIT_INVENTORY_CHANGED()
	if db.show.equipped then
		for slot in pairs(slots) do
			local start, duration, enabled = GetInventoryItemCooldown("player", slot)
			if enabled == 1 then
				local _,_,name = GetInventoryItemLink("player", slot):find("%|h%[(.-)%]%|h")
				if duration > db.min and duration <= db.max then
					local icon = GetInventoryItemTexture("player", slot)
					startBar(name, start, duration, icon)
				end
			end
		end
	end
end

function Heatsink:BAG_UPDATE_COOLDOWN()
	self:UNIT_INVENTORY_CHANGED()
	if db.show.inventory then
		for bag = 0,4 do
			local bagslots = GetContainerNumSlots(bag)
			for slot = 1, bagslots do
				local start, duration, enabled = GetContainerItemCooldown(bag,slot)
				if enabled == 1 then
					local link = GetContainerItemLink(bag, slot)
					local _,_,name = link:find("%|h%[(.-)%]%|h")
					local icon = GetContainerItemInfo(bag, slot)
					for old,new in pairs(substitute) do
						if name:find(old) then
							name = new
						end
					end
					startBar(name, start, duration, icon)
				end
			end
		end
	end
end

