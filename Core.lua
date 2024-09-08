local AddonName, Addon = ...

local EventBus = Addon.EventBus;

----------------------------------------
--             初始化配置             --
----------------------------------------

local DEFAULT_CONFIG = {
    ["enableTradeRecord"] = true,
    ["enableMailMoneyChange"] = true,
}

local DEFAULT_DB = {
    ["version"] = 1,
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
end)