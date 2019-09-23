


#pragma mark - SettingView
@interface MMUIViewController : UIViewController
@end

@interface NewSettingViewController: MMUIViewController
- (void)reloadTableData;
@end


#pragma mark - TableView
@interface WCTableViewManager : NSObject
- (id)getTableView;
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;
- (void)addSection:(id)arg1;
@end

@interface WCTableViewSectionManager : NSObject
+ (id)sectionInfoDefaut;
- (void)addCell:(id)arg1;
@end

@interface WCTableViewCellManager
+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(_Bool)arg4;
@end

@interface MMTableView: UITableView
@end

#pragma mark - redClass

@interface SKBuiltinBuffer_t : NSObject
@property(retain, nonatomic) NSData *buffer; // @dynamic buffer;
@end

@interface HongBaoRes : NSObject
@property(nonatomic) int cgiCmdid; // @dynamic cgiCmdid;
@property(retain, nonatomic) SKBuiltinBuffer_t *retText; // @dynamic retText;
@end


@interface HongBaoReq : NSObject
@property(retain, nonatomic) SKBuiltinBuffer_t *reqText; // @dynamic reqText;
@end

@interface WCPayInfoItem : NSObject
@property(retain, nonatomic) NSString *m_c2cNativeUrl;
@end

@interface CMessageWrap : NSObject
@property(retain, nonatomic) WCPayInfoItem *m_oWCPayInfoItem; // @dynamic m_oWCPayInfoItem;
@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;
@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsToUsr;
@property(nonatomic) unsigned int m_uiMessageType; // @synthesize m_uiMessageType;
@end

@interface MMServiceCenter : NSObject
+ (instancetype)defaultCenter;
- (id)getService:(Class)service;
@end

@interface WCRedEnvelopesLogicMgr: NSObject
- (void)OpenRedEnvelopesRequest:(id)params;
- (void)ReceiverQueryRedEnvelopesRequest:(id)arg1;
@end

@interface CContact: NSObject <NSCoding>
@property(retain, nonatomic) NSString *m_nsUsrName;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl;
@property(retain, nonatomic) NSString *m_nsNickName;
- (id)getContactDisplayName;
@end

@interface CContactMgr : NSObject
- (id)getSelfContact;
@end


@interface WCBizUtil : NSObject
+ (id)dictionaryWithDecodedComponets:(id)arg1 separator:(id)arg2;
@end