$(document).ready(function() {
  $.validator.addMethod("regex", function(value, element, regex) {
    return this.optional(element) || new RegExp(regex).test(value);
  });

  $("#new-post").validate({
    errorClass: "error",
    onkeyup: false,
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

  $("#new-post").bind('blur click', () => {
    if($("#new-post").validate().checkForm()) {
      $("#submit").prop('disabled', false);
    } else {
      $("#submit").prop('disabled', true);
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
        switch(data.status) {
          case 403:
            document.location = '/error_403';
            break;
          case 409:
            alert(data.responseText);
            break;
          default:
            alert('An unknown error occured');
            break;
        }
      }
    });
  });
  return 0;
});