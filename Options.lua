local AddonName, Addon = ...

local L = Addon.L;
local Logger = Addon.Logger;
local EventBus = Addon.EventBus;

local Options;

----------------------------------------
--            添加SLASH命令            --
----------------------------------------

local function addSlashCmd()
    SLASH_TRADELOGGER1 = "/tradeLogger"
    SLASH_TRADELOGGER2 = "/tl"

    SlashCmdList["TRADELOGGER"] = function()
        InterfaceOptionsFrame_OpenToCategory(Options)
    end
end

----------------------------------------
--             插件设置页面             --
----------------------------------------

local function createCheckbox(key)
    local config = TradeLoggerDB.config;
    local checkbox = CreateFrame("CheckButton", nil, Options, "InterfaceOptionsCheckButtonTemplate")

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
    title:SetPoint("TOPLEFT", 16, -16)

    local enableTradeRecord = createCheckbox("enableTradeRecord")
    local enableTradeConsoleLog = createCheckbox("enableTradeConsoleLog")
    local enableTradeWhisper = createCheckbox("enableTradeWhisper")
    local enableMailMoneyChange = createCheckbox("enableMailMoneyChange")

    local xStart = 16;
    local yStart = -48;
    local xSpace = 16;
    local ySpace = 32;

    enableTradeRecord:SetPoint("TOPLEFT", xStart, yStart)
    enableTradeConsoleLog:SetPoint("TOPLEFT", xStart + xSpace, yStart - ySpace * 1)
    enableTradeWhisper:SetPoint("TOPLEFT", xStart + xSpace, yStart - ySpace * 2)
    enableMailMoneyChange:SetPoint("TOPLEFT", xStart + xSpace, yStart - ySpace * 3)
end

----------------------------------------
--               初始化                --
----------------------------------------

-- 使用自定义的事件是为了保证Options初始化时，数据库已经更新完成
EventBus.Register("TL_DB_LOADED", function()
    initOptions()
    addSlashCmd()
end)