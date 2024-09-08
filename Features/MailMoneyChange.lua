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

-- 从某个版本后邮箱关闭时不再触发MAIL_CLOSED事件，
-- 需要兼容一下PLAYER_INTERACTION_MANAGER_FRAME_HIDE事件
-- type=17 是 mailbox
local function OnPlayerFrameHide(type)
    if type == 17 then
        OnMailClosed()
    end
end

EventBus.Register("MAIL_SHOW", OnMailShow);
EventBus.Register("MAIL_CLOSED", OnMailClosed);
EventBus.Register("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", OnPlayerFrameHide);
