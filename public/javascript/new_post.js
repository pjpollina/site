$(document).ready(function() {
  init_validator();
  slug_autocomplete();
  handle_body_upload();
  submit_new_post();
  return 0;
});

function init_validator() {
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
}

function slug_autocomplete() {
  if(this.slug_edited === undefined) {
    this.slug_edited = false;
  }

  $("#title").bind('change', () => {
    if(!this.slug_edited) {
      $("#slug").val($("#title").val().replace(/\s/g, '_').toLowerCase());
    }
  });

  $("#slug").bind('change', () => {
    this.slug_edited = true;
  });
}

function handle_body_upload() {
  $("#body-uploader").bind('change', () => {
    let reader = new FileReader();
    reader.readAsText($("#body-uploader").get(0).files[0]);
    $(reader).on('load', (data) => {
      $("#body").val(data.target.result);
    });
  });
}

function submit_new_post() {
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
            $("main").html(data.responseText);
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
}