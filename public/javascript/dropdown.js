$(document).ready(function() {
  $(".navbar-dropdown").mouseenter((event) => {
    let contentId = "#" + event.currentTarget.id + "-content";
    $(contentId).addClass("show");
  });

  $(".navbar-dropdown").mouseleave((event) => {
    let contentId = "#" + event.currentTarget.id + "-content";
    $(contentId).removeClass("show");
  });
});