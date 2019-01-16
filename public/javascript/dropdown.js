$(document).ready(function() {
  $(".navbar-dropdown").on("mouseenter mouseleave", (event) => {
    let contentId = "#" + event.currentTarget.id + "-content";
    let displayType = (event.type == "mouseenter") ? "block" : "none";
    $(contentId).css({"display": displayType});
  });
});