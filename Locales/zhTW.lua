local _, addon = ...

if GetLocale() ~= "zhTW" then return end

addon.L = {
    ["title"] = "交易記錄",
    ["bindingNameToggle"] = "打開/關閉交易記錄窗口",
    ["enableTradeRecord"] = "啟用交易記錄功能",
    ["enableTradeConsoleLog"] = "聊天窗輸出交易詳情",
    ["enableMailMoneyChange"] = "啟用郵件金幣變動報告",
    ["mailMoneyChangeIncr"] = "本次郵件操作獲得 |cFFFFFFFF%s|r",
    ["mailMoneyChangeDecr"] = "本次郵件操作失去 |cFFFFFFFF%s|r",
    ["ldbTooltipRecentTradeTitle"] = "最近交易：",
    ["ldbTooltipRecentTradeNone"] = "|cFFBBBBBB無",
    ["ldbTooltipRecentTradeCount"] = "|cFFBBBBBB%s 筆",
    ["ldbTooltipDesc1"] = "|cFFBBBBBB左鍵：打開交易記錄",
    ["ldbTooltipDesc2"] = "|cFFBBBBBB右鍵：打開設置頁面",
    ["tradeRecordError"] = "|cFFE5B200與[%s]的交易失敗: %s",
    ["tradeRecordCancel"] = "|cFFE5B200與[%s]的交易取消: %s",
    ["tradeRecordComplete"] = "|cFFE5B200與[%s]的交易成功。",
    ["tradeRecordCancelReasonSelf"] = "我取消了交易",
    ["tradeRecordCancelReasonSelfTooFar"] = "我超出了距離",
    ["tradeRecordCancelReasonTarget"] = "對方取消了交易",
    ["tradeRecordCancelReasonTargetTooFar"] = "對方超出了距離",
    ["tradeRecordCancelReasonUnknown"] = "未知原因",
    ["recordFrameActionBtnSelect"] = "|cFF888888已選中：%d/%d|r",
    ["recordFrameActionBtnPre"] = "上一頁",
    ["recordFrameActionBtnNext"] = "下一頁",
    ["recordFrameActionDeleteRecord"] = "刪除記錄",
    ["recordFrameActionDeleteConfirm"] = "確定要刪除選中的%d條記錄嗎？",
    ["recordFrameActionDeleteConfirmOk"] = "|cFFFF0000刪除",
    ["recordFrameActionDeleteConfirmCancel"] = "取消",
    ["recordFrameTableHeaderSerial"] = "#",
    ["recordFrameTableHeaderTime"] = "時間",
    ["recordFrameTableHeaderTarget"] = "交易對象",
    ["recordFrameTableHeaderType"] = "類型",
    ["recordFrameTableHeaderLocation"] = "位置",
    ["recordFrameTableHeaderMoney"] = "金錢",
    ["recordFrameTableHeaderGiveItems"] = "交出物品",
    ["recordFrameTableHeaderReceiveItems"] = "收到物品",
    ["recordFrameTableTypeTrade"] = "交易",
    ["recordFrameTooltipGiveItems"] = "交出物品",
    ["recordFrameTooltipReceiveItems"] = "收到物品",
    ["recordFrameTooltipItemCount"] = "共 %d 件",
    ["recordReport"] = "交易通報",
    ["recordReport_SAY"] = "說",
    ["recordReport_YELL"] = "喊",
    ["recordReport_PARTY"] = "小隊",
    ["recordReport_RAID"] = "團隊",
    ["recordReport_INSTANCE_CHAT"] = "副本",
    ["recordReport_GUILD"] = "公會",
    ["recordReport_OFFICER"] = "官員",
    ["recordReportTemplate"] = "%s「%s」與「%s」在%s交易%s%s",
    ["recordReportTitle"] = "===========交易通報===========",
    ["recordReportMoneyGive"] = "交出 %s",
    ["recordReportMoneyReceive"] = "收到 %s",
    ["recordReportMoneyUnitGold"] = "金",
    ["recordReportMoneyUnitSilver"] = "銀",
    ["recordReportMoneyUnitCopper"] = "銅",
    ["recordReportDivider"] = "==============================",
    ["recordFrameActionFilter"] = "篩選：",
    ["recordFrameActionCharacter"] = "所有角色",
}