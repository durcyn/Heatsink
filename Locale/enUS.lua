local _G = getfenv(0)
local LibStub = _G.LibStub
local ADDON_NAME, ADDON_TABLE = ...
local debug = false
--@debug@
debug = true
--@end-debug@
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, debug)
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, handle-unlocalized="english")@
