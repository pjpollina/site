function backButton() {
  window.history.back();
  return 0;
}

function updatePostButton() {
  window.location.search += '?edit=true';
  return 0;
}