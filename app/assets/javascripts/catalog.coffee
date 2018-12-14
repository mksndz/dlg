Blacklight.onLoad ->

  $("a.delete-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    entities = get_checked_items()
    console.log('Checked IDs: ' + entities)
    url = $(this).data('url')
    if entities
      count = (entities.match(/,/g) || []).length + 1
      return unless window.confirm("Are you sure you want to delete the " + count + " selected records?")
      $.ajax url,
        type: "DELETE",
        data:
          entities: entities,
        error: (jqXHR, textStatus, errorThrown) ->
          alert('error: ' + textStatus)
        success: (data, textStatus, jqXHR) ->
          alert(count + ' Items destroyed!')
          window.location.reload(true)
  )

  $(".add-to-xml-btn").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    if entities = get_checked_items()
      $form = $('#xml-generator-form')
      $form.append(
        $('<input />')
          .attr('type', 'hidden')
          .attr('name', "entities")
          .attr('value', entities))
      $form.submit()
      return true;
  )

  $("a.add-to-batch-action").on("click", (e, data, status, xhr) ->
    e.preventDefault()
    entities = get_checked_items()
    return false unless entities
    $this = $(this)
    url = $this.attr('href')
    index = url.indexOf('?ids=')
    if index == -1
      new_url = url + '?ids=' + entities
    else
      new_url = url.substring(0,index) + '?ids=' + entities
    $this.attr('href', new_url)
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