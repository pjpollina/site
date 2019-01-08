$(document).ready(function() {
  $("#edit-post").submit(event => {
    let url = window.location.href.split('?')[0];
    event.preventDefault();
    $.ajax({
      type: "PUT",
      url: url,
      data: $("#edit-post").serialize(),
      success:function(data) {
        document.location = url;
      },
      error:function(data) {
        document.location = '/error_403';
      }
    });
  });

  $("#delete-post").click(event => {
    event.preventDefault();
    if(!confirm("Are you sure?")) {
      return 0;
    }
    $.ajax({
      type: "DELETE",
      url: window.location.href.split('?')[0],
      data: $("#edit-post").serialize(),
      success:function(data) {
        document.location = '/';
      },
      error:function(data) {
        document.location = '/error_403';
      }
    });
  });
});