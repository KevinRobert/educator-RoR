$ ->
  $("#test-date").datetimepicker
    format: "YYYY-MM-DD"
    maxDate: new Date()

  # Get grades list when change school
  $("#school-select").change (e) ->
    $.ajax
      type: "POST"
      url: "/admin/schools/get_grades"
      data:
        school_id: $("#school-select option:selected").val()
      success: (data) ->
        # $("#test-section").append "<option value=''>All</option>"
        $("#grade-select").html ""

        for grade in JSON.parse data.grades
          $("#grade-select").append $("<option></option>").val(grade).html(grade)
      error: (data) ->
        $("#grade-select").html ""

  $("#upcoming-tests .view-more").on 'click', () ->
    if $("#upcoming-tests p.hide").length > 0
      for i in [0..$("#upcoming-tests p.hide").length]
        $("#upcoming-tests p.hide:first").removeClass "hide"
        break if i == 4

    if $("#upcoming-tests p.hide").length == 0
      $(this).hide()

  $("#recent-tests .view-more").on 'click', () ->
    if $("#recent-tests p.hide").length > 0
      for i in [0..$("#recent-tests p.hide").length]
        $("#recent-tests p.hide:first").removeClass "hide"
        break if i == 4

    if $("#recent-tests p.hide").length == 0
      $(this).hide()