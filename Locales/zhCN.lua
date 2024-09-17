local _, addon = ...

addon.L = {
    ["title"] = "交易记录",
    ["enableTradeRecord"] = "启用交易记录功能",
    ["enableTradeConsoleLog"] = "聊天窗输出交易详情",
    ["enableTradeWhisper"] = "启用交易密语通报",
    ["enableMailRecord"] = "启用邮件记录功能",
    ["enableMailConsoleLog"] = "聊天窗输出邮件操作详情",
    ["enableMailMoneyChange"] = "聊天窗输出邮件金币变动报告",
    ["mailMoneyChangeIncr"] = "本次邮件操作获得 |cFFFFFFFF%s|r",
    ["mailMoneyChangeDecr"] = "本次邮件操作失去 |cFFFFFFFF%s|r",
    ["ldbTooltipRecentTradeTitle"] = "最近交易：",
    ["ldbTooltipRecentTradeNone"] = "|cFFBBBBBB无",
    ["ldbTooltipRecentTradeCount"] = "|cFFBBBBBB%s 笔",
    ["ldbTooltipDesc1"] = "|cFFBBBBBB左键：打开交易记录",
    ["ldbTooltipDesc2"] = "|cFFBBBBBB右键：打开设置页面",
    ["tradeRecordError"] = "|cFFE5B200与[%s]的交易失败: %s",
    ["tradeRecordCancel"] = "|cFFE5B200与[%s]的交易取消: %s",
    ["tradeRecordComplete"] = "|cFFE5B200与[%s]的交易成功。",
    ["tradeRecordDescGive"] = "交出%s。",
    ["tradeRecordDescReceive"] = "收到%s。",
    ["tradeRecordCancelReasonSelf"] = "我取消了交易",
    ["tradeRecordCancelReasonSelfTooFar"] = "我超出了距离",
    ["tradeRecordCancelReasonTarget"] = "对方取消了交易",
    ["tradeRecordCancelReasonTargetTooFar"] = "对方超出了距离",
    ["tradeRecordCancelReasonUnknown"] = "未知原因",
    ["recordFrameActionBtnPre"] = "上一页",
    ["recordFrameActionBtnNext"] = "下一页",
    ["recordFrameTableHeaderSerial"] = "#",
    ["recordFrameTableHeaderTime"] = "时间",
    ["recordFrameTableHeaderTarget"] = "交易对象",
    ["recordFrameTableHeaderType"] = "类型",
    ["recordFrameTableHeaderLocation"] = "位置",
    ["recordFrameTableHeaderMoney"] = "金钱",
    ["recordFrameTableHeaderGiveItems"] = "交出物品",
    ["recordFrameTableHeaderReceiveItems"] = "收到物品",
    ["recordFrameTableTypeTrade"] = "交易",
    ["recordFrameTableTypeMail"] = "邮件",
    ["recordFrameTip1"] = "点击分类进行排序，点击交易查看详情",
    ["recordFrameTooltipGiveItems"] = "交出物品",
    ["recordFrameTooltipReceiveItems"] = "收到物品",
}