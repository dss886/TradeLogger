local AddonName, Addon = ...

local L = Addon.L
local Logger = Addon.Logger
local EventBus = Addon.EventBus
local Template = Addon.Template
local tinsert = table.insert

local TABLE_COLS = {
    { name = "serial", width = 32 },
    { name = "time",   width = 120 },
    { name = "target", width = 88 },
    { name = "type",   width = 48 },
    { name = "location", width = 64 },
    { name = "money",  width = 80 },
    { name = "giveItems",  width = 180 },
    { name = "receiveItems",  width = 180 },
}
local TITLE_BAR_HEIGHT = 40
local ACTION_BAR_HEIGHT = 32
local TABLE_ROW_HEIGHT = 32
local TABLE_ROW_COUNT = 10
local TABLE_MARGIN_H = 16
local DESC_HEIGHT = 40

local Frame
local Dirty = true
local CurPage = 1
local CurRecords = {}

local Data = {}
local Action = {}
local Builder = {}

----------------------------------------
--              UI初始化               --
----------------------------------------

-- 创建主窗口
function Builder.InitFrame()
    if Frame then
        return
    end
    local frame = Builder.CreateMainFrame()
    Builder.CreateTitleBar(frame)
    Builder.CreateActionBar(frame)
    Builder.CreateTable(frame)
    Builder.CreateToolTip(frame)
    Builder.CreateDescription(frame)
    Frame = frame
end

-- 创建窗口容器
function Builder.CreateMainFrame()
    local frameName = AddonName .. "RecordFrame"
    local frame = Template.CreateBackDropFrame(frameName, UIParent, { 0, 0, 0, 0.7 }, { 1, 1, 1, 0.5 })
    -- 确保不让鼠标穿透窗口
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetPoint("CENTER", 0, 64)
    frame:SetMovable(true)
    frame:SetUserPlaced(true)
    frame:SetDontSavePosition(false)
    frame:SetScript("OnShow", Action.OnFrameShow)
    frame:SetScript("OnHide", Action.OnFrameHide)
    -- 确保窗口可以在按下Esc时关闭
    table.insert(UISpecialFrames, frameName)
    local height = TITLE_BAR_HEIGHT + ACTION_BAR_HEIGHT
        + TABLE_ROW_HEIGHT * (TABLE_ROW_COUNT + 1) + DESC_HEIGHT
    local width = TABLE_MARGIN_H * 2 + 2
    for _, col in ipairs(TABLE_COLS) do
        width = width + col.width
    end
    frame:SetSize(width, height)
    frame:Hide()
    return frame
end

-- 创建标题栏
function Builder.CreateTitleBar(frame)
    local titleBar = Template.CreateBackDropFrame(nil, frame, { 0, 0, 0, 0.3 }, nil)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(TITLE_BAR_HEIGHT)
    titleBar:EnableMouse(true)
    titleBar:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    titleBar:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)
    -- 分割线
    local divider = Template.CreateDivider(titleBar)
    divider:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 1, 0)
    divider:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", -1, 0)
    -- 标题
    local title = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetText("|cFF00CCFF" .. AddonName)
    title:SetPoint("LEFT", titleBar, "LEFT", 20, 0)
    title:SetFont(STANDARD_TEXT_FONT, 14)
    -- 版本号
    local version = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    version:SetText("|cFF888888v" .. C_AddOns.GetAddOnMetadata(AddonName, "Version"))
    version:SetPoint("LEFT", title, "RIGHT", 8, -1)
    version:SetFont(STANDARD_TEXT_FONT, 12)
    -- 关闭按钮
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(32, 32)
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -4, 0)
    closeButton:SetScript("OnClick", function() frame:Hide(); end)
    frame.titleBar = titleBar
end

-- 创建操作栏
function Builder.CreateActionBar(frame)
    local actionBar = CreateFrame("Frame", nil, frame)
    actionBar:SetPoint("TOPLEFT", frame.titleBar, "BOTTOMLEFT", 0, 0)
    actionBar:SetPoint("TOPRIGHT", frame.titleBar, "BOTTOMRIGHT", 0, 0)
    actionBar:SetHeight(ACTION_BAR_HEIGHT)
    actionBar:EnableMouse(true)

    local preBtn = Template.CreatePlainButton(actionBar,
        L["recordFrameActionBtnPre"], ACTION_BAR_HEIGHT, Action.OnActionPreClick)
    local nextBtn = Template.CreatePlainButton(actionBar,
        L["recordFrameActionBtnNext"], ACTION_BAR_HEIGHT, Action.OnActionNextClick)

    -- pageBtn单独处理下
    local pageBtn = Template.CreatePlainButton(actionBar, "1/1", ACTION_BAR_HEIGHT, nil)
    pageBtn:Disable()
    pageBtn:SetWidth(pageBtn:GetTextWidth() + 16 < ACTION_BAR_HEIGHT
        and ACTION_BAR_HEIGHT or pageBtn:GetTextWidth() + 16)

    nextBtn:SetPoint("RIGHT", actionBar, "RIGHT", -16, 0)
    pageBtn:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
    preBtn:SetPoint("RIGHT", pageBtn, "LEFT", -8, 0)

    frame.actionBar = actionBar
    frame.pagination = pageBtn
