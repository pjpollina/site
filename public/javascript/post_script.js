$("new-post").submit(event => {
  event.preventDefault();
  $.ajax({
    type: "POST",
    url: "new_blog_post",
    data: this.serialize
  });
});