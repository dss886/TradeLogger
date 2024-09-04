local AddonName, Addon = ...

----------------------------------------
--            注册和处理事件           --
----------------------------------------

local EventBus = {};
local CallbackCenter = {};
function EventBus.RegisterCallback(eventName, callback)
    if callback ~= nil and type(callback) == "function" then
        CallbackCenter[eventName] = CallbackCenter[eventName] or {};
        local callbacks = CallbackCenter[eventName];
        for index = 1, #callbacks do
            if callbacks[index] == callback then
                return;
            end
        end
        callbacks[#callbacks + 1] = callback;
    end
end

function EventBus.UnregisterCallback(event, callback)
    local callbacks = CallbackCenter[event];
    if callbacks ~= nil and callback ~= nil and type(callback) == "function" then
        for index = #callbacks, 1, -1 do
            if callbacks[index] == callback then
                tremove(callbacks, index);
            end
        end
    end
end

function EventBus.TriggerCallback(event, ...)
    local callbacks = CallbackCenter[event];
    if callbacks ~= nil then
        for index = #callbacks, 1, -1 do
            callbacks[index](...);
        end
    end
end

local EventFrame = CreateFrame("Frame", AddonName .. "EventFrame")
EventFrame:Hide()
EventFrame:SetScript("OnEvent", function(self, event, ...)
    EventBus.TriggerCallback(event, ...);
end)

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("MAIL_SHOW")
EventFrame:RegisterEvent("MAIL_CLOSED")
EventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
EventFrame:RegisterEvent("TRADE_SHOW")
EventFrame:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
EventFrame:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
EventFrame:RegisterEvent("TRADE_MONEY_CHANGED")
EventFrame:RegisterEvent("TRADE_ACCEPT_UPDATE")

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

EventBus.RegisterCallback("ADDON_LOADED", function(name)
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

----------------------------------------
--        对其他模块暴露的接口         --
----------------------------------------

Addon.EventBus = EventBus;