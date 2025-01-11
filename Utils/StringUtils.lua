local _, Addon = ...

local L = Addon.L
local StringUtils = {};

function StringUtils.formatMoneyString(money)
    local gold = floor(money / 10000)
    local silver = floor((money % 10000) / 100)
    local copper = money % 100
    local moneyString = ""
    if gold > 0 then
        moneyString = format("%d%s", gold, L["recordReportMoneyUnitGold"])
    end
    if silver > 0 then
        moneyString = moneyString .. format("%d%s", silver, L["recordReportMoneyUnitSilver"])
    end
    if copper > 0 then
        moneyString = moneyString .. format("%d%s", copper, L["recordReportMoneyUnitCopper"])
    end
    return moneyString
end

function StringUtils.formatItemString(items)
    local getItemWithCount = function(item)
        if item.count > 1 then
            return item.itemLink .. "x" .. item.count
        else
            return item.itemLink
        end
    end
    local desc = ""
    if #items > 0 then
        for _, item in ipairs(items) do
            desc = desc .. getItemWithCount(item)
        end
    end
    return desc
end

function StringUtils.getTradeReportString(record)
    local time = date("%Y-%m-%d %H:%M:%S", record.timestamp)
    local player = record.playerName
    local target = record.targetName
    local location = record.location
    local diffMoney = record.receiveMoney - record.giveMoney
    local money = ""
    if diffMoney > 0 then
        money = "，"..format(L["recordReportMoneyGain"], StringUtils.formatMoneyString(diffMoney))
    elseif diffMoney < 0 then
        money = "，"..format(L["recordReportMoneyLose"], StringUtils.formatMoneyString(-diffMoney))
    end
    local items = ""
    if #record.giveItems > 0 then
        items = "，"..items .. format(L["recordReportMoneyLose"], StringUtils.formatItemString(record.giveItems))
    end
    if #record.receiveItems > 0 then
        items = "，"..items..format(L["recordReportMoneyGain"], StringUtils.formatItemString(record.receiveItems))
    end
    local content = format(L["recordReportTemplate"],
        time, player, target, location, money, items)
    return content
end

----------------------------------------
--         对其他模块暴露的接口         --
----------------------------------------

Addon.StringUtils = StringUtils;