local _, Addon = ...
local L = Addon.L;
local Logger = Addon.Logger;
local EventBus = Addon.EventBus;

local IsMailBoxOpened = false
local MailOpenMoney = 0;

local function OnMailShow()
    IsMailBoxOpened = true;
    MailOpenMoney = GetMoney();
end

local function OnMailClosed()
    local config = TradeLoggerDB.config;
    if IsMailBoxOpened and config.enableMailMoneyChange then
        local diffMoney = GetMoney() - MailOpenMoney;
        if diffMoney > 0 then
            Logger.Info(format(L["mail_money_change_incr"], GetMoneyString(diffMoney)));
        elseif diffMoney < 0 then
            Logger.Info(format(L["mail_money_change_decr"], GetMoneyString(-diffMoney)));
        end
        IsMailBoxOpened = false;
    end
end

EventBus.RegisterCallback("MAIL_SHOW", OnMailShow);
EventBus.RegisterCallback("MAIL_CLOSED", OnMailClosed);
EventBus.RegisterCallback("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function(type)
    -- type 17 is mail box
    if type == 17 then
        OnMailClosed()
    end
end);
