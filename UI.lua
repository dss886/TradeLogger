local AddonName, Addon = ...

local L = Addon.L;
local Logger = Addon.Logger;
local Options = Addon.Options;
local EventBus = Addon.EventBus;

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
            tooltip:AddDoubleLine(L["ldb_tooltip_recent_trade_title"], L["ldb_tooltip_recent_trade_none"])
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