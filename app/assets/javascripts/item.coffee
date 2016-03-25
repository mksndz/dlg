$(document).ready ->
  # todo specify this
  $(".panel-collapse").on("click" , ->
    $('.panel-body').collapse('toggle')
  )