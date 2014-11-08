--[[--------------------------------------------------------------------
	Trade Chat Cleaner
	Removes spam and irrelevant chatter from Trade chat.
	Copyright (c) 2013-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info23178-TradeChatCleaner.html
	http://www.curse.com/addons/wow/tradechatcleaner

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to use any/all of its code
	in your own addon, as long as you do not use my name or the name of
	this addon ANYWHERE in your addon, including in its name, outside of
	an optional attribution. You are also welcome to include this addon
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
----------------------------------------------------------------------]]

local _, L = ...

ChatCleanerWhitelist = {
	"|h", -- links
	"^wt[bst]",
	"^lf[gm%d%s]",
	"dps",
	"ffa",
	"flex",
	"free ?roll",
	"kaufe", -- de
	"gall?e?o?n?",
	"he[ai]l",
	"heroic",
	"mog run",
	"nala?k?",
	"oond?a?s?t?a?",
	"reserve",
	"s[cz]ena?r?i?o?", -- en/de
	"transmog",
	"%f[%a]vk%f[%A]", -- de
	"%f[%a]sha%f[%A]",
	"tank",
}

ChatCleanerBlacklist = {
	-- real spam
	"%.c0m%f[%L]",
	"%d%s?eur%f[%L]",
	"%d%s?usd%f[%L]",
	"account",
	"boost",
	"diablo",
	"elite gear",
	"game ?time",
	"g0ld",
	"name change",
	"paypal",
	"qq",
	"ranking",
	"realm",
	"server",
	"share",
	"s%A*k%A*y%A*p%Ae", -- spammers love to obfuscate "skype"
	"transfer",
	"wow gold",
	-- pvp
	"%f[%d][235]s%f[%L]", -- 2s, 3s, 5s
	"[235]v[235]",
	"%f[%a]arena", -- arenacap, arenamate, arenapoints
	"%f[%l]carry%f[%L]",
	"conqu?e?s?t? cap",
	"conqu?e?s?t? points",
	"for %ds",
	"lf %ds",
	"low mmr",
	"points cap",
	"punktecap", -- DE
	"pusc?h", -- DE
	"rbg",
	"season",
	"weekly cap",
	-- junk
	"a?m[eu]rican?", -- america, american, murica
	"an[au][ls]e?r?%f[%L]", -- anal, anus, -e/er/es/en
	"argument",
	-- "aus[st]?[ir]?[ea]?l?i?a?n?%f[%L]", -- aus, aussie, australia, australian -- "aus" is problematic in DE
	"bacon",
	"bewbs",
	"boobs",
	"chuck ?norris",
	"girl",
	"kiss",
	"mad ?bro",
	"nigg[ae]r?",
	"obama",
	"pussy",
	"sexy?",
	"shut ?up",
	"tits",
	"twitch%.tv",
	"webcam",
	"wts.+guild",
	"xbox",
	"youtu%.?be",
}

local TRADE = L.Trade
local reqLatin = not strmatch(GetLocale(), "^[rkz][uoh]")

local strfind, strlower, type = string.find, string.lower, type

local prevID, result
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_, _, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, ...)
	if lineID == prevID then
		return result
	end
	prevID, result = lineID, nil

	-- Don't filter custom channels
	if channelID == 0 or type(channelID) ~= "number" then return end

	local search = strlower(message)

	-- Hide ASCII crap.
	if reqLatin and not strfind(search, "[a-z]") then
		-- print("No letters.")
		result = true
		return true
	end

	local blacklist = ChatCleanerBlacklist
	for i = 1, #blacklist do
		if strfind(search, blacklist[i]) then
			-- print("Blacklisted.")
			result = true
			return true
		end
	end

	-- Apply only the blacklist to non-Trade channels
	if not strfind(channelName, TRADE) then
		return
	end

	local whitelist = ChatCleanerWhitelist
	for i = 1, #whitelist do
		if strfind(search, whitelist[i]) then
			-- print("Whitelisted:", whitelist[i])
			-- Remove extra spaces
			message = strtrim(gsub(message, "%s%s+", " "))
			return false, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, ...
		end
	end

	-- print("Other.")
	result = true
	return true
end)
