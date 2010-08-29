local _G = getfenv(0)
local LibStub = _G.LibStub
local Heatsink = LibStub("AceAddon-3.0"):GetAddon("Heatsink", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Heatsink")

local GetSpellInfo = _G.GetSpellInfo
local pairs = _G.pairs

local FIRE = L["%s School"]:format(_G.STRING_SCHOOL_FIRE)
local SHADOW = L["%s School"]:format(_G.STRING_SCHOOL_SHADOW)
local FROST = L["%s School"]:format(_G.STRING_SCHOOL_FROST)
local HOLY = L["%s School"]:format(_G.STRING_SCHOOL_HOLY)
local NATURE = L["%s School"]:format(_G.STRING_SCHOOL_NATURE)
local ARCANE = L["%s School"]:format(_G.STRING_SCHOOL_ARCANE)
local PHYSICAL = L["%s School"]:format(_G.STRING_SCHOOL_PHYSICAL)

local slots = {	"Trinket0Slot", 
		"Trinket1Slot",
		"Finger0Slot",
		"Finger1Slot",
		"HeadSlot"
	}

local spellsub = {
	[(GetSpellInfo(1499))] = L["Traps"], -- 1499 Freezing Trap
	[(GetSpellInfo(13795))] = L["Traps"], -- 13795 Immolation Trap
	[(GetSpellInfo(13809))] = L["Traps"], -- 13909 Immolation Trap
	[(GetSpellInfo(13813))] = L["Traps"], -- 13813 Explosive Trap
	[(GetSpellInfo(34600))] = L["Traps"], -- 34600 Snake Trap
	[(GetSpellInfo(8042))] = L["Shocks"], -- 8042 Earth Shock
	[(GetSpellInfo(8056))] = L["Shocks"], -- 8056 Frost Shock
	[(GetSpellInfo(8050))] = L["Shocks"], -- 8050 Flame Shock
	[(GetSpellInfo(53408))] = L["Judgement"], -- Judgement of Wisdom
	[(GetSpellInfo(20271))] = L["Judgement"], -- Judgement of Light
	[(GetSpellInfo(53407))] = L["Judgement"], -- Judgement of Justice
	[(GetSpellInfo(16979))] = (GetSpellInfo(49377)), -- 16979 Feral Charge - Bear, 49377 Feral Charge (Talent)
	[(GetSpellInfo(49376))] = (GetSpellInfo(49377)), -- 16979 Feral Charge - Cat,  49377 Feral Charge (Talent)
	[(GetSpellInfo(6572))] = L["Reactive Attacks"], -- 6572 Revenge
	[(GetSpellInfo(7384))] = L["Reactive Attacks"], -- 7384 Overpower
	[(GetSpellInfo(72))] = L["Interrupts"], -- 72 Shield Bash
	[(GetSpellInfo(6552))] = L["Interrupts"], -- 6552 Pummel
}

local itemsub = {
	-- items
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
	[L["Cenarion Healing Salve"]] = L["Potions"],   --enarion Expedition
	[L["Major Healing Draught"]] = L["Potions"],   --PvP
	[L["Major Mana Draught"]] = L["Potions"],   --PvP
	[L["Superior Mana Draught"]] = L["Potions"],   --PvP
	[L["Superior Healing Draught"]] = L["Potions"],   --PvP
	[L["Noth's Special Brew"]] = L["Potions"], -- Deathknight Starting Area
}

local schoolspell = {
	["WARLOCK"] = {
		[SHADOW] = 686, -- 686 Shadow Bolt 
		[FIRE]   = 5676, -- 5676 Searing Pain
	},
	["MAGE"] = {
		[ARCANE] = 5143, -- 5343 Arcane Missiles 
		[FIRE]   = 133,  -- 133 Fireball
		[FROST]  = 116, -- 116 Frostbolt
	},
	["DRUID"] = {
		[NATURE] = 5185, -- 5185 Healing Touch
	},
	["SHAMAN"] = {
		[NATURE]   = 403, -- 403 Lightning Bolt
		[FIRE]     = 8024, -- 8024 Flametongue Weapon
		[FROST]    = 8033, -- 8033 Frostbrand Weapon
		[PHYSICAL] = 8071, -- 8071 Stoneskin Totem
	},
	["PRIEST"] = {
		[HOLY] = 585, --585 Smite
		[SHADOW] = 589, -- 589 Shadow Word: Pain
	},
	["PALADIN"] = {
		[HOLY] = 635, -- 635 Holy Light
	},
}

local school = {
	["WARLOCK"] = {
		[(GetSpellInfo(603))] = SHADOW, -- 603 Curse of Doom
		[(GetSpellInfo(698))] = SHADOW, -- 698 Ritual of Summoning
		[(GetSpellInfo(1122))] = SHADOW, -- 1122 Inferno
		[(GetSpellInfo(5484))] = SHADOW, -- 5484 Howl of Terror
		[(GetSpellInfo(6229))] = SHADOW, -- 6229 Shadow Ward
		[(GetSpellInfo(6789))] = SHADOW, -- 6789 Death Coil
		[(GetSpellInfo(17877))] = SHADOW, -- 17877 Shadowburn
		[(GetSpellInfo(18708))] = SHADOW, -- 18708 Fel Domination
		[(GetSpellInfo(18540))] = SHADOW, -- 18540 Ritual of Doom
		[(GetSpellInfo(29858))] = SHADOW, -- 29858 Soulshatter
		[(GetSpellInfo(29893))] = SHADOW, -- 29893 Ritual of Souls
		[(GetSpellInfo(47897))] = SHADOW, -- 47897 Shadowflame
		[(GetSpellInfo(48020))] = SHADOW, -- 48020 Demonic Circle: Teleport
		[(GetSpellInfo(48181))] = SHADOW, -- 48181 Haunt 

		[(GetSpellInfo(50796))] = FIRE, -- 50796 Chaos Bolt
		[(GetSpellInfo(17962))] = FIRE, -- 17962 Conflagrate
	},
	["MAGE"] = {
		[(GetSpellInfo(66))] = ARCANE, -- 66 Invisibility
		[(GetSpellInfo(1953))] = ARCANE, -- 1953 Blink
		[(GetSpellInfo(2139))] = ARCANE, -- 2139 Counterspell
		[(GetSpellInfo(10059))] = ARCANE, -- 10059 Portal: Stormwind
		[(GetSpellInfo(11416))] = ARCANE, -- 11416 Portal: Ironforge
		[(GetSpellInfo(11417))] = ARCANE, -- 11417 Portal: Orgrimmar
		[(GetSpellInfo(11418))] = ARCANE, -- 11418 Portal: Undercity
		[(GetSpellInfo(11419))] = ARCANE, -- 11419 Portal: Darnassus
		[(GetSpellInfo(11420))] = ARCANE, -- 11420 Portal: Thunder Bluff
		[(GetSpellInfo(12042))] = ARCANE, -- 12042 Arcane Power
		[(GetSpellInfo(12043))] = ARCANE, -- 12043 Presence of Mind
		[(GetSpellInfo(12051))] = ARCANE, -- 12051 Evocation
		[(GetSpellInfo(32266))] = ARCANE, -- 32266 Portal: Exodar
		[(GetSpellInfo(32267))] = ARCANE, -- 32267 Portal: Silvermoon
		[(GetSpellInfo(33691))] = ARCANE, -- 33691 Portal: Shattrath

		[(GetSpellInfo(543))] = FIRE, -- 543 Fire Ward
		[(GetSpellInfo(1831))] = FIRE, -- 1831 Blast Wave
		[(GetSpellInfo(2136))] = FIRE, -- 2136 Fire Blast
		[(GetSpellInfo(31661))] = FIRE, -- 31661 Dragon's Breath

		[(GetSpellInfo(120))] = FROST, -- 120 Cone of Cold
		[(GetSpellInfo(122))] = FROST, -- 122 Frost Nova
		[(GetSpellInfo(6143))] = FROST, -- 6143 Frost Ward
		[(GetSpellInfo(11426))] = FROST, -- 11426 Ice Barrier
		[(GetSpellInfo(11958))] = FROST, -- 11958 Cold Snap
		[(GetSpellInfo(12472))] = FROST, -- 12472 Icy Veins
		[(GetSpellInfo(31687))] = FROST, -- 31687 Summon Water Elemental
		[(GetSpellInfo(45438))] = FROST, -- 45438 Ice Block
		[(GetSpellInfo(44572))] = FROST, -- 44572 Deep Freeze
	},
	["DRUID"] = {
		[(GetSpellInfo(740))] = NATURE, -- 740 Tranquility
		[(GetSpellInfo(29166))] = NATURE, -- 29166 Innervate
		[(GetSpellInfo(20484))] = NATURE, -- 20484 Rebirth
		[(GetSpellInfo(16857))] = NATURE, -- 16857 Faerie Fire (Feral)
		[(GetSpellInfo(22812))] = NATURE,  -- 22812 Barkskin
		[(GetSpellInfo(16689))] = NATURE, -- 16689 Nature's Grasp
		[(GetSpellInfo(16914))] = NATURE, -- 16914 Hurricane
	},
	["SHAMAN"] = {
		[(GetSpellInfo(421))] = NATURE, -- 421 Chain Lightning
		[(GetSpellInfo(556))] = NATURE, -- 556 Astral Recall
		[(GetSpellInfo(2062))] = NATURE, -- 2062 Earth Elemental Totem
		[(GetSpellInfo(2484))] = NATURE, -- 2484 Earthbind Totem
		[(GetSpellInfo(2825))] = NATURE, -- 2825 Bloodlust
		[(GetSpellInfo(5730))] = NATURE, -- 5730 Stoneclaw Totem
		[(GetSpellInfo(8042))] = NATURE, -- 8042 Earth Shock
		[(GetSpellInfo(8177))] = NATURE, -- 8177 Grounding Totem
		[(GetSpellInfo(16166))] = NATURE, -- 16166 Elemental Mastery
		[(GetSpellInfo(32182))] = NATURE, -- 32182 Heroism

		[(GetSpellInfo(2894))] = FIRE, -- 2894 Fire Elemental Totem
		[(GetSpellInfo(1535))] = FIRE, -- 1535 Fire Nova Totem
		[(GetSpellInfo(8050))] = FIRE, -- 8050 Flame Shock

		[(GetSpellInfo(8056))] = FROST, -- 8056 Frost Shock
		[(GetSpellInfo(16190))] = FROST, -- 16190 Mana Tide Totem

		[(GetSpellInfo(16188))] = PHYSICAL, -- 16188 Nature's Swiftness
		[(GetSpellInfo(17364))] = PHYSICAL, -- 17364 Stormstrike
	},
	["PRIEST"] = {
		[(GetSpellInfo(586))] = SHADOW, -- 586 Fade
		[(GetSpellInfo(8092))] = SHADOW, -- 8092 Mind Blast
		[(GetSpellInfo(32379))] = SHADOW, -- 32379 Shadow Word: Death
		[(GetSpellInfo(15407))] = SHADOW, -- 15407 Mind Flay
		[(GetSpellInfo(34433))] = SHADOW, -- 34433 Shadowfiend

		[(GetSpellInfo(19238))] = HOLY, -- 19238 Desperate Prayer
		[(GetSpellInfo(15263))] = HOLY, -- 15263 Holy Fire
		[(GetSpellInfo(27870))] = HOLY, -- 27870 Lightwell
		[(GetSpellInfo(33076))] = HOLY, -- 33076 Prayer of Mending
		[(GetSpellInfo(34863))] = HOLY, -- 34863 Circle of Healing
		[(GetSpellInfo(47540))] = HOLY, -- 47540 Penance
		[(GetSpellInfo(64843))] = HOLY, -- 64843 Divine Hymn
		[(GetSpellInfo(64901))] = HOLY, -- 64901 Hymn of Hope
	},
	["PALADIN"] = {
		[(GetSpellInfo(498))] = HOLY, -- 498 Divine Protection
		[(GetSpellInfo(633))] = HOLY, -- 633 Lay on Hands
		[(GetSpellInfo(642))] = HOLY, -- 642 Divine Shield
		[(GetSpellInfo(853))] = HOLY, -- 853 Hammer of Justice
		[(GetSpellInfo(879))] = HOLY, -- 879 Exorcism
		[(GetSpellInfo(2812))] = HOLY, -- 2812 Holy Wrath
		[(GetSpellInfo(10326))] = HOLY, -- 10326 Turn Evil
		[(GetSpellInfo(19752))] = HOLY, -- 19752 Divine Intervention
		[(GetSpellInfo(20216))] = HOLY, -- 20216 Divine Favor
		[(GetSpellInfo(20473))] = HOLY, -- 20473 Holy Shock
		[(GetSpellInfo(20271))] = HOLY, -- 20271 Judgement of Light
		[(GetSpellInfo(24275))] = HOLY, -- 24275 Hammer of Wrath
		[(GetSpellInfo(26573))] = HOLY, -- 26573 Consecration
		[(GetSpellInfo(31789))] = HOLY, -- 31789 Righteous Defense
		[(GetSpellInfo(31842))] = HOLY, -- 31842 Divine Illumination
		[(GetSpellInfo(31884))] = HOLY, -- 31884 Avenging Wrath
	},
}

local whitelist = { 
	[(GetSpellInfo(47528))] = true,
}

local notooltip = {
	[(GetSpellInfo(20608))] = true,
}

Heatsink.slots = Heatsink.slots or {}
for k,v in pairs(slots) do
	Heatsink.slots[k] = v
end

Heatsink.spellsub = Heatsink.spellsub or {}
for k,v in pairs(spellsub) do
	Heatsink.spellsub[k] = v
end

Heatsink.itemsub = Heatsink.itemsub or {}
for k,v in pairs(itemsub) do
	Heatsink.itemsub[k] = v
end

Heatsink.schoolspell = Heatsink.schoolspell or {}
Heatsink.lockout = Heatsink.lockout or {}
for k,v in pairs(schoolspell) do
	Heatsink.schoolspell[k] = v
	for i in pairs(v) do
		Heatsink.lockout[i] = false
	end
end
  
Heatsink.school = Heatsink.school or {}
for k,v in pairs(school) do
	Heatsink.school[k] = v
end

Heatsink.whitelist = Heatsink.whitelist or {}
for k,v in pairs(whitelist) do
	Heatsink.whitelist[k] = v
end

Heatsink.notooltip = Heatsink.notooltip or {}
for k,v in pairs(notooltip) do
	Heatsink.notooltip[k] = v
end


