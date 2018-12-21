$(document).ready(function() {
  $("#edit-post").submit(event => {
    event.preventDefault();
    $.ajax({
      type: "PUT",
      url: window.location.href.split('?')[0],
      data: $("#edit-post").serialize(),
      success:function(data) {
        document.location = data;
      },
      error:function(data) {
        let errors = JSON.parse(data.responseText);
        alert(errors);
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
        let errors = JSON.parse(data.responseText);
        alert(errors);
      }
    });
  });
});