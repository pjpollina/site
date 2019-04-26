function validate(element) {
  let input = element.value;
  let error = document.getElementById(element.id + "-error");
  error.innerHTML = "";
  error.style.display = "none";
  if(element.required && !input.length) {
    error.style.display = "flex";
    error.innerHTML = "Field cannot be blank";
  }
  if(element.hasAttribute("unique") && input.length) {
    let ajax = new XMLHttpRequest();
    ajax.open("GET", "/validate?" + element.id + "=" + encodeURI(input), true);
    ajax.onload = function() {
      if(ajax.responseText === 'false') {
        error.style.display = "flex";
        error.innerHTML = "Requested input already in use";
      }
    }
    ajax.send();
  }
  if(element.hasAttribute("regexp") && input.length) {
    let regexp = new RegExp(element.getAttribute("regexp"));
    if(!regexp.test(input)) {
      error.style.display = "flex";
      error.innerHTML = "Illegal formatting";
    }
  }
  submitCheck();
}

function submitCheck() {
  let submit = document.getElementById("submit");
  let fields = document.getElementsByClassName("error");
  for(let i = 0; i < fields.length; i++) {
    if(fields[i].innerHTML.length) {
      submit.disabled = true;
      return;
    }
  }
  submit.disabled = false;
}