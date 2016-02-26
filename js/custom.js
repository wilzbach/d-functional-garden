jQuery(function($) {
  var $bodyEl = $('body'),
      $sidedrawerEl = $('#sidedrawer');


  function showSidedrawer() {
    // show overlay
    var options = {
      onclose: function() {
        $sidedrawerEl
          .removeClass('active')
          .appendTo(document.body);
      }
    };

    var $overlayEl = $(mui.overlay('on', options));

    // show element
    $sidedrawerEl.appendTo($overlayEl);
    setTimeout(function() {
      $sidedrawerEl.addClass('active');
    }, 20);
  }


  function hideSidedrawer() {
    $bodyEl.toggleClass('hide-sidedrawer');
  }


  $('.js-show-sidedrawer').on('click', showSidedrawer);
  $('.js-hide-sidedrawer').on('click', hideSidedrawer);

  // get menu clicks
    $(function(){
        $(document).on('click','a',function(){
            var id = $(this).attr('id');
            menuItems.parent().removeClass("active")
            $(this).addClass("active");
        })
    })
    var topMenu = $("#sidedrawer-list"),
    topOffset = $("header").outerHeight(),
    // All list items
    menuItems = topMenu.find("a"),
    // Anchors corresponding to menu items
    scrollItems = menuItems.map(function(){
      var item = $($(this).attr("href"));
      if (item.length) { return item; }
    });

    // Bind to scroll
    $(window).scroll(function(){
       // Get container scroll position
       var fromTop = $(this).scrollTop();
    
       // Get id of current scroll item
       var curDist = 100000;
       var cur = this;
       scrollItems.each(function(i, el){
        var newDist = el.offset().top - fromTop;
         if (newDist < curDist && newDist >= 0){
             curDist = newDist;
             cur = el;
         }
       });
       // Get the id of the current element
       var id = cur && cur.length ? cur[0].id : "";
       // Set/remove active class
       menuItems
         .parent().removeClass("active")
         .end().filter("[href='#"+id+"']").parent().addClass("active");
    });

});
