local _, Addon = ...
local L = Addon.L;
local Logger = Addon.Logger;
local EventBus = Addon.EventBus;

local CurrentTrade;

local function createNewTrade()
    return {
        ["timestamp"] = 0,
        ["playerName"] = UnitName("player"),
        ["playerRealm"] = GetRealmName(),
        ["targetName"] = UnitName("npc"),
        ["targetRealm"] = (select(2, UnitName("npc")) or GetRealmName()),
        ["giveItems"] = {},
        ["receiveItems"] = {},
        ["giveMoney"] = 0,
        ["receiveMoney"] = 0,
        ["location"] = GetRealZoneText(),
        ["type"] = 0,
    }
end

local function OnTradeShow()
    Logger.Debug("OnTradeShow")
    if not TradeLoggerDB.config.enableTradeRecord then
		return
	end
	CurrentTrade = createNewTrade()
end

local function OnTradePlayerItemChanged(slotIndex)
    Logger.Debug("OnTradePlayerItemChanged", slotIndex)
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
    Logger.Debug("OnTradeTargetItemChanged", slotIndex)
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    local itemName, _, quantity, _, enchantment = GetTradeTargetItemInfo(slotIndex)
    if not itemName then
        CurrentTrade.receiveItems[slotIndex] = nil
        return
    end
    local itemLink = GetTradeTargetItemLink(slotIndex)
    CurrentTrade.receiveItems[slotIndex] = {
        ["name"] = itemName,
        ["count"] = quantity,
        ["enchantment"] = enchantment,
        ["itemLink"] = itemLink,
    }
end

local function OnTradeMoneyChanged()
    Logger.Debug("OnTradeMoneyChanged")
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
	CurrentTrade.giveMoney = GetPlayerTradeMoney()
	CurrentTrade.receiveMoney = GetTargetTradeMoney()
end

local function OnTradeAcceptUpdate()
    Logger.Debug("OnTradeAcceptUpdate")
    if not TradeLoggerDB.config.enableTradeRecord then
        return
    end
    for i = 1, 7 do
        OnTradePlayerItemChanged(i)
        OnTradeTargetItemChanged(i)
    end
    OnTradeMoneyChanged()
    CurrentTrade.timestamp = time()
    table.insert(TradeLoggerDB.tradeRecord, CurrentTrade)
    table.insert(TradeLoggerDB.tradeRecord, CurrentTrade)
    Logger.Debug(format("与 %s 的交易已记录", CurrentTrade.targetName))
    EventBus:Post("TL_TRADE_RECORD_ADDED")
    CurrentTrade = nil
end

EventBus.Register("TRADE_SHOW", OnTradeShow);
EventBus.Register("TRADE_PLAYER_ITEM_CHANGED", OnTradePlayerItemChanged);
EventBus.Register("TRADE_TARGET_ITEM_CHANGED", OnTradeTargetItemChanged);
EventBus.Register("TRADE_MONEY_CHANGED", OnTradeMoneyChanged);
EventBus.Register("TRADE_ACCEPT_UPDATE", OnTradeAcceptUpdate);