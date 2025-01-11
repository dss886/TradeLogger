local AddonName, Addon = ...

local L = Addon.L;
local Logger = Addon.Logger;
local EventBus = Addon.EventBus;

----------------------------------------
--             一些工具函数             --
----------------------------------------

local function GetRecentTrade()
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

local function AddTradeListToToolTip(tooltip, tradeList)
    local count = math.min(#tradeList, 10)
    for i = 1, count do
        local trade = tradeList[i]
        local timeStr = date("%Y-%m-%d %H:%M:%S", trade.timestamp)
        local left = format("|cFFFFFFFF%s", timeStr)
        local right = format("|cFFFFFFFF%s", trade.targetName)
        tooltip:AddDoubleLine(left, right)
    end
end

function OnTooltipShow(tooltip)
    local recentTrade = GetRecentTrade()
    tooltip:AddDoubleLine(L["ldbTooltipRecentTradeTitle"], #recentTrade > 0
        and format(L["ldbTooltipRecentTradeCount"], #recentTrade)
        or L["ldbTooltipRecentTradeNone"])
    AddTradeListToToolTip(tooltip, recentTrade)
    tooltip:AddLine(" ")
    tooltip:AddLine(L["ldbTooltipDesc1"])
    tooltip:AddLine(L["ldbTooltipDesc2"])
end

function OnClick(self, button)
    if button == "LeftButton" then
        EventBus.Post("TL_TOGGLE_RECORD_FRAME")
    elseif button == "RightButton" then
        Settings.OpenToCategory(AddonName)
    end
end

----------------------------------------
--               LDB配置               --
----------------------------------------

local function InitLDB()
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

        plugin.OnClick = OnClick
        plugin.OnTooltipShow = OnTooltipShow
    end
end

----------------------------------------
--            小地图图标配置            --
----------------------------------------

local function InitMinimap()
    if LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true) then
        local ldi = LibStub("LibDBIcon-1.0")
        ldi:Register(AddonName,
        {
            type = "launcher",
            text = AddonName,
            icon = "Interface\\Icons\\inv_misc_coin_02",
            OnClick = OnClick,
            OnTooltipShow = OnTooltipShow,
        },{});
        ldi:Show("TalentEmu");
    end
end

----------------------------------------
--               初始化                --
----------------------------------------

EventBus.Register("ADDON_LOADED", function(name)
    if name == AddonName then
        InitLDB()
        InitMinimap()
	end
end)