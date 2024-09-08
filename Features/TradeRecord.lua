local _, Addon = ...
local L = Addon.L
local Logger = Addon.Logger
local EventBus = Addon.EventBus

local CurrentTrade
local tinsert = table.insert

local function CreateNewTrade()
    return {
        timestamp = 0,
        playerName = UnitName("player"),
        playerRealm = GetRealmName(),
        targetName = UnitName("npc"),
        targetRealm = (select(2, UnitName("npc")) or GetRealmName()),
        giveItems = {},
        receiveItems = {},
        giveMoney = 0,
        receiveMoney = 0,
        location = GetRealZoneText(),
        type = 0,
        extra = {
            events = {},
            status = nil,
            message = nil,
        },
    }
end

----------------------------------------
--             交易流程事件            --
----------------------------------------

local function OnTradeShow()
    if not TradeLoggerDB.config.enableTradeRecord then
		return
	end
	CurrentTrade = CreateNewTrade()
    tinsert(CurrentTrade.extra.events, "TRADE_SHOW")
end

local function OnTradeClosed()
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    if not CurrentTrade then
        return
    end
    tinsert(CurrentTrade.extra.events, "TRADE_CLOSED")
end

local function OnTradeCancel()
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    tinsert(CurrentTrade.extra.events, "TRADE_REQUEST_CANCEL")
end

----------------------------------------
--             交易数据事件            --
----------------------------------------

local function OnTradePlayerItemChanged(slotIndex)
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    local itemName, _, quantity, _, enchantment = GetTradePlayerItemInfo(slotIndex)
    if not itemName then
        CurrentTrade.giveItems[slotIndex] = nil
        return
    end
    local itemLink = GetTradePlayerItemLink(slotIndex)
    CurrentTrade.giveItems[slotIndex] = {
		["name"] = itemName,
		["count"] = quantity,
		["enchantment"] = enchantment,
		["itemLink"] = itemLink,
	}
end

local function OnTradeTargetItemChanged(slotIndex)
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    local itemName, _, quantity = GetTradeTargetItemInfo(slotIndex)
    if not itemName then
        CurrentTrade.receiveItems[slotIndex] = nil
        return
    end
    local itemLink = GetTradeTargetItemLink(slotIndex)
    CurrentTrade.receiveItems[slotIndex] = {
        ["name"] = itemName,
        ["count"] = quantity,
        ["itemLink"] = itemLink,
    }
end

local function OnTradeMoneyChanged()
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
	CurrentTrade.giveMoney = GetPlayerTradeMoney()
	CurrentTrade.receiveMoney = GetTargetTradeMoney()
end

local function OnTradeAcceptUpdate(playerAccepted, targetAccepted)
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    for i = 1, 7 do
        OnTradePlayerItemChanged(i)
        OnTradeTargetItemChanged(i)
    end
    OnTradeMoneyChanged()
end

----------------------------------------
--            处理交易结果             --
----------------------------------------

-- 离谱的事件调用顺序！
-- 主动取消交易：SHOW -> CLOSED -> CANCEL
-- 自己距离太远：SHOW -> CLOSED -> CLOSED -> CANCEL
-- 对方取消/距离太远：SHOW -> CANCEL -> CLOSED -> CLOSED
local function AnalyseCancelReason()
    local reason = "unknown"
    local e = CurrentTrade.extra.events
    local n = #e
    if n >= 3 and e[n]=="TRADE_REQUEST_CANCEL" and e[n-1]=="TRADE_CLOSED" and e[n-2]=="TRADE_SHOW" then
        reason = "self"
    elseif n >= 3 and e[n]=="TRADE_REQUEST_CANCEL" and e[n-1]=="TRADE_CLOSED" and e[n-2]=="TRADE_CLOSED" then
        reason = "self_too_far"
    elseif n >= 3 and e[n]=="TRADE_CLOSED" and e[n-1]=="TRADE_CLOSED" and e[n-2]=="TRADE_REQUEST_CANCEL" then
        -- TODO 没办法区分对方取消和对方超出距离？
        reason = "target"
    end
    return reason
end

local function HandleTradeResult()
    if CurrentTrade.extra.status == "error" then
        Logger.Debug(format(L["trade_record_error"], CurrentTrade.targetName, CurrentTrade.extra.message))
        CurrentTrade = nil
        return
    end
    if CurrentTrade.extra.status == "cancel" then
        local reason = L["trade_record_cancel_reason_"..AnalyseCancelReason()]
        Logger.Debug(format(L["trade_record_cancel"], CurrentTrade.targetName, reason))
        CurrentTrade = nil
        return
    end
    CurrentTrade.timestamp = time()
    CurrentTrade.extra = nil
    tinsert(TradeLoggerDB.tradeRecord, CurrentTrade)
    Logger.Debug(format(L["trade_record_save"], CurrentTrade.targetName))
    EventBus:Post("TL_TRADE_RECORD_ADDED")
    CurrentTrade = nil
end

----------------------------------------
--             交易结束事件            --
----------------------------------------

local function OnUiErrorMessage(_, msg)
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    if msg == ERR_TRADE_BAG_FULL or msg == ERR_TRADE_MAX_COUNT_EXCEEDED 
        or msg == ERR_TRADE_TARGET_BAG_FULL or msg == ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED then
        CurrentTrade.extra.status = "error"
        CurrentTrade.extra.message = msg
        HandleTradeResult()
    end
end

local function OnUiInfoMessage(_, msg)
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    if msg == ERR_TRADE_CANCELLED then
        CurrentTrade.extra.status = "cancel"
        CurrentTrade.extra.message = msg
        HandleTradeResult()
    elseif msg == ERR_TRADE_COMPLETE then
        CurrentTrade.extra.status = "complete"
        CurrentTrade.extra.message = msg
        HandleTradeResult()
    end
end

----------------------------------------
--              注册事件              --
----------------------------------------

EventBus.Register("TRADE_SHOW", OnTradeShow);
EventBus.Register("TRADE_CLOSED", OnTradeClosed);
EventBus.Register("TRADE_REQUEST_CANCEL", OnTradeCancel);
EventBus.Register("TRADE_PLAYER_ITEM_CHANGED", OnTradePlayerItemChanged);
EventBus.Register("TRADE_TARGET_ITEM_CHANGED", OnTradeTargetItemChanged);
EventBus.Register("TRADE_MONEY_CHANGED", OnTradeMoneyChanged);
EventBus.Register("TRADE_ACCEPT_UPDATE", OnTradeAcceptUpdate);
EventBus.Register("UI_ERROR_MESSAGE", OnUiErrorMessage);
EventBus.Register("UI_INFO_MESSAGE", OnUiInfoMessage);