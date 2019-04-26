$(document).ready(function() {
  slug_autocomplete();
  handle_body_upload();
  submit_new_post();
  return 0;
});

function slug_autocomplete() {
  if(this.slug_edited === undefined) {
    this.slug_edited = false;
  }
  let title = document.getElementById("title");
  let slug = document.getElementById("slug");
  title.addEventListener("change", () => {
    if(!this.slug_edited) {
      slug.value = title.value.replace(/\s/g, '_').toLowerCase();
    }
  });
  slug.addEventListener("change", () => {
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