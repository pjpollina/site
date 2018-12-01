$(document).ready(function() {
  $("#new-post").submit(event => {
    event.preventDefault();
    $.ajax({
      type: "POST",
      url: "new_blog_post",
      data: $("#new-post").serialize(),
      success:function(event) {
        document.location = event;
      }
    });
  });
  return 0;
});