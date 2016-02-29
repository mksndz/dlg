# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
#  $("#xml_form").on("ajax:success", (e, data, status, xhr) ->
#    $("#results").append render_successful_output(xhr.responseText)
#  ).on "ajax:error", (e, xhr, status, error) ->
#    $("#results").append render_error_output(xhr.responseText)

#    on form submit
#     parse xml from file or field
#     loop thru nodes if >1
#       ajax call to xml_import_batch_batch_items_path
#          update results div with response
#     show buttons when done

  $("#xml_form").on("submit" ,(e, data, status, xhr) ->
    e.preventDefault()
    $.ajax this.action,
      type: this.method,
      data:
        xml_text: $("#xml_text").val(),
      error: (jqXHR, textStatus, errorThrown) ->
        $("#results").append render_error_output(jqXHR.responseText)
      success: (data, textStatus, jqXHR) ->
        $("#results").append render_successful_output(data)
  )


render_successful_output = (response) ->
  return "<div class='bi_new bg-success'>" +
      "<a href='" + response.url + "'>" + response.slug + "</a></div>"

render_error_output = (response) ->
  obj = JSON.parse(response)
  error_messages = ''
  for field, msg of obj
    error_messages += "<span class='err_msg'>" + field + ' ' + msg + "</span>"
  return "<div class='bi_new bg-danger'>" + error_messages + "</div>"