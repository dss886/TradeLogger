local _, Addon = ...

local Logger = {};

Logger.LEVEL = {
    ["DEBUG"] = 0,
    ["INFO"] = 1,
    ["WARN"] = 2,
    ["ERROR"] = 3,
}

Logger.logLevel = Logger.LEVEL.DEBUG;

local LEVEL_COLOR = {
    ["DEBUG"] = "|cFFBBBBBB",
    ["INFO"] = "|cFF00FF00",
    ["WARN"] = "|cFFFFFF00",
    ["ERROR"] = "|cFFFF0000",
}

local LOGGER_TEMPLATE = "|cFF00CCFF[TradeLogger]: %s%s|r";

function Logger.PrintImpl(content, deps)
    if type(content) == "function" then
        return "[function]";
    elseif type(content) == "table" then
        local str = "{";
        local indent = string.rep(" ", deps * 4);
        local indent2 = string.rep(" ", (deps + 1) * 4);
        for k, v in pairs(content) do
            str = str .. format("|n%s%s: %s", indent2, k, Logger.PrintImpl(v, deps + 1));
        end
        str = str .. format("|n%s%s", indent, "}");
        return str;
    else
        return tostring(content);
    end
end

function Logger.Info(content)
    if Logger.logLevel <= Logger.LEVEL.INFO then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.INFO, Logger.PrintImpl(content, 0)));
    end
end

function Logger.Debug(content)
    if Logger.logLevel <= Logger.LEVEL.DEBUG then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.DEBUG, Logger.PrintImpl(content, 0)));
    end
end

function Logger.Warn(content)
    if Logger.logLevel <= Logger.LEVEL.WARN then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.WARN, Logger.PrintImpl(content, 0)));
    end
end

function Logger.Error(content)
    if Logger.logLevel <= Logger.LEVEL.ERROR then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.ERROR, Logger.PrintImpl(content, 0)));
    end
end

----------------------------------------
--        对其他模块暴露的接口         --
----------------------------------------

Addon.Logger = Logger;