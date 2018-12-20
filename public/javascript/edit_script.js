$(document).ready(function() {
  $("#edit-post").submit(event => {
    event.preventDefault();
    $.ajax({
      type: "PUT",
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
});