local _G = getfenv(0)
local LibStub = _G.LibStub
local Heatsink = LibStub("AceAddon-3.0"):GetAddon("Heatsink")
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Heatsink")
local AceGUIWidgetLSMlists = _G.AceGUIWidgetLSMlists

local STRING_SCHOOL_ARCANE = _G.STRING_SCHOOL_ARCANE
local STRING_SCHOOL_FIRE = _G.STRING_SCHOOL_FIRE
local STRING_SCHOOL_FROST = _G.STRING_SCHOOL_FROST
local STRING_SCHOOL_HOLY = _G.STRING_SCHOOL_HOLY
local STRING_SCHOOL_NATURE = _G.STRING_SCHOOL_NATURE
local STRING_SCHOOL_PHYSICAL = _G.STRING_SCHOOL_PHYSICAL
local STRING_SCHOOL_SHADOW = _G.STRING_SCHOOL_SHADOW
local tostring = _G.tostring
local tonumber = _G.tonumber
local unpack = _G.unpack

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
					get = function () return Heatsink.db.profile.show.items end,
					set = function (info, v)
						Heatsink.db.profile.show.items = v
						Heatsink:ScanItems()
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
						Heatsink:ScanItems()
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

function Heatsink:SetupOptions()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Heatsink", options)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Heatsink.db)
	local optFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Heatsink")
	LibStub("AceConsole-3.0"):RegisterChatCommand( "heatsink", function() InterfaceOptionsFrame_OpenToCategory("Heatsink") end )
end

