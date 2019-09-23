#import "LFRedParamManager.h"
#import "LFRedManager.h"
#import "WeChatClass.h"


// 设置红包是否自动抢按钮
%hook NewSettingViewController
- (void)reloadTableData{
    %orig;
    WCTableViewManager *tbViewManager= [(id)self valueForKey:@"m_tableViewMgr"];

    WCTableViewSectionManager *section = [%c(WCTableViewSectionManager) sectionInfoDefaut];

    WCTableViewCellManager *redCell = [%c(WCTableViewCellManager) switchCellForSel:@selector(dealWithRedSwitch) target:[LFRedManager sharedInstance] title:@"红包助手" on:[LFRedManager sharedInstance].isAutoRed];

    [section addCell:redCell];
    [tbViewManager insertSection:section At:0];
    MMTableView *tableView = [tbViewManager getTableView];
    [tableView reloadData];
}
%end


%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2{
	%orig;

    //cgiCmdid = 3 可抢
	if (arg1.cgiCmdid != 3){ return; }

	NSError *err;
    NSDictionary *bufferDic = [NSJSONSerialization JSONObjectWithData:arg1.retText.buffer options:NSJSONReadingMutableContainers error:&err];

    // 已抢过
	if ([bufferDic[@"receiveStatus"] integerValue] == 2) { return; }
	// 红包被抢完
	if ([bufferDic[@"hbStatus"] integerValue] == 4) { return; }
	//判断是否是外挂
	if (!bufferDic[@"timingIdentifier"]) { return; }
	LFRedParamManager *mgrParams = [[LFRedManager sharedInstance] getParams];
	mgrParams.timingIdentifier = bufferDic[@"timingIdentifier"];

	//WCRedEnvelopesLogicMgr
    WCRedEnvelopesLogicMgr *redLogicMgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(WCRedEnvelopesLogicMgr) class]];
    [redLogicMgr OpenRedEnvelopesRequest:[mgrParams singProtoParam]];

}

%end

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap{
    %log;
    %orig;

    NSLog(msg,wrap);
    if(wrap.m_uiMessageType == 49){

    	//红包
        if ([wrap.m_nsContent rangeOfString:@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao"].location != NSNotFound) { 

        	CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
            CContact *selfContact = [contactManager getSelfContact];

        	// 自动抢红包开关
        	if (![LFRedManager sharedInstance].isAutoRed){return;}

            NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
            NSString *nativeString = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

            NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeString separator:@"&"];


			NSMutableDictionary *params = [NSMutableDictionary dictionary];
	        if ([wrap.m_nsFromUsr hasSuffix:@"@chatroom"]){ //群红包
	            [params setObject:@"0" forKey:@"inWay"]; //0:群聊，1：单聊
	        }else {     //个人红包
	            [params setObject:@"1" forKey:@"inWay"]; 
	        }
	        [params setObject:nativeUrlDict[@"sendid"] forKey:@"sendId"];
	        [params setObject:nativeUrl forKey:@"nativeUrl"];
	        [params setObject:nativeUrlDict[@"msgtype"] forKey:@"msgType"];
	        [params setObject:nativeUrlDict[@"channelid"] forKey:@"channelId"];
	        [params setObject:@"0" forKey:@"agreeDuty"];
	        WCRedEnvelopesLogicMgr *logicMgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(WCRedEnvelopesLogicMgr) class]];
			[logicMgr ReceiverQueryRedEnvelopesRequest:params];

			// 存储打开红包的参数
			LFRedParamManager *mgrParams = [[LFRedParamManager alloc] init];
            mgrParams.msgType = nativeUrlDict[@"msgtype"];
		    mgrParams.sendId = nativeUrlDict[@"sendid"];
		    mgrParams.channelId = nativeUrlDict[@"channelid"];
		    mgrParams.nickName = [selfContact getContactDisplayName];
		    mgrParams.headImg = [selfContact m_nsHeadImgUrl];
		    mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
		    mgrParams.sessionUserName = wrap.m_nsFromUsr;
		    mgrParams.sign = nativeUrlDict[@"sign"];

        }
    }
}
%end



