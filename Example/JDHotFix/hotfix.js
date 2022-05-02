///修改参数值的例子
/// 注意，这里只支持修改方法返回值为对象的方法；参数类型除对象外，基础数据类型仅支持int，NSInteger，NSUInteger，float，CGFloat，BOOL
//fixInstanceMethodReplace('MPCreationMenuView','method:',function(instance, originInvocation, originArguments){
//
//	var index = originArguments[0]
//	if (index > 0) {
//		console.log('测试数据' + index)
//		originArguments[0] = 0
//		console.log('测试数据' + originArguments[0])
//
//		runVoidInstanceWith1Paramter(instance,'method:', originArguments[0])
//	} else {
//        console.log('测试数据' + '666')
//		runInvocation(originInvocation);
//	}
//});

fixeMethodAfter("JDHotFix_Example.TestSwift", false, "test", function(instance, originInvocation, originArguments) {
    //取出test1 方法第一个参数
    console.log("TestSwift hotfix执行了-->")
    //参数传递给方法2 test2:  没有参数传[]
//    runInstanceMethod(instance, "test2:", [argument0])
    //执行原来的test1:方法
//    runInvocation(originInvocation)

})

fixeMethodAfter("JDViewController", false, "test1:", function(instance, originInvocation, originArguments) {
    //取出test1 方法第一个参数
    var argument0 = originArguments[0]
    console.log("hotfix执行了-->" + argument0)
    //参数传递给方法2 test2:  没有参数传[]
    runInstanceMethod(instance, "test2:", [argument0])
    //执行原来的test1:方法
    runInvocation(originInvocation)

})

//fixInstanceMethodReplace('_TtC5ivwen20MPLiveViewController','viewDidLoad',function(instance, originInvocation, originArguments) {
//    runInstanceWith1Paramter(instance,'f1WithSite:', '111')
//});


//fixInstanceMethodBefore("MPDiscoveryViewController", "searchClick", function(instance, originInvocation, originArguments){
//    runVoidInstanceWithNoParamter(instance, 'testVoid')
//
//    var i = runInstanceMethod(instance, 'test')
//
//    console.log("test:"+i)
//    var j = runInstanceWithNoParamter(instance, 'test1')
//    console.log("test:"+j)
//
//    var k = runInstanceWithNoParamter(instance, 'test2')
//    console.log("test:"+k)
//
//    var n = runInstanceWithNoParamter(instance, 'test3')
//    console.log("test:"+n)
//
//    var m = runInstanceMethod(instance, 'test4:str:objc:', [1, "1", null])
//    console.log("test:"+m)
//
//    var x = runInstanceMethod(instance, 'test5')
//    console.log("test:x"+x.x+",y:"+x.y+",width:"+x.width+",height:"+x.height)
//
//    runInstanceMethod(instance, 'test6:', [{x: 1, y: 2, width: 3, height: 4}])
//
//});

//fixeMethodAfter("MPFeedCardHeadView", false, "layout", function(instance, originInvocation, originArguments){
//    var model = runInstanceMethod(instance, 'model')
//    var workType = runInstanceMethod(model, 'works_type')
//    var a = (workType == 1 || workType == 15)
//
//    var isRcmdTab = runInstanceMethod(model, 'isRcmdTab')
//    var isShortContentTab = runInstanceMethod(model, 'isShortContentTab')
//    var isShowSignature = runInstanceMethod(model, 'isShowSignature')
//    var isTalkPage = runInstanceMethod(model, 'isTalkPage')
//    var b = (isRcmdTab || isShortContentTab || isShowSignature || isTalkPage)
//
//    if (a && b) {
//        var timeView = runInstanceMethod(instance, 'timeView')
//        var timeYoga = runInstanceMethod(timeView, 'yoga')
//        runInstanceMethod(timeYoga, 'setValue:forKey:', [1, 'display'])
//    }
//    runInstanceMethod(instance, 'applyLayoutAll')
//});

