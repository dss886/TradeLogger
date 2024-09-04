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

local function createCheckbox(key)
    local config = TradeLoggerDB.config;
    local checkbox = CreateFrame("CheckButton", AddonName..key, Options, "InterfaceOptionsCheckButtonTemplate")

    checkbox.Text:SetText(L[key])
    checkbox:SetChecked(config[key])
    checkbox:SetScript("OnClick", function()
        config[key] = not config[key];
    end)
    return checkbox
end


local function initOptions()
    Options = CreateFrame("FRAME");
    Options.name = AddonName;
    InterfaceOptions_AddCategory(Options)

    local title = Options:CreateFontString(AddonName.."Title", "ARTWORK", "GameFontNormal")
	title:SetText(AddonName)
    title:SetFont(STANDARD_TEXT_FONT, 18, "")

    local enableTradeRecord = createCheckbox("enableTradeRecord")
    local enableMailMoneyChange = createCheckbox("enableMailMoneyChange")

    local spaceV = 28;
    local spaceStart = -48;
    title:SetPoint("TOPLEFT", 16, -16)
    enableTradeRecord:SetPoint("TOPLEFT", 16, spaceStart)
    enableMailMoneyChange:SetPoint("TOPLEFT", 16, spaceStart - spaceV * 1)
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