end

-- 创建表格
function Builder.CreateTable(frame)
    local table = Template.CreateBackDropFrame(nil, frame, { 0, 0, 0, 0.3 }, { 1, 1, 1, 0.5 })
    table:SetPoint("TOPLEFT", frame.actionBar, "BOTTOMLEFT", TABLE_MARGIN_H, 0)
    table:SetPoint("TOPRIGHT", frame.actionBar, "TOPRIGHT", -TABLE_MARGIN_H, 0)
    table:SetHeight(TABLE_ROW_HEIGHT * (TABLE_ROW_COUNT + 1))
    Builder.CreateTableHeader(table)
    table.rows = {}
    for i = 1, TABLE_ROW_COUNT do
        local row = Builder.CreateTableRow(table)
        row:SetPoint("TOPLEFT", table, "TOPLEFT", 0, -TABLE_ROW_HEIGHT * i)
        row:SetPoint("TOPRIGHT", table, "TOPRIGHT", 0, -TABLE_ROW_HEIGHT * i)
        table.rows[i] = row
    end
    frame.table = table
end

-- 创建表格头
function Builder.CreateTableHeader(table)
    local header = CreateFrame("Frame", nil, table)
    header:SetPoint("TOPLEFT", table, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", table, "TOPRIGHT", 0, 0)
    header:SetHeight(TABLE_ROW_HEIGHT)
    header:EnableMouse(true)
    -- 分割线
    local divider = Template.CreateDivider(header)
    divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 1, 0)
    divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -1, 0)
    -- 字段
    local left = 0
    local keyPrefix = "recordFrameTableHeader"
    local remainWidth = header:GetWidth()
    for _, col in ipairs(TABLE_COLS) do
        local button = Template.CreateTableHeaderButton(header, L[keyPrefix..col.name:gsub("^%l", string.upper)], 30,
            col.width == -1 and remainWidth or col.width)
        button:SetPoint("LEFT", header, "LEFT", left, 0)
        left = left + col.width
        remainWidth = remainWidth - col.width
    end
    table.header = header
end

-- 创建表格行
function Builder.CreateTableRow(table)
    local row = Template.CreateTableRow(table, TABLE_ROW_HEIGHT)
    local left = 0
    for i = 1, #TABLE_COLS do
        local string = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        string:SetHeight(TABLE_ROW_HEIGHT)
        string:SetWidth(TABLE_COLS[i].width)
        string:SetPoint("LEFT", row, "LEFT", left, 0)
        string:SetTextColor(1, 1, 1, 0.8)
        left = left + TABLE_COLS[i].width
        row[TABLE_COLS[i].name] = string
    end
    return row
end

-- 创建鼠标提示
function Builder.CreateToolTip(frame)
    local name = AddonName .. "RecordFrameListTooltip"
    frame.detailTooltip = CreateFrame("GameTooltip", name, UIParent, "GameTooltipTemplate")
    frame.detailTooltip:Hide()
end

-- 创建描述
function Builder.CreateDescription(frame)
    local desc = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    desc:SetText(L["recordFrameTip1"])
    desc:SetHeight(DESC_HEIGHT)
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("CENTER")
    desc:SetPoint("TOPLEFT", frame.table, "BOTTOMLEFT", 4, 0)
    desc:SetFont(STANDARD_TEXT_FONT, 11)
    desc:SetTextColor(1, 1, 1, 0.5)
    frame.desc = desc
end

----------------------------------------
--              数据函数               --
----------------------------------------