//fixeMethodAfter('MPEditorViewController', false, 'keyboardDidHide:', function(instance, originInvocation, originArguments){
//    runInstanceMethod(instance, 'setValue:forKey:', [false, 'keyBoardHasShow'])
//});
//
//fixMethodReplace('MPEditorViewController', false, 'scrollViewDidScroll:', function(instance, originInvocation, originArguments){
//    var scrollView = originArguments[0]
//    var contentOffset = runInstanceMethod(scrollView, 'contentOffset')
//    var offsetY = contentOffset.y
//    var keyBoardHasShow = runInstanceMethod(instance, 'keyBoardHasShow')
//    if (keyBoardHasShow && offsetY < -20) {
//        var webView = runInstanceMethod(instance, 'webView')
//        runInstanceMethod(webView, 'resignFirstResponder')
//        runInstanceMethod(webView, 'evaluateJavaScript:completionHandler:', ['blur()', null])
//    }
//})

// fixMethodBefore('Article',false, 'addVideoSection:thumbnail:videoUrl:videoFameImgs:width:height:isHDVideo:videoLength:platform:position:', function(instance, originInvocation, originArguments) {
//     var videoUrl = originArguments[2];
//     // console.log('dfsafnsakfsafh;af' + videoUrl)
//     if (videoUrl.search("/out_put_video/") != -1 ) {
//         var newVideoUrl =  videoUrl.replace('/out_put_video', '')
//         // console.log(videoUrl + '  -----  ' + newVideoUrl)
//          runClassMethod('FileUtils', 'moveDir:to:',[videoUrl,newVideoUrl])
//     }
// });


// fixeMethodAfter('MPTopicContributeArticleViewController',false, 'loadVideoDataWithRefresh:', function(instance2, originInvocation, originArguments) {
//     fixMethodBefore('NSDictionary',false, 'mp_safeStringForKey:', function(instance, originInvocation, originArguments) {
//         var key = originArguments[0];
//         if (key == "last_list_id" ) {
//             if(!instance.hasOwnProperty("last_list_id")) {
//                 if(instance.hasOwnProperty("data")) {
//                      var data = instance["data"]
//                      var last_list_id = data["last_list_id"]
//                      if(last_list_id != "undefined" && last_list_id != null && last_list_id != "" &&  last_list_id.length > 0){
//                          fixeMethodAfter('MPTopicContributeArticleViewController',false, 'setLast_list_id:', function(instance3, originInvocation, originArguments){
//                              var iv1 = originArguments[0];
//                              if ((iv1 == "undefined" || iv1 == null || iv1 == "") && last_list_id.length > 0) {
//                                  runInstanceMethod(instance3, 'setLast_list_id:', [last_list_id])
//                                  last_list_id  = ""
//                              }
//                          });
//                      }
//                 }
//             }
//         }
//     });

// });


//fixeMethodAfter("MPGrowthController", false, "uploadPush", function(instance, originInvocation, originArguments) {
//    var notificationCenter = runClassMethod('NSNotificationCenter', 'defaultCenter',[])
//    runInstanceMethod(notificationCenter, 'removeObserver:', [instance])
//
//    console.log("test:-=-=-=" + notificationCenter)
//});

// fixeMethodAfter("MPGrowthController", false, "traceSaveWithUri:options:", function(instance, originInvocation, originArguments) {
//     var notificationCenter = runClassMethod('NSNotificationCenter', 'defaultCenter',[])
//     runInstanceMethod(notificationCenter, 'removeObserver:', [instance])
// });
//
// fixMethodReplace('MKController', true, 'applicationWillResignActive:', function(instance, originInvocation, originArguments){
//
//     console.log("test:-=-=-=909")
// })

//fixeMethodAfter("ivwen.MPNewVideoDetailViewController", false, "viewWillAppear:", function(instance, originInvocation, originArguments) {
//    var fromPath = runInstanceMethod(instance, "valueForKey:", ["fromPathDic"])
//    var manager = runClassMethod("AppManager", "sharedManager", [])
//    runInstanceMethod(manager, "setFromPathDic:", [fromPath])
//})


