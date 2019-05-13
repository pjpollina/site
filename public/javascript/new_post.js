document.addEventListener("DOMContentLoaded", () => {
  slugAutoFill();
  handleBodyUpload();
  submitNewPost();
});

function slugAutoFill() {
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

function handleBodyUpload() {
  let uploader = document.getElementById("body-uploader");
  uploader.addEventListener("change", () => {
    let reader = new FileReader();
    reader.readAsText(uploader.files[0]);
    reader.onload = function(data) {
      document.getElementById("body").value = data.target.result;
    };
  });
}

function submitNewPost() {
  let form = document.getElementById("new-post");
  form.addEventListener("submit", event => {
    event.preventDefault();
    let ajax = new XMLHttpRequest();
    ajax.open(form.getAttribute("method"), form.getAttribute("action"), true);
    ajax.onload = function() {
      if(ajax.status == 201) {
        document.location = "/" + ajax.responseText;
      } else {
        if(ajax.responseText === "") {
          alert("An unknown error has occured");
        } else {
          alert(ajax.responseText);
        }
      }
    }
    ajax.send(new URLSearchParams(new FormData(form)).toString());
  });
}