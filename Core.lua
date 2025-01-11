local AddonName, Addon = ...

local L = Addon.L;
local EventBus = Addon.EventBus;
local Logger = Addon.Logger;

----------------------------------------
--             挂载全局对象             --
----------------------------------------

TradeLogger = {}
TradeLogger.EventBus = EventBus;

----------------------------------------
--             游戏按键绑定             --
----------------------------------------

BINDING_HEADER_TRADELOGGER = "TradeLogger";
BINDING_NAME_TRADELOGGER_TOGGLE = L["bindingNameToggle"];

----------------------------------------
--              初始化配置              --
----------------------------------------

local DEFAULT_CONFIG = {
    ["enableTradeRecord"] = true,
    ["enableTradeConsoleLog"] = true,
    ["enableMailMoneyChange"] = true,
}

local DEFAULT_DB = {
    ["version"] = 3,
    ["config"] = DEFAULT_CONFIG,
    ["tradeRecord"] = {},
}

EventBus.Register("ADDON_LOADED", function(name)
    if name ~= AddonName then
		return
	end
    
    if not TradeLoggerDB or TradeLoggerDB.version == nil then
        TradeLoggerDB = DEFAULT_DB;
    end

    -- 如果数据库版本低于默认版本，要使用默认配置覆盖旧配置
    if TradeLoggerDB.version < DEFAULT_DB.version or TradeLoggerDB.config == nil then
        TradeLoggerDB.config = DEFAULT_CONFIG;
    end
    
    if TradeLoggerDB.tradeRecord == nil then
        TradeLoggerDB.tradeRecord = {};
    end
    EventBus.Post("TL_DB_LOADED")
end)