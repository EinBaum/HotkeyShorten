local function shorten(text)
    if not text or text == "" then
        return text
    end
    text = text:gsub("Mouse Wheel Up", "MU")
    text = text:gsub("Mouse Wheel Down", "MD")
    text = text:gsub("Mouse Button ", "M")
    local prev
    repeat
        prev = text
        text = text:gsub("(%w)%-(%w)", "%1%2")
    until text == prev
    return text
end

local function updateButton(button)
    if not button then
        return
    end
    local hk = button.HotKey
    if not hk and button.GetName then
        hk = _G[button:GetName() .. "HotKey"]
    end
    if not hk then
        return
    end
    if hk.SetMaxLines then
        hk:SetMaxLines(0)
    end
    if hk.SetWordWrap then
        hk:SetWordWrap(false)
    end
    if hk.SetNonSpaceWrap then
        hk:SetNonSpaceWrap(true)
    end
    if hk.SetWidth then
        hk:SetWidth(0)
    end
    local text = hk:GetText()
    if not text or text == "" then
        return
    end
    local newText = shorten(text)
    if newText ~= text then
        hk:SetText(newText)
    end
end

local bars = {
    { "ActionButton", 12 },
    { "MultiBarBottomLeftButton", 12 },
    { "MultiBarBottomRightButton", 12 },
    { "MultiBarRightButton", 12 },
    { "MultiBarLeftButton", 12 },
    { "MultiBar5Button", 12 },
    { "MultiBar6Button", 12 },
    { "MultiBar7Button", 12 },
    { "PetActionButton", 10 },
    { "StanceButton", 10 },
    { "PossessButton", 2 },
}

local function updateAll()
    for _, info in ipairs(bars) do
        local prefix, count = info[1], info[2]
        for i = 1, count do
            updateButton(_G[prefix .. i])
        end
    end
end

local function hookMethod(object, method)
    if object and type(object[method]) == "function" then
        hooksecurefunc(object, method, updateButton)
    end
end

if type(_G.ActionButton_UpdateHotkeys) == "function" then
    hooksecurefunc("ActionButton_UpdateHotkeys", updateButton)
end
hookMethod(ActionBarActionButtonMixin, "UpdateHotkeys")
hookMethod(PetActionButtonMixin, "SetHotkeys")

local function queueUpdate()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, updateAll)
    else
        updateAll()
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_BINDINGS")
f:SetScript("OnEvent", queueUpdate)
queueUpdate()
