local AddonName, Addon = ...

local L = Addon.L;

----------------------------------------
--            添加SLASH命令           --
----------------------------------------

local function addSlashCmd(options)
    SLASH_TRADELOGGER1 = "/tradeLogger"
    SLASH_TRADELOGGER2 = "/tl"

    SlashCmdList["TRADELOGGER"] = function()
        InterfaceOptionsFrame_OpenToCategory(options)
    end
end

----------------------------------------
--             插件设置页面            --
----------------------------------------

local function init()
    local config = TradeLoggerDB;
    local options = CreateFrame("FRAME");
    options.name = L["AddonName"];
    InterfaceOptions_AddCategory(options)

    local enableMailMoneyChange = CreateFrame("CheckButton", AddonName .. "enableMailMoneyChange", options,
        "InterfaceOptionsCheckButtonTemplate")
    enableMailMoneyChange:SetPoint("TOPLEFT", 16, -16)
    enableMailMoneyChange.Text:SetText(L['enableMailMoneyChange'])
    enableMailMoneyChange:SetChecked(config.enableMailMoneyChange)
    enableMailMoneyChange:SetScript("OnClick", function()
        config.enableMailMoneyChange = not config.enableMailMoneyChange;
    end)

    addSlashCmd(options)
end

----------------------------------------
--        对其他模块暴露的接口         --
----------------------------------------

Addon.Options = {
    init = init;
};