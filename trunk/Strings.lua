local _, L = ...

L.Trade = "Trade"
L.Blacklist = "Blacklisted Words"
L.Whitelist = "Whitelisted Words"
L.Description = "Messages in Trade chat are blocked, unless they contain at least one whitelisted word *and* do not contain any blacklisted words.\n\nThe blacklist (but not the whitelist) is also applied to General chat."

local LOC = GetLocale()
if LOC == "deDE" then

	L.Trade = "Handel"
	L.Blacklist = "Verbotene Wörter"
	L.Whitelist = "Zulässige Wörter"
	L.Description = "Die Meldungen im Handeln-Channel werden nur angezeigt, wenn sie mindestens eins zulässiges Wort enthalten *und* keine verbotenen Worte enthalten.\n\nDie Liste der verbotenen Wörter (aber nicht die zulässigen) ist auch mit dem Allgemein-Channel angewendet."

elseif LOC == "esES" or LOC == "esMX" then

	L.Trade = "Comercio"
	L.Blacklist = "Palabras prohibidas"
	L.Whitelist = "Palabras permitidas"
	L.Description = "Los mensajes en el canal Comercio se muestran solamente si contienen al menos una palabra permitida *y* también no contienen ningún palabras prohibidas.\n\nLa lista de palabras prohibidas (pero no las permitidas) se aplica también al canal General."

elseif LOC == "frFR" then

	L.Trade = "Commerce"

elseif LOC == "itIT" then

	L.Trade = "Commercio"

elseif LOC == "ptBR" then

	L.Trade = "Comércio"

elseif LOC == "ruRU" then

	L.Trade = "Торговля"

elseif LOC == "koKR" then

	L.Trade = "거래"

elseif LOC == "zhCN" then

	L.Trade = "交易"

elseif LOC == "zhTW" then

	L.Trade = "交易"

end
