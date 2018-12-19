$(document).ready(function() {
  $.validator.addMethod("regex", function(value, element, regex) {
    return this.optional(element) || new RegExp(regex).test(value);
  });

  $("#new-post").validate({
    errorClass: "error",
    rules: {
      title: {
        remote: "/validate"
      },
      slug: {
        regex: /^[A-Za-z0-9]+(?:[A-Za-z0-9_-]+[A-Za-z0-9]){0,255}$/,
        remote: "/validate"
      }
    },
    messages: {
      title: {
        remote: "Title already in use!"
      },
      slug: {
        regex: "Slug is invalid!",
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