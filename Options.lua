--[[--------------------------------------------------------------------
	Trade Chat Cleaner
	Removes spam and irrelevant chatter from Trade chat.
	Copyright (c) 2013-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info23178-TradeChatCleaner.html
	http://www.curse.com/addons/wow/tradechatcleaner
	https://github.com/Phanx/TradeChatCleaner
----------------------------------------------------------------------]]

local NAME, L = ...

local Options = CreateFrame("Frame", NAME.."Options", InterfaceOptionsFramePanelContainer)
Options.name = NAME
InterfaceOptions_AddCategory(Options)

local Title = Options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
Title:SetPoint("TOPLEFT", 16, -16)
Title:SetText(NAME)
Options.Title = Title

local SubText = Options:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
SubText:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8)
SubText:SetPoint("RIGHT", -16, 0)
SubText:SetHeight(64)
SubText:SetJustifyH("LEFT")
SubText:SetJustifyV("TOP")
SubText:SetText(L.Description)
Options.SubText = SubText

local function MakeMultiLineEditBox(name)
	local label = Options:CreateFontString("$parent"..name.."Label", "ARTWORK", "GameFontNormal")
	label:SetJustifyH("LEFT")

	local bg = CreateFrame("Frame", nil, Options)
	bg:SetBackdrop({
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
		insets = { left = 4, right = 3, top = 4, bottom = 3 }
	})
	bg:SetBackdropColor(0, 0, 0)
	bg:SetBackdropBorderColor(0.4, 0.4, 0.4)

	local scroll = CreateFrame("ScrollFrame", "$parent"..name.."Scroll", bg, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 8, -6)
	scroll:SetPoint("BOTTOMRIGHT", -4, 6)

	local bar = _G[scroll:GetName().."ScrollBar"]
	bar:ClearAllPoints()
	bar:SetPoint("TOPRIGHT", -1, -15)
	bar:SetPoint("BOTTOMRIGHT", -1, 15)

	local edit = CreateFrame("EditBox", "$parent"..name, Options)
	edit:SetPoint("BOTTOMLEFT", scroll)
	edit:SetPoint("TOPRIGHT", scroll, -bar:GetWidth(), 0)
	edit:EnableMouse(true)
	edit:SetAutoFocus(false)
	edit:SetFontObject(ChatFontNormal)
	edit:SetMaxLetters(10000)
	edit:SetMultiLine(true)
	edit:SetScript("OnTabPressed", edit.ClearFocus)
	edit:SetScript("OnEscapePressed", edit.ClearFocus)
	edit:SetScript("OnCursorChanged", function(this, x, y, _, cursorHeight)
		y = -y
		local offset = scroll:GetVerticalScroll()
		if y < offset then
			scroll:SetVerticalScroll(y)
		else
			y = y + cursorHeight - scroll:GetHeight()
			if y > offset then
				scroll:SetVerticalScroll(y)
			end
		end
	end)

	scroll:SetScrollChild(edit)
	edit:SetFrameLevel(scroll:GetFrameLevel() + 1)

	scroll:HookScript("OnSizeChanged", function(this, width, height)
		edit:SetWidth(width - bar:GetWidth())
	end)
	scroll:HookScript("OnVerticalScroll", function(this, offset)
		edit:SetHitRectInsets(0, 0, offset, edit:GetHeight() - offset - this:GetHeight())
	end)

	local accept = CreateFrame("Button", "$parent"..name.."Accept", Options, "UIPanelButtonTemplate")
	accept:SetPoint("TOP", bg, "BOTTOM", 0, -4)
	accept:SetSize(120, 20)
	accept:SetText(ACCEPT)

	edit.bg = bg
	edit.label = label
	edit.scrollBar = bar
	edit.scrollFrame = scroll
	edit.acceptButton = accept

	return edit
end

local function FillListFromText(list, text)
	wipe(list)

	text = gsub(text .. "\n", "([^%%|]%u)", strlower)
	for line in gmatch(text, "[^\n]+") do
		line = strtrim(line)
		if strlen(line) > 0 then
			tinsert(list, line)
		end
	end
	table.sort(list)

	local i = 2
	while i <= #list do
		if list[i] == list[i-1] then
			tremove(list, i)
		else
			i = i + 1
		end
	end
end

local Blacklist = MakeMultiLineEditBox("Blacklist")
Options.Blacklist = Blacklist

Blacklist.label:SetPoint("TOPLEFT", SubText, "BOTTOMLEFT", 0, -16)
Blacklist.label:SetPoint("TOPRIGHT", SubText, "BOTTOM", -8, -16)
Blacklist.label:SetText(L.Blacklist)

Blacklist.bg:SetPoint("TOPLEFT", Blacklist.label, "BOTTOMLEFT", -4, 0)
Blacklist.bg:SetPoint("TOPRIGHT", Blacklist.label, "BOTTOMRIGHT", 4, 0)
Blacklist.bg:SetPoint("BOTTOMLEFT", Options, 16, 16 + 4 + 20)

local Whitelist = MakeMultiLineEditBox("Whitelist")
Options.Whitelist = Whitelist

Whitelist.label:SetPoint("TOPLEFT", SubText, "BOTTOM", 8, -16)
Whitelist.label:SetPoint("TOPRIGHT", SubText, "BOTTOMRIGHT", 0, -16)
Whitelist.label:SetText(L.Whitelist)

Whitelist.bg:SetPoint("TOPLEFT", Whitelist.label, "BOTTOMLEFT", -4, 0)
Whitelist.bg:SetPoint("TOPRIGHT", Whitelist.label, "BOTTOMRIGHT", 4, 0)
Whitelist.bg:SetPoint("BOTTOMRIGHT", Options, -16, 16 + 4 + 20)

local function RefreshEditBoxFromList(editBoxName, listName)
	editBoxName:SetCursorPosition(0)
	editBoxName:ClearFocus()
	editBoxName:SetText(table.concat(listName, "\n"))
	
	local _, lineHeight = editBoxName:GetFontObject():GetFont()
 	editBoxName:SetHeight(lineHeight * #listName)
	editBoxName.scrollFrame:SetVerticalScroll(0)
end

local function RefreshBlacklist()
	RefreshEditBoxFromList(Blacklist, ChatCleanerBlacklist)
end

local function RefreshWhitelist()
	RefreshEditBoxFromList(Whitelist, ChatCleanerWhitelist)
end

Blacklist.acceptButton:SetScript("OnClick", function(this)
	FillListFromText(ChatCleanerBlacklist, Blacklist:GetText())
	RefreshBlacklist()
end)

Whitelist.acceptButton:SetScript("OnClick", function(this)
	FillListFromText(ChatCleanerWhitelist, Whitelist:GetText())
	RefreshWhitelist()
end)

function Options:refresh()
	table.sort(ChatCleanerBlacklist)
	RefreshBlacklist()

	table.sort(ChatCleanerWhitelist)
	RefreshWhitelist()
end

Options:SetScript("OnShow", Options.refresh)

SLASH_TRADECHATCLEANER1 = "/tcc"
SlashCmdList.TRADECHATCLEANER = function()
	InterfaceOptionsFrame_OpenToCategory(Options)
	InterfaceOptionsFrame_OpenToCategory(Options)
end
