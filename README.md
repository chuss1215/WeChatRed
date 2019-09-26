**功能**
自动抢红包插件

过滤：错抢、误抢、两倍等红包不抢，个人红包不自动抢

**抢红包逻辑分析**：

1. 打开消息界面，用Reveal或者cycript找到当前控制器界面：BaseMsgContentViewController
2. 用logify跟踪BaseMsgContentViewController类里面的方法，找到-[BaseMsgContentViewController addMessageNode:layout:addMoreMsg:]，并得知红包的type=49，该方法是接收红包通知，lldb追踪其调用堆栈
3. 打印通知方法的调用堆栈，如下：
```
-[CMessageMgr MainThreadNotifyToExt:]
-[BaseMsgContentLogicController OnAddMsg:MsgWrap:]
-[BaseMsgContentLogicController DidAddMsg:]
-[BaseMsgContentViewController addMessageNode:layout:addMoreMsg:]
```

找到CMessageMgr类，分析CMessageMgr，用logify跟踪CMessageMgr，找到收红包消息的方法-(void)AsyncOnAddMsg:(NSString *)message MsgWrap:(CMessageWrap* )msgWrap ，这样当消息一到来就能实现自动抢红包了。

4. 打开红包界面，用Reveal或者cycript找到当前控制器界面：WCRedEnvelopesReceiveHomeView，分析WCRedEnvelopesReceiveHomeView.h头文件，定位到处理红包的方法OnOpenRedEnvelopes。（该类方法不多，可以猜测到）
5. 反汇编工具静态分析 -[WCRedEnvelopesReceiveHomeView OnOpenRedEnvelopes],找到WCRedEnvelopesReceiveHomeViewOpenRedEnvelopes方法
6. 进一步分析WCRedEnvelopesReceiveHomeViewOpenRedEnvelopes方法，翻译成代码
7. 缺少参数键值对timingIdentifier的值，分析WCRedEnvelopesLogicMgr方法，用logify跟踪，每次打开红包、抢红包都会调用的方法，在-[WCRedEnvelopesLogicMgr OnWCToHongbaoCommonResponse:Request:]参数中获取到timingIdentifier
8. 调用WCRedEnvelopesLogicMgr的抢红包方法OpenRedEnvelopesRequest

设置自动抢开关
1. 找到设置界面控制器：NewSettingViewController
2. 分析NewSettingViewController.h头文件，可以看到WCTableViewManager和MMTableViewInfo两个与TableView相关的类，分别分析头文件，可以看到TableView相关的代码在WCTableViewManager类里
3. 分析WCTableViewManager，找到方法
```
- (void)addSection:(id)arg1;
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;
```
可以插入section，hook打印参数，得到arg1为WCTableViewSectionManager，分析头文件
```
- (void)addCell:(id)arg1;
- (void)insertCell:(id)arg1 At:(unsigned int)arg2;
```

**红包状态**
```
// cgiCmdid = 3 自己可抢 ，cgiCmdid = 4 自己抢完， cgiCmdid = 自己已抢过
// hbStatus = 2 可抢红包， hbStatus = 2 自己抢完， hbStatus = 4 不可抢 ，"hbStatus":5 过期红包
// "isSender":0 别人发的，"isSender":1 自己发的
// "hbType":1 群红包，"hbType":0 个人红包
// "receiveStatus":0 未抢过 ， "receiveStatus":2 已抢过
```


**arg1.retText.buffer**

{"retcode":0,"retmsg":"ok","sendId":"1000039401201909167011704328917","wishing":"恭喜发财，大吉大利","isSender":0,"receiveStatus":0,"hbStatus":2,"statusMess":"给你发了一个红包","hbType":0,"watermark":"","scenePicSwitch":1,"preStrainFlag":1,"sendUserName":"wxid_t64lm2fvfzsr22","timingIdentifier":"E51DEB7261600BB81FA30325A2F59C73","showYearExpression":1,"expression_md5":"","showRecNormalExpression":1}

**arg2.reqText.buffer**

//agreeDuty=0&channelId=1&inWay=1&msgType=1&nativeUrl=wxpay%3A%2F%2Fc2cbizmessagehandler%2Fhongbao%2Freceivehongbao%3Fmsgtype%3D1%26channelid%3D1%26sendid%3D1000039401201909167011704328917%26sendusername%3Dwxid_t64lm2fvfzsr22%26ver%3D6%26sign%3Dc8529ccc878e775b110d6c08960fc7b37e19529663d05ac187b7b77c725cc9548d324f5dc3638e911134960097380930c04055be63f875eafb1eb5a669a0cd697ece549c80b35af50b76593ba2420c5f&sendId=1000039401201909167011704328917


