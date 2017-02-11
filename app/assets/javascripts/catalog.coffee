Blacklight.onLoad ->

  $("a.delete-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    entities = get_checked_items()
    url = $(this).data('url')
    if entities
      return unless window.confirm("Are you sure?")
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
    if entities = get_checked_items()
      url = $(this).data('url') + '.xml' + '?entities=' + entities
      window.location.href = url
  )

  $("a.add-to-batch-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    alert('feature not yet implemented')
#    entities = get_checked_items()
#    url = $(this).data('url')
#    if entities
#      $.ajax url,
#        type: "POST",
#        data:
#          entities: entities,
#        error: (jqXHR, textStatus, errorThrown) ->
#          alert('error')
#        success: (data, textStatus, jqXHR) ->
#          alert('success')
  )

  $("a.select-all-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    $(".action-item").prop('checked', true)
  )

  $("a.deselect-all-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    $(".action-item:checked").prop('checked', false)
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