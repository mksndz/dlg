$(document).ready ->

  $("a.delete-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    return unless window.confirm("Are you sure?")
    entities = get_checked_items()
    url = $(this).data('url')
    if entities
      $.ajax url,
        type: "DELETE",
        data:
          entities: entities,
        error: (jqXHR, textStatus, errorThrown) ->
          alert('error')
        success: (data, textStatus, jqXHR) ->
          alert('Items destroyed!')
          window.location.reload(true)
  )

  $("a.add-to-xml-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    entities = get_checked_items()
    url = $(this).data('url')
    if entities
      $.ajax url,
        type: "GET",
        data:
          entities: entities,
        error: (jqXHR, textStatus, errorThrown) ->
          alert('arror')
        success: (data, textStatus, jqXHR) ->
          alert('success')
  )

  $("a.add-to-batch-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    entities = get_checked_items()
    url = $(this).data('url')
    if entities
      $.ajax url,
        type: "POST",
        data:
          entities: entities,
        error: (jqXHR, textStatus, errorThrown) ->
          alert('arror')
        success: (data, textStatus, jqXHR) ->
          alert('success')
  )

get_checked_items = ->
  checkedArray = []
  $(".action-item:checked").each( ->
    checkedArray.push($(this).val())
  )
  unless checkedArray.length > 0
    alert("Please select at least one record to perform this action")
    return false
  return checkedArray.join(',')