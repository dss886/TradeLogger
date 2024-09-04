local AddonName, Addon = ...

local L = Addon.L;
local Logger = Addon.Logger;
local EventBus = Addon.EventBus;

local Options;

----------------------------------------
--            添加SLASH命令           --
----------------------------------------

local function addSlashCmd()
    SLASH_TRADELOGGER1 = "/tradeLogger"
    SLASH_TRADELOGGER2 = "/tl"

    SlashCmdList["TRADELOGGER"] = function()
        InterfaceOptionsFrame_OpenToCategory(Options)
    end
end

----------------------------------------
--             插件设置页面            --
----------------------------------------

local function initOptions()
    local config = TradeLoggerDB.config;
    Options = CreateFrame("FRAME");
    Options.name = AddonName;
    InterfaceOptions_AddCategory(Options)

    local enableMailMoneyChange = CreateFrame("CheckButton", AddonName .. "enableMailMoneyChange", Options,
        "InterfaceOptionsCheckButtonTemplate")
    enableMailMoneyChange:SetPoint("TOPLEFT", 16, -16)
    enableMailMoneyChange.Text:SetText(L['enableMailMoneyChange'])
    enableMailMoneyChange:SetChecked(config.enableMailMoneyChange)
    enableMailMoneyChange:SetScript("OnClick", function()
        config.enableMailMoneyChange = not config.enableMailMoneyChange;
    end)
end

----------------------------------------
--               初始化               --
----------------------------------------

EventBus.RegisterCallback("ADDON_LOADED", function(name)
    if name == AddonName then
        initOptions()
        addSlashCmd()
	end
end)