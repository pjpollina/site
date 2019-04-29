$(document).ready(function() {
  function errorCallback(data) {
    $("main").html(data.responseText);
  }
  sendPostUpdate();
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

function sendPostUpdate() {
  let url = window.location.href.split('?')[0];
  let form = document.getElementById("edit-post");
  form.addEventListener("submit", event => {
    event.preventDefault();
    let ajax = new XMLHttpRequest();
    ajax.open("PUT", url, true);
    ajax.onload = function() {
      switch(ajax.status) {
        case 200:
          document.location = url;
          break;
        default:
          alert("An unknown error has occured");
          break;
      }
    };
    ajax.send(new URLSearchParams(new FormData(form)).toString());
  });
}