//fixInstanceMethodReplace('MPFeedAdViewModel','cellHeight',function(instance, originInvocation, originArguments){
//
//var isRcmdCollectionType = runInstanceWithNoParamter(instance,"isRcmdCollectionType")
//if (isRcmdCollectionType == true) {
//    var deviceWidth = runClassMethod('MPDevice', 'width',[])
//    var imageWidth = (deviceWidth - 15) / 2.0
//    var totalHeight = imageWidth * (2.0 /3.0) + 92
//    return totalHeight
//} else  {
//    return runInvocation(originInvocation)
//}
//});

//fixMethodReplace('MPMineWorksView', false, 'onCellClick:', function(instance, originInvocation, originArguments) {
//    var model0 = originArguments[0]
//    var isArticle = runInstanceMethod(model0, "isKindOfClass:", [runClassMethod("Article", "class", [])])
//    if (isArticle) {
//        var containerId = runInstanceMethod(model0, "containerId", [])
//        var publishModel = runInstanceMethod(model0, "publishModel", [])
//        if (publishModel != null) {
//            var state = runInstanceMethod(publishModel, "state", [])
//            if (state == 0 || state == 1) {
//                runInvocation(originInvocation)
//            } else {
//                runInstanceMethod(model0, "openContentWithContenterId:completion:", [containerId, null])
//            }
//        } else {
//            runInstanceMethod(model0, "openContentWithContenterId:completion:", [containerId, null])
//        }
//    } else {
//        runInvocation(originInvocation)
//    }
//});

//fixMethodReplace("ivwen.MPDiscussionDetailViewController", false, "commentDidScroll:", function(instance, originInvocation, originArguments){
//    console.log("11111111")
//    var topViewHeight = runInstanceMethod(instance, "getTopViewHeight", [])
//    var topicContainer = runInstanceMethod(instance, "topTopicContainerView", [])
//    var topicIsHidden = runClassMethod(topicContainer, "valueForKey:", ["isHidden"])
//    var topicHeight = runInstanceMethod(topicContainer, "height", [])
//    if (topicIsHidden) {
//        topicHeight = 0
//    }
//    var topHeight = topViewHeight - topicHeight - 1
//
//    var scrollView = originArguments[2]
//    var scrollViewContentOffset = runInstanceMethod(scrollView, "contentOffset", [])
//    var y = scrollViewContentOffset.y
//
//    var content = runInstanceMethod(instance, "contentScrollView", [])
//    var contentOffset = runInstanceMethod(content, "contentOffset", [])
//    var contentY = contentOffset.y
//
//    if (contentY < topHeight) {
//        runInstanceMethod(scrollView, "setContentOffset:", [{x:0,y:0}])
//    }
//
//    if (y > 0 && contentY > topHeight) {
//        runInstanceMethod(content, "setContentOffset:",[{x:0, y:topHeight}])
//    }
//    runInstanceMethod(instance, "commentShownNum", [])
//})


//fixMethodReplace("MPAppController", false, "settingOpenWithUri:callback:options:", function(instance, originInvocation, originArguments){
////    console.log("11111111333000000")
////    [MKContext switchViewController:vc animate:YES switchType:MKViewControllerSwitchByPush];
//    var vc = runClassMethod("SettingViewController", "new", [])
//    
//    runClassMethod("MKContext", "switchViewController:animate:switchType:", [vc,true,0])
//    
////    console.log("11111111333")
//})

//fixMethodReplace("MPAppController", false, "settingOpenWithUri:callback:options:", function(instance, originInvocation, originArguments){
//
//    var vc = runClassMethod("SettingViewController", "new", [])
//    
//    runClassMethod("MKContext", "switchViewController:animate:switchType:", [vc,true,0])
//
//})
