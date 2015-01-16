--[[--------------------------------------------------------------------
	Trade Chat Cleaner
	Removes spam and irrelevant chatter from Trade chat.
	Copyright (c) 2013-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info23178-TradeChatCleaner.html
	http://www.curse.com/addons/wow/tradechatcleaner
	https://github.com/Phanx/TradeChatCleaner
----------------------------------------------------------------------]]

local _, L = ...

ChatCleanerWhitelist = {
	"|h", -- links
	"%f[%a]rukh", -- rukh, rukhan
	"blingtron",
	"dps",
	"drov",
	"ffa",
	"flex",
	"free ?roll",
	"he[ai]l",
	"heroic",
	"%f[%a]lf[gmw%d]?%f[%A]", -- lfg, lfm, lfw, lf5, lf ___
	"kaufe", -- de
	"mog run",
	"mythic",
	"reserve",
	"s[cz]ena?r?i?o?", -- en/de
	"style ?ru[ns]h?", -- en/de
	"tar[il]na", -- tarlna, but people are dumb and also write tarina
	"transmog",
	"%f[%a]vk%f[%A]", -- de
	"tank",
	"trash farm",
	"weltboss",
	"world ?boss",
	"^wt[bst]", -- wtb, wts, wtt
}

ChatCleanerBlacklist = {
	-- real spam
	"%.c0m%f[%A]",
	"%S+#%d+", -- BattleTag
	"%d/%d cm gold",
	"%d%s?eur%f[%A]",
	"%d%s?usd%f[%A]",
	"account",
	"boost",
	"cs[:;]go%f[%A]", -- seems to be the new hype
	"delivery",
	"diablo",
	"elite gear",
	"game ?time",
	"g0ld",
	"name change",
	"paypal",
	"professional",
	"qq", -- Chinese IM network, also catches junk as a bonus!
	"ranking",
	"realm",
	"self ?play",
	"server",
	"share",
	"s%A*k%A*y%A*p%Ae", -- spammers love to obfuscate "skype"
	"transfer",
	"wow gold",
	-- pvp
	"[235]v[235]",
	"%f[%a]arena", -- arenacap, arenamate, arenapoints
	"%f[%a]cap%f[%A]",
	"%f[%a]carry%f[%A]",
	"%f[%a]cr%f[%A]",
	"%f[%d][235]s%f[%A]", -- 2s, 3s, 5s
	"conqu?e?s?t? cap",
	"conqu?e?s?t? points",
	"for %ds",
	"lf %ds",
	"low mmr",
	"partner",
	"points cap",
	"punktecap", -- DE
	"pvp ?mate",
	"rating",
	"rbg",
	"season",
	"weekly cap",
	-- junk
	"%[dirge%]",
	"%f[%a]ebay",
	"a?m[eu]rican?", -- america, american, murica
	"an[au][ls]e?r?%f[%L]", -- anal, anus, -e/er/es/en
	"argument",
	"aussie",
	"australi",
	"bacon",
	"bewbs",
	"bitch",
	"boobs",
	"christian",
	"chuck ?norris",
	"girl",
	"kiss",
	"mad ?bro",
	"mudda",
	"muslim",
	"nigg[ae]r?",
	"obama",
	"pussy",
	"sexy",
	"shut ?up",
	"tits",
	"twitch%.tv",
	"webcam",
	"wts.+guild",
	"xbox",
	"youtu%.?be",
	"y?o?ur? m[ao]mm?a",
	"y?o?ur? m[ou]th[ae]r",
	"youtube",
	-- TCG codes
	"hippogryph hatchling",
	"mottled drake",
	"rocket chicken",
}

local TRADE = L.Trade
local reqLatin = not strmatch(GetLocale(), "^[rkz][uoh]")

local strmatch, strlower, type = string.match, string.lower, type

local prevID, result
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_, _, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, senderGUID, ...)
	if lineID == prevID then
		if result == true then
			return true
		else
			return false, result, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, senderGUID, ...
		end
	end
	prevID, result = lineID, true

	-- Don't filter custom channels
	if channelID == 0 or type(channelID) ~= "number" then return end

	local search = strlower(message)

	-- Hide ASCII art crap
	if reqLatin and not strmatch(search, "[a-z]") then
		--print("No letters")
		return true
	end

	local blacklist = ChatCleanerBlacklist
	for i = 1, #blacklist do
		if strmatch(search, blacklist[i]) then
			--print("Blacklisted:", blacklist[i])
			--print("  ", search)
			return true
		end
	end

	-- Remove extra spaces
	message = strtrim(gsub(message, "%s%s+", " "))

	local whitelist = ChatCleanerWhitelist
	local pass = #whitelist == 0 or not strmatch(channelName, TRADE)
	if not pass then
		for i = 1, #whitelist do
			if strmatch(search, whitelist[i]) then
				--print("Whitelisted:", whitelist[i])
				pass = true
				break
			end
		end
	end
	if pass then
		--print("Passed")
		result = message
		return false, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, senderGUID, ...
	end

	--print("Other:", channelID, search)
	return true
end)
