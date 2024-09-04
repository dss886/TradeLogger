local AddonName, Addon = ...

local L = Addon.L;
local Logger = Addon.Logger;
local EventBus = Addon.EventBus;

----------------------------------------
--        一些数据操作用的工具函数      --
----------------------------------------

local function getRecentTrade()
    local tradeRecord = TradeLoggerDB.tradeRecord
    local recentTrade = {}
    local now = time()
    for i = #tradeRecord, 1, -1 do
        local trade = tradeRecord[i]
        if now - trade.timestamp <= 24 * 60 * 60 then
            table.insert(recentTrade, trade)
        else
            break
        end
    end
    return recentTrade
end

local function addTradeListToToolTip(tooltip, tradeList)
    local count = math.min(#tradeList, 10)
    for i = 1, count do
        local trade = tradeList[i]
        local timeStr = date("%Y-%m-%d %H:%M:%S", trade.timestamp)
        local left = format("|cFFFFFFFF%s", timeStr)
        local right = format("|cFFFFFFFF%s", trade.targetName)
        tooltip:AddDoubleLine(left, right)
    end
end

----------------------------------------
--          LDB配置（如果可用）        --
----------------------------------------

local function initLDB()
    if LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true) then
        local ldb = LibStub("LibDataBroker-1.1")
        local icon = "Interface\\MINIMAP\\TRACKING\\Mailbox"
        local plugin = ldb:NewDataObject("TradeLogger", {
            type 		= "data source",
            icon        = icon,
            label		= AddonName,
            text		= L["title"],
        })

        if not plugin then return end

        function plugin.OnTooltipShow(tooltip)
            local recentTrade = getRecentTrade()
            tooltip:AddDoubleLine(L["ldb_tooltip_recent_trade_title"], #recentTrade > 0 
                and format(L["ldb_tooltip_recent_trade_count"], #recentTrade) 
                or L["ldb_tooltip_recent_trade_none"])
            addTradeListToToolTip(tooltip, recentTrade)
            tooltip:AddLine(" ")
            tooltip:AddLine(L["ldb_tooltip_desc1"])
            tooltip:AddLine(L["ldb_tooltip_desc2"])
        end

        function plugin.OnClick(self, button)
            if button == "LeftButton" then
                Logger.Debug("LDB_TradeLogger:OnClickLeftButton")
            elseif button == "RightButton" then
                Settings.OpenToCategory(AddonName)
            end
        end
    end
end

----------------------------------------
--               初始化               --
----------------------------------------

EventBus.RegisterCallback("ADDON_LOADED", function(name)
    if name == AddonName then
        initLDB()
	end
end)