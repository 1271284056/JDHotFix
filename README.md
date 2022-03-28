# JDHotFix


如何写热修复?
oc代码都可以热修,swift类里面代码前缀有@objc的可以热修,可以用方法交换等api替换原来方法的实现来实现热修
1 在Hotfix.js里面写热修复代码可以直接调试
例子1: 双列广告卡片高度小于内容显示问题修复,方案: 替换获取高度方法,双列广告可以返回固定的.
fixInstanceMethodReplace('MPFeedAdViewModel','cellHeight',function(instance, originInvocation, originArguments){
        //获取当前对象instance isRcmdCollectionType方法返回值,方法没有参数
    var isRcmdCollectionType = runInstanceWithNoParamter(instance,"isRcmdCollectionType")

    if (isRcmdCollectionType == true) {
        //值是true时候代表是双列广告, 返回固定值
        return 225
    } else  {
        //返回原来函数的返回值
        return runInvocation(originInvocation)
    }
});

fixInstanceMethodReplace 是方法替换,上面代码意思是把MPFeedAdViewModel类的对象方法cellHeight实现替换成下面的实现
instance 是self,也是当前MPFeedAdViewModel对象, originInvocation是原来方法的实现, originArguments是方法参数,是个数组从0开始

例子2: 我的作品样例文章方法少实现问题修复, 方案: 替换点击时候方法,没有实现对象方法调用另外一个跳转方法
fixMethodReplace('MPMineWorksView', false, 'onCellClick:', function(instance, originInvocation, originArguments) {
    //获取参数对象model
    var model0 = originArguments[0]
    //判断是否是文章对象,发布中和样例文章是Article对象
    var isArticle = runInstanceMethod(model0, "isKindOfClass:", [runClassMethod("Article", "class", [])])
    if (isArticle) {
        var containerId = runInstanceMethod(model0, "containerId", [])
        var publishModel = runInstanceMethod(model0, "publishModel", [])
        if (publishModel != null) {
            var state = runInstanceMethod(publishModel, "state", [])
            if (state == 0 || state == 1) {
                //发布中文章执行原来函数
                runInvocation(originInvocation)
            } else {
                runInstanceMethod(model0, "openContentWithContenterId:completion:", [containerId, null])
            }
        } else {
             //样例文章调用原来跳转方法
            runInstanceMethod(model0, "openContentWithContenterId:completion:", [containerId, null])
        }
    } else {
        //内容跳转执行原来方法
        runInvocation(originInvocation)
    }
});

热修代码从js转成oc代码实现在 MPHotfix类里面
2  测试好后
创建版本号_main.js文件,比如7.2.0_main.js,
把刚才写的热修复代码复制到这个文件(可以把7.2.0_main.js文件后缀改成.m,复制好代码后,再把后缀改成.js)
把这个文件  7.2.0_main.js 右键 压缩成zip
3 上传热修文件
自己公司前端给一个上传zip文件生成地址的网页,zip拖拽上去后 拿到地址

4 热修文件针对自己账号看是否生效
 https://biz.xxxxx.cn/chain   打开热修配置网址
选择 app灰度配置
在发布之前可以针对userId测试热修是否生效
选择 hot_fix_info_user  ,uid_list添加自己的现网用户id
hf_zip_url  添加刚才导出的路径
然后用自己手机看热修是否生效
可以接口抓包看下发的hf_zip_url 地址是否对
{
                        "rule": {
                                "hf_enable": 1,
                                "hf_zip_url": "https:\/\/ss2.meipian.me\/app\/hotfix\/7.0.3_main.js.zip”
                        },
                        "type": "4"
                }, 
看  hf_zip_url 下发地址是否是你刚才填写的链接.


5 热修上线
右上角- 新增热修 创建文件 hot_fix_info_720,填写版本号和链接,最后点击启用


如果同一个版本又加新的热修
第一版是 7.2.0_main.js, 如果有升级热修文件 热修文件名main后面+1,比如: 7.2.0_main1.js. 新文件要包含原来的热修代码,自己新的热修代码写到下面
