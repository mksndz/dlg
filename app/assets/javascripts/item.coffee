$(document).on 'ready turbolinks:load', ->
  $(".validation-errors").popover {
    html: true,
    title: 'Validation Errors'
  }
