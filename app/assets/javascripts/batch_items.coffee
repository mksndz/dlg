$(document).ready ->

  $("#xml_form").on("submit" ,(e, data, status, xhr) ->
    e.preventDefault()
    $this = $(this)
    url = this.action
    xml_text_field_data = $("#xml_text").val()
    xml_file_field_data = $("#_xml_file").val()

    if xml_file_field_data and !xml_text_field_data
      handleFileSelect($this, url)
    else if !xml_file_field_data and xml_text_field_data
      process_xml($this, xml_text_field_data, url)
    else
      handle_error('No file or XML text was provided.')
  )

handle_error = (e) ->
  alert(e)

create_record = (url, number, record_node) ->
  return false if !record_node
  return $.ajax url,
    type: "POST",
    data:
      xml_text: record_node.outerHTML,
    error: (jqXHR, textStatus, errorThrown) ->
      $(".progress-bar").addClass('progress-bar-danger')
      $("#results").prepend render_error_output(jqXHR.responseText, number)
    success: (data, textStatus, jqXHR) ->
      $("#results").prepend render_successful_output(data, number)

render_successful_output = (response, num) ->
  return list_item_html num, "Batch Item Successfuly Created",
    "<a href='#{response.edit_url}' target='_blank'>Click here to edit record with slug #{ response.slug }</a>",
    "list-group-item-success"

process_xml = ($this, xml, url) ->
  try $xml_doc = $( $.parseXML(xml) )
  catch e then ->
    handle_error e
    return

  records = $xml_doc.children()[0].children
  if !records
    handle_error('We could not extract any records from the provided XML.')
    return
  $this.slideUp()
  total_records = records.length
  i = 1
  interval = setInterval(
    ->
      if i <= total_records
        create_record(url, i, records[i - 1])
        update_progress_bar(i, total_records)
        i++
      else
        $("#actions").removeClass('hide').fadeIn()
        clearInterval(interval)
  , 250
  )

update_progress_bar = (num, total) ->
  val = (num/total) * 100
  $pb = $(".progress-bar")
  $pb.css('width', val + '%')
  $pb.html("Completed #{num} of #{total}")
  $pb.addClass('progress-bar-success') unless $pb.hasClass('progress-bar-danger') or val < 100

render_error_output = (response, number) ->
  obj = JSON.parse(response)
  error_messages = ''
  for field, msg of obj
    error_messages += field + ' ' + msg
  return list_item_html number, "Record Failed to Import", error_messages, "list-group-item-danger"

list_item_html = (number, title, message, context_class) ->
  return "<li class='list-group-item #{ context_class }'>" +
    "<span class='badge'># #{ number }</span>" +
    "<h4>#{ title }</h4>" +
    "<p>#{ message }</p>" +
  "</li>"

handleFileSelect = ($this, url) ->
  if (!window.File || !window.FileReader || !window.FileList || !window.Blob)
    handle_error('The File APIs are not fully supported in this browser.')
    return
  $input = $this.find('#_xml_file')
  file = $input[0].files[0]
  fr = new FileReader()
  fr.onload = ->
    process_xml($this, fr.result, url)
  fr.readAsText file
