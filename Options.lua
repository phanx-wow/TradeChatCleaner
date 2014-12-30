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

Options:Hide()
Options:SetScript("OnShow", function()

local Title = Options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
Title:SetPoint("TOPLEFT", 16, -16)
Title:SetText(NAME)
Options.Title = Title

local SubText = Options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
SubText:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8)
SubText:SetPoint("RIGHT", -16, 0)
SubText:SetHeight(40) -- TODO: check height with translations
SubText:SetJustifyH("LEFT")
SubText:SetJustifyV("TOP")
--SubText:SetWordWrap(true)
--SubText:SetIndentedWordWrap(false)
SubText:SetText(L.Description)
Options.SubText = SubText

local function MakeMultiLineEditBox(name)
	local bg = CreateFrame("Frame", nil, Options)
	bg:SetBackdrop({
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
		insets = { left = 4, right = 3, top = 4, bottom = 3 }
	})
	bg:SetBackdropColor(0, 0, 0)
	bg:SetBackdropBorderColor(0.4, 0.4, 0.4)

	local label = bg:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", 4, 0)
	label:SetPoint("BOTTOMRIGHT", bg, "TOPRIGHT", -4, 0)
	label:SetJustifyH("LEFT")

	local scroll = CreateFrame("ScrollFrame", "$parent"..name.."Scroll", bg, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 9, -10) -- 8, -6)
	scroll:SetPoint("BOTTOMRIGHT", -4, 8) -- -4, 6)

	local bar = _G[scroll:GetName().."ScrollBar"]
	bar:ClearAllPoints()
	bar:SetPoint("TOPRIGHT", -1, -12)
	bar:SetPoint("BOTTOMRIGHT", -1, 15)

	local edit = CreateFrame("EditBox", "$parent"..name, bg)
	edit:SetPoint("BOTTOMLEFT", scroll)
	edit:SetPoint("TOPRIGHT", scroll, -bar:GetWidth(), 0)
	edit:EnableMouse(true)
	edit:SetAutoFocus(false)
	edit:SetFontObject(ChatFontNormal)
	edit:SetMaxLetters(10000)
	edit:SetMultiLine(true)
	edit:SetScript("OnTabPressed", edit.ClearFocus)
	edit:SetScript("OnEscapePressed", edit.ClearFocus)
	edit:SetScript("OnCursorChanged", function(self, x, y, _, cursorHeight)
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

	local focus = CreateFrame("Button", nil, scroll)
	focus:SetPoint("BOTTOMLEFT", -2, -1)
	focus:SetPoint("TOPRIGHT", 1 - bar:GetWidth(), 1)
	--focus:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
	--focus:SetBackdropColor(1, 1, 1, 0.25)
	focus:SetScript("OnClick", function(self)
		edit:SetFocus()
	end)
	edit:SetScript("OnEditFocusGained", function(self)
		focus:Hide()
	end)
	edit:SetScript("OnEditFocusLost", function(self)
		focus:Show() -- focus:SetShown(self:GetHeight() < scroll:GetHeight())
	end)

	local accept = CreateFrame("Button", "$parent"..name.."Button", scroll, "UIPanelButtonTemplate")
	accept:SetPoint("TOP", bg, "BOTTOM", 0, -1)
	accept:SetSize(180, 20)
	accept:SetText(ACCEPT)

	scroll:SetScrollChild(edit)
	edit:SetFrameLevel(scroll:GetFrameLevel() + 1)
	scroll:HookScript("OnSizeChanged", function(self, width, height)
		edit:SetWidth(width - bar:GetWidth())
	end)
	scroll:HookScript("OnVerticalScroll", function(self, offset)
		edit:SetHitRectInsets(0, 0, offset, edit:GetHeight() - offset - self:GetHeight())
	end)

	function edit:SetPoint(point, relativeTo, relativePoint, x, y)
		print("SetPoint", tostringall(point, relativeTo, relativePoint, x, y))
		if relativeTo == nil or type(relativeTo) == "number" then
			-- "TOPLEFT", x, y
			point, relativeTo, relativePoint, x, y = point, Options, point, relativeTo, relativePoint
		elseif relativePoint == nil or type(relativePoint) == "number" then
			-- "TOPLEFT", someFrame, x, y
			point, relativeTo, relativePoint, x, y = point, relativeTo, point, relativePoint, x
		end
		if strmatch(point, "LEFT") then
			x = (x or 0) - 4
		elseif strmatch(point, "RIGHT") then
			x = (x or 0) + 4
		end
		if strmatch(point, "TOP") then
			y = (y or 0) - label:GetStringHeight()
		elseif strmatch(point, "BOTTOM") then
			y = (y or 0) + 1 + accept:GetHeight()
		end
		print("      =>", tostringall(point, relativeTo, relativePoint, x, y))
		bg:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
	end

	edit.bg = bg
	edit.label = label
	edit.scrollBar = bar
	edit.scrollFrame = scroll
	edit.acceptButton = accept
	edit.focusClicker = focus

	return edit
end

local function FillEditBoxFromList(editBox, list)
	editBox:SetCursorPosition(0)
	editBox:ClearFocus()
	editBox:SetText(table.concat(list, "\n"))
	editBox.scrollFrame:SetVerticalScroll(0)
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
Blacklist:SetPoint("TOPLEFT", SubText, "BOTTOMLEFT", 0, -16)
Blacklist:SetPoint("TOPRIGHT", SubText, "BOTTOM", -8, -16)
Blacklist:SetPoint("BOTTOMLEFT", 16, 16)
Blacklist.label:SetText(L.Blacklist)
Options.Blacklist = Blacklist

local Whitelist = MakeMultiLineEditBox("Whitelist")
Whitelist:SetPoint("TOPLEFT", SubText, "BOTTOM", 8, -16)
Whitelist:SetPoint("TOPRIGHT", SubText, "BOTTOMRIGHT", 0, -16)
Whitelist:SetPoint("BOTTOMRIGHT", -16, 16)
Whitelist.label:SetText(L.Whitelist)
Options.Whitelist = Whitelist

local CheckboxWhitelistChannels = CreateFrame("CheckButton", "$parentCheckboxWhitelistChannels", Options, "ChatConfigCheckButtonTemplate")
CheckboxWhitelistChannels:SetScript("OnClick", function(this)
	WhitelistAllNumberedChannels = CheckboxWhitelistChannels:GetChecked()
end)
_G[CheckboxWhitelistChannels:GetName().."Text"]:SetText(L.CheckboxWhitelistChannelsLabel)
CheckboxWhitelistChannels.tooltip = L.CheckboxWhitelistChannelsTooltip
CheckboxWhitelistChannels:SetPoint("TOPLEFT", 316, -62)

Blacklist.acceptButton:SetScript("OnClick", function(this)
	FillListFromText(ChatCleanerBlacklist, Blacklist:GetText())
	Options:refresh()
end)

Whitelist.acceptButton:SetScript("OnClick", function(self)
	FillListFromText(ChatCleanerWhitelist, Whitelist:GetText())
	Options:refresh()
end)

function Options:refresh()
	table.sort(ChatCleanerBlacklist)
	FillEditBoxFromList(Blacklist, ChatCleanerBlacklist)

	table.sort(ChatCleanerWhitelist)
	FillEditBoxFromList(Whitelist, ChatCleanerWhitelist)
	
	CheckboxWhitelistChannels:SetChecked(WhitelistAllNumberedChannels)
end

Options:refresh()
Options:SetScript("OnShow", Options.refresh)

end) -- one-time OnShow

SLASH_TRADECHATCLEANER1 = "/tcc"
SlashCmdList.TRADECHATCLEANER = function()
	InterfaceOptionsFrame_OpenToCategory(Options)
end
