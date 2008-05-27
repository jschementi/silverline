// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function disableProblem(dom_id) {
        disableForm(dom_id + "_answer_form")
        disableLink(dom_id + "_request_help_link")
        disableLink(dom_id + "_submit_link")
}
function disableLink(id) {
        if(document.getElementById(id)) {
                $(id).removeAttribute("href")
                $(id).setAttribute("onclick", "return false;")
        }
}
function disableForm(id) {
        var form = document.getElementById(id);
        for (i=0;i<form.elements.length;i++) {
                form.elements[i].disabled = true;
        }
}