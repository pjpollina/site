document.addEventListener("DOMContentLoaded", () => {
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
  let uploader = document.getElementById("body-uploader");
  uploader.addEventListener("change", () => {
    let reader = new FileReader();
    reader.readAsText(uploader.files[0]);
    reader.onload = function(data) {
      document.getElementById("body").value = data.target.result;
    };
  });
}

function submit_new_post() {
  let form = document.getElementById("new-post");
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    let ajax = new XMLHttpRequest();
    ajax.open(form.getAttribute("method"), form.getAttribute("action"), true);
    ajax.onload = function() {
      switch(ajax.status) {
        case 200:
          document.location = "/" + ajax.responseText;
          break;
        default:
          alert("An unknown error has occured");
          break;
      }
    }
    ajax.send(new URLSearchParams(new FormData(form)).toString());
  });
}