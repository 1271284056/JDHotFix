
fixInstanceMethodReplace('MPFeedAdViewModel','cellHeight',function(instance, originInvocation, originArguments){
var isRcmdCollectionType = runInstanceWithNoParamter(instance,"isRcmdCollectionType")
if (isRcmdCollectionType == true) {
    var deviceWidth = runClassMethod('MPDevice', 'width',[])
    var imageWidth = (deviceWidth - 15) / 2.0
    var totalHeight = imageWidth * (2.0 /3.0) + 92
    return totalHeight
} else  {
    return runInvocation(originInvocation)
}
});



fixInstanceMethodReplace('MPLive.MPDiscussionDetailViewController','commentDidScroll:',function(instance, originInvocation, originArguments){
    var _content = runInstanceMethod(instance, 'valueForKey:', ["contentScrollView"])
    if (_content == null) {
        return
    }
    var topHeight = runInstanceMethod(instance, 'getTopViewHeight', [])
    var topTopicContainerViewHeight = 48
    
    var topTopicContainerView = runInstanceMethod(instance, 'valueForKey:', ["topTopicContainerView"])
    var isHidden = runInstanceMethod(topTopicContainerView, 'isHidden', [])
    if (isHidden) {
        topTopicContainerViewHeight = 0
    }
    topHeight = (topHeight - topTopicContainerViewHeight)

    var scrollView = originArguments[0]
    var contentOffset = runInstanceMethod(scrollView, 'contentOffset')
    
    var y = contentOffset.y
    var contentOff = runInstanceMethod(scrollView, '_content')
    var contentY = contentOff.y
     if () {
        
    }
    
    
    fixMethodReplace('MPEditorViewController', false, 'scrollViewDidScroll:', function(instance, originInvocation, originArguments){
        var scrollView = originArguments[0]
        var contentOffset = runInstanceMethod(scrollView, 'contentOffset')
        var offsetY = contentOffset.y
        var keyBoardHasShow = runInstanceMethod(instance, 'keyBoardHasShow')
        if (keyBoardHasShow && offsetY < -20) {
            var webView = runInstanceMethod(instance, 'webView')
            runInstanceMethod(webView, 'resignFirstResponder')
            runInstanceMethod(webView, 'evaluateJavaScript:completionHandler:', ['blur()', null])
        }
    })
    
var isRcmdCollectionType = runInstanceWithNoParamter(instance,"isRcmdCollectionType")
if (isRcmdCollectionType == true) {
    var deviceWidth = runClassMethod('MPDevice', 'width',[])
    var imageWidth = (deviceWidth - 15) / 2.0
    var totalHeight = imageWidth * (2.0 /3.0) + 92
    return totalHeight
} else  {
    return runInvocation(originInvocation)
}
});
