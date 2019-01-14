$(document).ready(function() {
  function errorCallback(data) {
    $("main").html(data.responseText);
  } 

  $("#edit-post").submit(event => {
    let url = window.location.href.split('?')[0];
    event.preventDefault();
    $.ajax({
      type: "PUT",
      url: url,
      data: $("#edit-post").serialize(),
      success:() => document.location = url,
      error:(data) => errorCallback(data)
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
      success:() => document.location = '/',
      error:(data) => errorCallback(data)
    });
  });
});