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

    //WCTableViewCellManager *setCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(settingRedView) target:self title:@"微信助手"];
    // [section addCell:setCell];

    [tbViewManager insertSection:section At:0];
    MMTableView *tableView = [tbViewManager getTableView];
    [tableView reloadData];
}

// %new 
// -(void)settingRedView
// {
// 	MySettingViewController *myView = [[MySettingViewController alloc]init];
//     [self.navigationController pushViewController:myView animated:YES];
// }

%end


%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2{
	%orig;

    //cgiCmdid = 3 可抢
	if (arg1.cgiCmdid != 3){ return; }

	NSError *err;
    NSDictionary *bufferDic = [NSJSONSerialization JSONObjectWithData:arg1.retText.buffer options:NSJSONReadingMutableContainers error:&err];
    // 打开红包的参数
    LFRedParamManager *mgrParams = [[LFRedManager sharedInstance] getParams];
    BOOL (^isReceiveRed)()  = ^BOOL() {
    	// 非自动抢红包
    	if (!mgrParams){return NO;}
    	// 已抢过
		if ([bufferDic[@"receiveStatus"] integerValue] == 2) { return NO; }
		// 红包被抢完
		if ([bufferDic[@"hbStatus"] integerValue] == 4) { return  NO; }
		//判断是否是外挂
		if (!bufferDic[@"timingIdentifier"]) { return NO; }

		// 判断红包上的描述
		BOOL (^isDescLimit)() = ^BOOL() {
	        NSArray *descArray = @[@"错抢",@"误抢",@"双倍",@"两倍",@"三倍"];
	        for (int i = 0; i < descArray.count; ++i)
	        {
	            if ([bufferDic[@"wishing"] rangeOfString:descArray[i]].location != NSNotFound) {
	                return YES;
	            }
	        }
	        return NO;
	    };
	    if (isDescLimit()){return NO;}
	    
	    return YES;
    };

    NSLog(@"打开红包参数----%@",mgrParams);

    if (isReceiveRed())
    {
    	mgrParams.timingIdentifier = bufferDic[@"timingIdentifier"];

		//WCRedEnvelopesLogicMgr
	    WCRedEnvelopesLogicMgr *redLogicMgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(WCRedEnvelopesLogicMgr) class]];
	    // 打开红包
	    [redLogicMgr OpenRedEnvelopesRequest:[mgrParams singProtoParam]];
    }
}

%end

%hook CMessageMgr
/**
msg当前聊天消息的对象，群格式17733384035@chatroom，个人wxid_s8fx99ltaybp12
自己在群里发消息，判断m_nsToUsr是否包含chatroom
他人在群里发消息，判断m_nsFromUsr是否包含chatroom
*/
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap{
    %log;
    %orig;

    // NSLog(msg,wrap);
    if(wrap.m_uiMessageType == 49){

    	//红包
        if ([wrap.m_nsContent rangeOfString:@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao"].location != NSNotFound) { 

        	CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
            CContact *selfContact = [contactManager getSelfContact];


        	// 自动抢红包开关
        	BOOL (^isAutoRed)() = ^BOOL() {
				return [LFRedManager sharedInstance].isAutoRed;
			};
        	if (!isAutoRed()){return;}

        	//是否是自己发消息（红包）
        	BOOL (^isSender)() = ^BOOL() {
				return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
			};

        	//是否是群消息（红包）
        	BOOL (^isGroup)() = ^BOOL() {
				return [msg rangeOfString:@"@chatroom"].location != NSNotFound;
			};

			//个人红包不自动领
			if (!isGroup()){return;}

			// 是否自己在群聊中发消息（红包）
			BOOL (^isGroupSender)() = ^BOOL() {
				return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
			};


            NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
            NSString *nativeString = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

            NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeString separator:@"&"];


			NSMutableDictionary *params = [NSMutableDictionary dictionary];
	        if (isGroup()){ //群红包
	            [params setObject:@"0" forKey:@"inWay"]; //0:群聊，1：单聊
	        }else {     //个人红包
	            [params setObject:@"1" forKey:@"inWay"]; 
	        }
	        [params setObject:nativeUrlDict[@"sendid"] forKey:@"sendId"];
	        [params setObject:nativeUrl forKey:@"nativeUrl"];
	        [params setObject:nativeUrlDict[@"msgtype"] forKey:@"msgType"];
	        [params setObject:nativeUrlDict[@"channelid"] forKey:@"channelId"];
	        [params setObject:@"0" forKey:@"agreeDuty"];
	        NSLog(@"红包验证参数-----%@",params);
	        WCRedEnvelopesLogicMgr *logicMgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(WCRedEnvelopesLogicMgr) class]];
	        //发送红包验证消
			[logicMgr ReceiverQueryRedEnvelopesRequest:params];

			// 存储打开红包的参数
			LFRedParamManager *mgrParams = [[LFRedParamManager alloc] init];
            mgrParams.msgType = nativeUrlDict[@"msgtype"];
		    mgrParams.sendId = nativeUrlDict[@"sendid"];
		    mgrParams.channelId = nativeUrlDict[@"channelid"];
		    mgrParams.nickName = [selfContact getContactDisplayName];
		    mgrParams.headImg = [selfContact m_nsHeadImgUrl];
		    mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
		    mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
		    mgrParams.sign = nativeUrlDict[@"sign"];
            [[LFRedManager sharedInstance]addParams:mgrParams];

        }
    }
}
%end



