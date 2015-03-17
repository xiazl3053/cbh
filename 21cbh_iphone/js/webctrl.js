/*---------------------字体控制相关代码开始----------------------*/
//控制字体小号
function smallFont() {
    ts('article-text', 15)
}
//控制字体中号
function middleFont() {
    ts('article-text', 17)
}
//控制字体大号
function largeFont() {
    ts('article-text', 21)
}

function ts(trgt, sz) {
    var tgs = new Array('div','p','td');
    var cEl = null,
    i, j, cTags;
    if (! (cEl = document.getElementById(trgt))) {
        cEl = document.getElementsByTagName(trgt)[0];
    }
    cEl.style.fontSize = sz+'px';
    for (i = 0; i < tgs.length; i++) {
        cTags = cEl.getElementsByTagName(tgs[i]);
        for (j = 0; j < cTags.length; j++) cTags[j].style.fontSize = sz+'px';
    }
}

/*---------------------阅读模式控制相关代码开始----------------------*/
function nightMode() {
    $("#linkcss").attr('href','css/article_night.css');
}

function normalMode() {
    $("#linkcss").attr('href','css/article.css');
}

/*---------------------页面滚动控制开始----------------------*/
//window.addEventListener('load',
//function() {
//    var windowH = window.innerHeight,
//    imagePositionY = [],
//    imageElements = document.querySelectorAll('.lazy');
//
//    [].forEach.call(imageElements,
//    function(val) {
//        imagePositionY.push(val.offsetTop + val.height);
//    });
//
//    function scrollEvent() {
//        window.removeEventListener('scroll', scrollEvent);
//        var pageY = windowH + window.scrollY + 80;
//        imagePositionY.forEach(function(val, index) {
//            if (pageY >= val && imageElements[index].className.indexOf('show') === -1) {
//                imageElements[index].className += ' show';
//            }
//        });
//        setTimeout(function() {
//            window.addEventListener('scroll', scrollEvent, false);
//        },
//        500);
//    }
//
//    window.addEventListener('scroll', scrollEvent, false);
//
//    // init
//    scrollEvent();
//
//},
//false);


//页面滚动到某元素
function scrollToPosition(id) {
	var offset = arguments[1] || 100;
	window.scroll(0 , document.getElementById(id).offsetTop - offset);
}

/*---------------------投票控制开始----------------------*/
$(function($) {
    var $voteOpts = $('.vote-c'),
    $voteOptsChildren = $voteOpts.find('li'),
    $voteRlts = $('.vote-s'),
    $voteRltsChildren = $voteRlts.find('li'),
    url = 'http://baidu.com';
    $voteOptsChildren.on('click',
    function(e) {
        // 获取点击选项的位置
        var index = $(this).index();

        $voteRltsChildren.eq(index).children().find('.v-opt').append('<span class="voted-s">已投票</span>');
        $voteOpts.hide();
        $voteRlts.show();

        $voteRltsChildren.each(function() {
            var num = parseInt($(this).find('.num').html());
            $(this).find('.barW').css('left', num - 100 + '%');
        })
        $("#vote-lo").hide();
        // 向服务器提交请求
        var img = new Image();
        img.src = url + '?vi=001&vt=' + index;
    });

    $("#vote-lo").on('click', function() {
        $(this).hide();
        $voteOpts.hide();
        $voteRlts.show();
        $voteRltsChildren.each(function() {
            var num = parseInt($(this).find('.num').html());
            $(this).find('.barW').css('left', num - 100 + '%');
        })
    });
});


/*--点赞--*/
function do_up(){
    var contentid=$("#dp_up").attr('dataid');  
    $.getScript("http://www.21cbh.com/dynamic/index.php?c=mobileapp&m=setVal&type=digg&contentid="+contentid, function(){
        var oldNum=parseInt($("#dp_up").find('i').text());
        oldNum++;
        $("#dp_up").find('i').text(oldNum);
    });               
}
/*--踩--*/
function do_down(){
    var contentid=$("#dp_down").attr('dataid');
    $.getScript("http://www.21cbh.com/dynamic/index.php?c=mobileapp&m=setVal&type=tread&contentid="+contentid, function(){
        var oldNum=parseInt($("#dp_down").find('i').text());
        oldNum++;
        $("#dp_down").find('i').text(oldNum);
    });
}