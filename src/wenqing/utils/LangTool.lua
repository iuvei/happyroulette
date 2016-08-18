local LangTool = {}
local lang = require("lang_en")

function LangTool.getText(majorKey, secondKey, ...)
    if lang[majorKey] and lang[majorKey][secondKey] then
		if type(lang[majorKey][secondKey]) == "string" then
			return LangTool.formatText(lang[majorKey][secondKey], ...)
		else
			return lang[majorKey][secondKey]
		end
	else
		return ""
	end
end

function LangTool.formatText(text, ...)
	local count = select("#", ...)
    if count >= 1 then
        for i = 1, count do
			local value = select(i, ...)
            text = string.gsub(text, "{" .. i .. "}", value)
		end
	end
    return text
end

return LangTool
