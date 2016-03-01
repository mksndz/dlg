$(document).ready ->

  $("#xml_form").on("submit" ,(e, data, status, xhr) ->
    e.preventDefault()
    $this = $(this)
    $this.slideUp()
    url = this.action
    xml_text_field_data = $("#xml_text").val()
    # todo  xml_file_field_data = $("#xml_file").val()
    # if file, take contents and assign to xml_text_field_data
    $xml_doc = $( $.parseXML(xml_text_field_data) )
    records = $xml_doc.children()[0].children
    if !records
      return
    i = 1
    interval = setInterval(
      ->
        if i <= records.length
          create_record(url, i, records[i - 1])
          i++
        else
          $("#actions").removeClass('hide').fadeIn()
          clearInterval(interval)
      , 250
    )
  )

create_record = (url, number, record_node) ->
  return false if !record_node
  return $.ajax url,
    type: "POST",
    data:
      xml_text: record_node.outerHTML,
    error: (jqXHR, textStatus, errorThrown) ->
      $("#results").append render_error_output(jqXHR.responseText, number)
    success: (data, textStatus, jqXHR) ->
      $("#results").append render_successful_output(data, number)

render_successful_output = (response, num) ->
  return list_item_html num, "Batch Item Successfuly Created",
    "<a href='#{response.edit_url}' target='_blank'>Click here to edit record with slug #{ response.slug }</a>",
    "list-group-item-success"

render_error_output = (response, number) ->
  obj = JSON.parse(response)
  error_messages = ''
  for field, msg of obj
    error_messages += field + ' ' + msg
  return list_item_html number, "Record Failed to Import", error_messages, "list-group-item-danger"

list_item_html = (number, title, message, context_class) ->
  return "<li class='list-group-item #{ context_class }'>" +
    "<span class='badge'>#{ number }</span>" +
    "<h4>#{ title }</h4>" +
    "<p>#{ message }</p>" +
  "</li>"