function Data.GetTotalPage()
    return ceil(#CurRecords / TABLE_ROW_COUNT)
end

function Data.UpdatePagination()
    Frame.pagination:SetText(format("%d/%d", CurPage, Data.GetTotalPage()))
end

-- 根据目前的（排序、筛选、翻页等）条件刷新要显示的数据
function Data.UpdateCurRecords()
    -- TODO 过滤、排序
    CurRecords = {}
    local size = #TradeLoggerDB.tradeRecord
    for i = size, 1, -1 do
        tinsert(CurRecords, TradeLoggerDB.tradeRecord[i])
    end
end

function Data.ShowTableData()
    for i = 1, TABLE_ROW_COUNT do
        local index = (CurPage - 1) * TABLE_ROW_COUNT + i
        if index <= #CurRecords then
            Data.SetRowText(Frame.table.rows[i], CurRecords[index], index)
        end
    end
end

function Data.ClearTableData()
    for i = 1, TABLE_ROW_COUNT do
        local row = Frame.table.rows[i]
        for _, col in ipairs(TABLE_COLS) do
            row[col.name]:SetText("")
            row:SetScript("OnMouseUp", nil)
            row:Disable()
        end
    end
end

-- 根据交易记录填充行数据
function Data.SetRowText(row, record, index)
    row:Enable()
    -- serial
    row.serial:SetFont(STANDARD_TEXT_FONT, 12)
    row.serial:SetText(index)
    -- time
    row.time:SetFont(STANDARD_TEXT_FONT, 12)
    row.time:SetText(date("%Y-%m-%d %H:%M:%S", record.timestamp))
    -- target
    local tClassColorR, tClassColorG, tClassColorB = GetClassColor(record.targetClass)
    row.target:SetText(record.targetName)
    row.target:SetTextColor(tClassColorR, tClassColorG, tClassColorB, 1)
    -- type
    if record.type == 0 then
        row.type:SetText(L["recordFrameTableTypeTrade"])
    elseif record.type == 1 then
        row.type:SetText(L["recordFrameTableTypeMail"])
    end
    -- location
    row.location:SetText(record.location)
    -- money
    local diffMoney = record.receiveMoney - record.giveMoney
    if diffMoney == 0 then
        row.money:SetText("-")
        row.money:SetTextColor(1, 1, 1, 0.8)
    elseif diffMoney > 0 then
        row.money:SetText(GetMoneyString(diffMoney))
        row.money:SetTextColor(0.3, 1, 0.3, 0.8)
    else
        row.money:SetText("-" .. GetMoneyString(-diffMoney))
        row.money:SetTextColor(1, 0.3, 0.3, 0.8)
    end
    -- give items
    row.giveItems:SetText(Data.GetRecordItemsDesc(record.giveItems))
    row.giveItems:SetNonSpaceWrap(false)
    row.giveItems:SetMaxLines(1)
    -- receive items
    row.receiveItems:SetText(Data.GetRecordItemsDesc(record.receiveItems))
    row.receiveItems:SetNonSpaceWrap(false)
    row.receiveItems:SetMaxLines(1)
    -- tooltip
    Data.SetItemTooltip(row, record)
end

-- 设置鼠标提示
function Data.SetItemTooltip(row, record)
    if #record.giveItems == 0 and #record.receiveItems == 0 then
        row.OnHover = nil
        return
    end
    local tip = Frame.detailTooltip
    row.OnHover = function (isEnter)
        if isEnter then
            tip:SetOwner(row, "ANCHOR_NONE")
            tip:SetPoint("LEFT", row, "RIGHT", TABLE_MARGIN_H + 2, 0)
            tip:ClearLines()
            if #record.giveItems > 0 then
                tip:AddLine(L["recordFrameTooltipGiveItems"], 1, 1, 1)
                for _, item in ipairs(record.giveItems) do
                    tip:AddDoubleLine(item.itemLink, "x"..item.count, 1, 1, 1, 1, 1, 1)
                end
            end
            if #record.receiveItems > 0 then
                if #record.giveItems > 0 then
                    tip:AddLine(" ")
                end
                tip:AddLine(L["recordFrameTooltipReceiveItems"], 1, 1, 1)
                for _, item in ipairs(record.receiveItems) do
                    tip:AddDoubleLine(item.itemLink, "x"..item.count, 1, 1, 1, 1, 1, 1)
                end
            end
            tip:Show()
        else
            tip:Hide()
        end
    end
end

function Data.GetRecordItemsDesc(items)
    if #items == 0 then
        return "-"
    end
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

----------------------------------------
--              逻辑函数               --
----------------------------------------

function Action.OnActionPreClick()
    if CurPage > 1 then
        CurPage = CurPage - 1
        Data.ClearTableData()
        Data.UpdatePagination()
        Data.ShowTableData()
    end
end

function Action.OnActionNextClick()
    if CurPage < Data.GetTotalPage() then
        CurPage = CurPage + 1
        Data.ClearTableData()
        Data.UpdatePagination()
        Data.ShowTableData()
    end
end

function Action.OnFrameShow()
    if not Dirty then
        return
    end
    CurPage = 1
    Data.ClearTableData()
    Data.UpdateCurRecords()
    Data.UpdatePagination()
    Data.ShowTableData()
    Dirty = false
end

function Action.OnFrameHide()
    if CurPage ~= 1 then
        Dirty = true
    end
end

function Action.ToggleRecordFrame()
    if not Frame then
        Builder.InitFrame()
    end
    if Frame:IsShown() then
        Frame:Hide()
    else
        Frame:Show()
    end
end

----------------------------------------
--              注册事件               --
----------------------------------------

EventBus.Register("TL_TOGGLE_RECORD_FRAME", Action.ToggleRecordFrame)
EventBus.Register("TL_TRADE_RECORD_ADDED", function() Dirty = true; end)
