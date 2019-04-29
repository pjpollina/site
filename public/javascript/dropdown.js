document.addEventListener("DOMContentLoaded", () => {
  let dropdowns = document.getElementsByClassName("navbar-dropdown");
  for(let i = 0; i < dropdowns.length; i++) {
    dropdowns[i].addEventListener("mouseenter", dropdownMenuEvent);
    dropdowns[i].addEventListener("mouseleave", dropdownMenuEvent);
  }
});

function dropdownMenuEvent(event) {
  let content = document.getElementById(event.currentTarget.id + "-content");
  content.style.display = (event.type == "mouseenter") ? "block" : "none";
}