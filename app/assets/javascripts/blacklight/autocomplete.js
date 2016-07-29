/*global Bloodhound */

$(document).on('ready turbolinks:load', function() {

    $('[data-autocomplete-enabled="true"]').each(function() {
        var $el = $(this);
        var suggestUrl = $el.data().autocompletePath;

        var terms = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            remote: {
                url: suggestUrl + '?q=%QUERY',
                wildcard: '%QUERY'
            }
        });

        terms.initialize();

        $el.typeahead({
                hint: true,
                highlight: true,
                minLength: 5
            },
            {
                name: 'terms',
                displayKey: 'term',
                source: terms.ttAdapter()
            });
    });

});

