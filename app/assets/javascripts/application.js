// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
// require_tree .

function toggleTab(tab){

    var tabs = document.getElementsByClassName("tab-active");
    for (var e=0; e < tabs.length; e++){

        document.getElementById(tabs[e].id+"Tab").className="tab-content invisible"
        tabs[e].className = "tab";

    }

    tab.className="tab-active"
    document.getElementById(tab.id+"Tab").classList.remove("invisible")

}

function showModal() {
    // Get the modal
    var modal = document.getElementById('myModal');

    // Get the button that opens the modal


    // When the user clicks the button, open the modal

        modal.style.display = "block";


}

function hideModal(){
    var modal = document.getElementById('myModal');
    modal.style.display = "none";
}