$(document).ready(function() {
  $("#new-post").submit(event => {
    event.preventDefault();
    $.ajax({
      type: "POST",
      url: "new_blog_post",
      data: $("#new-post").serialize(),
      success:function(data) {
        document.location = data;
      },
      error:function(data) {
        let errors = JSON.parse(data.responseText);
        if(errors.title != null) {
          alert(errors.title)
        }
        if(errors.slug != null) {
          alert(errors.slug)
        }
        if(errors.password != null) {
          alert(errors.password);
        }
      }
    });
  });
  return 0;
});