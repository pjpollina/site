$(document).ready(function() {
  $(".navbar-dropdown").mouseenter((event) => {
    let contentId = "#" + event.currentTarget.id + "-content";
    $(contentId).css({"display": "block"});
  });

  $(".navbar-dropdown").mouseleave((event) => {
    let contentId = "#" + event.currentTarget.id + "-content";
    $(contentId).css({"display": "none"});
  });
});