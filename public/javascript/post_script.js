$(document).ready(function() {
  $("#new-post").validate({
    errorClass: "error",
    rules: {
      title: {
        remote: "/validate"
      },
      slug: {
        remote: "/validate"
      }
    },
    messages: {
      title: {
        remote: "Title already in use!"
      },
      slug: {
        remote: "Slug already in use!"
      }
    }
  });

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
        if(errors.password != null) {
          alert(errors.password);
        }
      }
    });
  });
  return 0;
});