document.addEventListener("DOMContentLoaded", () => {
  sendPostUpdate();
  sendPostDelete();
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

function sendPostDelete() {
  let url = window.location.href.split('?')[0];
  let form = document.getElementById("edit-post");
  let deleter = document.getElementById("delete-post");
  deleter.addEventListener("click", event => {
    event.preventDefault();
    if(!confirm("Are you sure?")) {
      return;
    }
    let ajax = new XMLHttpRequest();
    ajax.open("DELETE", url, true);
    ajax.onload = function() {
      switch(ajax.status) {
        case 200:
          document.location = "/";
          break;
        default:
          alert("An unknown error has occured");
          break;
      }
    };
    ajax.send(new URLSearchParams(new FormData(form)).toString());
  });
}