#line 1 "Red/Tweak.xm"
#import "LFRedParamManager.h"
#import "LFRedManager.h"
#import "WeChatClass.h"




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class CContactMgr; @class WCTableViewCellManager; @class WCBizUtil; @class NewSettingViewController; @class WCTableViewSectionManager; @class CMessageMgr; @class WCRedEnvelopesLogicMgr; @class MMServiceCenter; 
static void (*_logos_orig$_ungrouped$NewSettingViewController$reloadTableData)(_LOGOS_SELF_TYPE_NORMAL NewSettingViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$NewSettingViewController$reloadTableData(_LOGOS_SELF_TYPE_NORMAL NewSettingViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$WCRedEnvelopesLogicMgr$OnWCToHongbaoCommonResponse$Request$)(_LOGOS_SELF_TYPE_NORMAL WCRedEnvelopesLogicMgr* _LOGOS_SELF_CONST, SEL, HongBaoRes *, HongBaoReq *); static void _logos_method$_ungrouped$WCRedEnvelopesLogicMgr$OnWCToHongbaoCommonResponse$Request$(_LOGOS_SELF_TYPE_NORMAL WCRedEnvelopesLogicMgr* _LOGOS_SELF_CONST, SEL, HongBaoRes *, HongBaoReq *); static void (*_logos_orig$_ungrouped$CMessageMgr$AsyncOnAddMsg$MsgWrap$)(_LOGOS_SELF_TYPE_NORMAL CMessageMgr* _LOGOS_SELF_CONST, SEL, NSString *, CMessageWrap *); static void _logos_method$_ungrouped$CMessageMgr$AsyncOnAddMsg$MsgWrap$(_LOGOS_SELF_TYPE_NORMAL CMessageMgr* _LOGOS_SELF_CONST, SEL, NSString *, CMessageWrap *); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$MMServiceCenter(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("MMServiceCenter"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$WCTableViewCellManager(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("WCTableViewCellManager"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$WCBizUtil(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("WCBizUtil"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$WCRedEnvelopesLogicMgr(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("WCRedEnvelopesLogicMgr"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$WCTableViewSectionManager(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("WCTableViewSectionManager"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$CContactMgr(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("CContactMgr"); } return _klass; }
#line 7 "Red/Tweak.xm"

static void _logos_method$_ungrouped$NewSettingViewController$reloadTableData(_LOGOS_SELF_TYPE_NORMAL NewSettingViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd){
    _logos_orig$_ungrouped$NewSettingViewController$reloadTableData(self, _cmd);
    WCTableViewManager *tbViewManager= [(id)self valueForKey:@"m_tableViewMgr"];

    WCTableViewSectionManager *section = [_logos_static_class_lookup$WCTableViewSectionManager() sectionInfoDefaut];

    WCTableViewCellManager *redCell = [_logos_static_class_lookup$WCTableViewCellManager() switchCellForSel:@selector(dealWithRedSwitch) target:[LFRedManager sharedInstance] title:@"红包助手" on:[LFRedManager sharedInstance].isAutoRed];
    [section addCell:redCell];

    
    

    [tbViewManager insertSection:section At:0];
    MMTableView *tableView = [tbViewManager getTableView];
    [tableView reloadData];
}













static void _logos_method$_ungrouped$WCRedEnvelopesLogicMgr$OnWCToHongbaoCommonResponse$Request$(_LOGOS_SELF_TYPE_NORMAL WCRedEnvelopesLogicMgr* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, HongBaoRes * arg1, HongBaoReq * arg2){
	_logos_orig$_ungrouped$WCRedEnvelopesLogicMgr$OnWCToHongbaoCommonResponse$Request$(self, _cmd, arg1, arg2);

    
	if (arg1.cgiCmdid != 3){ return; }

	NSError *err;
    NSDictionary *bufferDic = [NSJSONSerialization JSONObjectWithData:arg1.retText.buffer options:NSJSONReadingMutableContainers error:&err];
    
    LFRedParamManager *mgrParams = [[LFRedManager sharedInstance] getParams];
    BOOL (^isReceiveRed)()  = ^BOOL() {
    	
    	if (!mgrParams){return NO;}
    	
		if ([bufferDic[@"receiveStatus"] integerValue] == 2) { return NO; }
		
		if ([bufferDic[@"hbStatus"] integerValue] == 4) { return  NO; }
		
		if (!bufferDic[@"timingIdentifier"]) { return NO; }

		
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

		
	    WCRedEnvelopesLogicMgr *redLogicMgr = [[_logos_static_class_lookup$MMServiceCenter() defaultCenter] getService:[_logos_static_class_lookup$WCRedEnvelopesLogicMgr() class]];
	    
	    [redLogicMgr OpenRedEnvelopesRequest:[mgrParams singProtoParam]];
    }
}









static void _logos_method$_ungrouped$CMessageMgr$AsyncOnAddMsg$MsgWrap$(_LOGOS_SELF_TYPE_NORMAL CMessageMgr* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString * msg, CMessageWrap * wrap){
    HBLogDebug(@"-[<CMessageMgr: %p> AsyncOnAddMsg:%@ MsgWrap:%@]", self, msg, wrap);
    _logos_orig$_ungrouped$CMessageMgr$AsyncOnAddMsg$MsgWrap$(self, _cmd, msg, wrap);

    
    if(wrap.m_uiMessageType == 49){

    	
        if ([wrap.m_nsContent rangeOfString:@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao"].location != NSNotFound) { 

        	CContactMgr *contactManager = [[_logos_static_class_lookup$MMServiceCenter() defaultCenter] getService:[_logos_static_class_lookup$CContactMgr() class]];
            CContact *selfContact = [contactManager getSelfContact];


        	
        	BOOL (^isAutoRed)() = ^BOOL() {
				return [LFRedManager sharedInstance].isAutoRed;
			};
        	if (!isAutoRed()){return;}

        	
        	BOOL (^isSender)() = ^BOOL() {
				return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
			};

        	
        	BOOL (^isGroup)() = ^BOOL() {
				return [msg rangeOfString:@"@chatroom"].location != NSNotFound;
			};

			
			if (!isGroup()){return;}

			
			BOOL (^isGroupSender)() = ^BOOL() {
				return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
			};


            NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
            NSString *nativeString = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

            NSDictionary *nativeUrlDict = [_logos_static_class_lookup$WCBizUtil() dictionaryWithDecodedComponets:nativeString separator:@"&"];


			NSMutableDictionary *params = [NSMutableDictionary dictionary];
	        if (isGroup()){ 
	            [params setObject:@"0" forKey:@"inWay"]; 
	        }else {     
	            [params setObject:@"1" forKey:@"inWay"]; 
	        }
	        [params setObject:nativeUrlDict[@"sendid"] forKey:@"sendId"];
	        [params setObject:nativeUrl forKey:@"nativeUrl"];
	        [params setObject:nativeUrlDict[@"msgtype"] forKey:@"msgType"];
	        [params setObject:nativeUrlDict[@"channelid"] forKey:@"channelId"];
	        [params setObject:@"0" forKey:@"agreeDuty"];
	        NSLog(@"红包验证参数-----%@",params);
	        WCRedEnvelopesLogicMgr *logicMgr = [[_logos_static_class_lookup$MMServiceCenter() defaultCenter] getService:[_logos_static_class_lookup$WCRedEnvelopesLogicMgr() class]];
	        
			[logicMgr ReceiverQueryRedEnvelopesRequest:params];

			
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




static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$NewSettingViewController = objc_getClass("NewSettingViewController"); MSHookMessageEx(_logos_class$_ungrouped$NewSettingViewController, @selector(reloadTableData), (IMP)&_logos_method$_ungrouped$NewSettingViewController$reloadTableData, (IMP*)&_logos_orig$_ungrouped$NewSettingViewController$reloadTableData);Class _logos_class$_ungrouped$WCRedEnvelopesLogicMgr = objc_getClass("WCRedEnvelopesLogicMgr"); MSHookMessageEx(_logos_class$_ungrouped$WCRedEnvelopesLogicMgr, @selector(OnWCToHongbaoCommonResponse:Request:), (IMP)&_logos_method$_ungrouped$WCRedEnvelopesLogicMgr$OnWCToHongbaoCommonResponse$Request$, (IMP*)&_logos_orig$_ungrouped$WCRedEnvelopesLogicMgr$OnWCToHongbaoCommonResponse$Request$);Class _logos_class$_ungrouped$CMessageMgr = objc_getClass("CMessageMgr"); MSHookMessageEx(_logos_class$_ungrouped$CMessageMgr, @selector(AsyncOnAddMsg:MsgWrap:), (IMP)&_logos_method$_ungrouped$CMessageMgr$AsyncOnAddMsg$MsgWrap$, (IMP*)&_logos_orig$_ungrouped$CMessageMgr$AsyncOnAddMsg$MsgWrap$);} }
#line 174 "Red/Tweak.xm"
