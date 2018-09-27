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
//= require 'blacklight_advanced_search'
//= require blacklight-maps
//= require blacklight/blacklight
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require bootstrap/tab
//= require chosen-jquery
//= require_tree .

Blacklight.onLoad(function() {

    $('select.advanced-search-facet-select').chosen({
        search_contains: true
    });
    $('select#dc-right-select, select#dc-right-select-multiple').chosen({
        allow_single_deselect: true
    });
    $('select#dcterms-type-select-multiple').chosen({
        allow_single_deselect: true
    });
    $('select#holding-institution-ids-select').chosen({
        search_contains: true
    });
    $('select#holding-institution-ids-select-multiple').chosen({
        search_contains: true
    });
    $('select.collection-select').chosen();
    $('select.fancy-multiselect').chosen();
    $('select.fancy-select').chosen({
        allow_single_deselect: true
    });

    $('a.floating-save-button').on('click', function(e) {
        e.preventDefault();
        $(document).find('form').submit();
        return false;
    });

    $('a.form-jump-link').on('click', function() {
        $($(this).href()).focus();
    });

    $('a.select-element-text').on('click', function() {
        selectElementText(document.getElementById($(this).data('container-id')))
    });

    $('.document-tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show')
    })
});

// thx http://stackoverflow.com/a/2838358
function selectElementText(el, win) {
    win = win || window;
    var doc = win.document, sel, range;
    if (win.getSelection && doc.createRange) {
        sel = win.getSelection();
        range = doc.createRange();
        range.selectNodeContents(el);
        sel.removeAllRanges();
        sel.addRange(range);
    } else if (doc.body.createTextRange) {
        range = doc.body.createTextRange();
        range.moveToElementText(el);
        range.select();
    }
}