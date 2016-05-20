# Initialize
$(document).ready ->

  # Get sections list when choose School
  $("#test-school").change (e) ->
    $.ajax
      type: "POST"
      url: "/admin/schools/get_sections"
      data:
        school_id: $("#test-school option:selected").val()
      success: (data) ->
        # $("#test-section").append "<option value=''>All</option>"
        $("#school-sections").html ""
        sections = JSON.parse data.sections
        for section in sections
          # $("#test-section").append $("<option></option>").attr("value",section.id).text(section.grade + " - " + section.name)
          str = "<div class='col-md-12'>" + 
                "<input type='checkbox' name='test_section[]' value=" + section.id + ">" +
                section.grade + " - " + section.name + 
                "</input></div>"
          $("#school-sections").append str
      error: (data) ->
        $("#school-sections").html ""

  $("#test-section").change (e) ->
    if $("#test-section option:selected").val() == ""
      $(".test-start-at").addClass "hide"
      $(".test-end-at").addClass "hide"

      $("#test-start-at").val ""
      $("#test-end-at").val ""
    else
      $(".test-start-at").removeClass "hide"
      $(".test-end-at").removeClass "hide"

  $("#test-start-at").datetimepicker
    format: "YYYY-MM-DD hh:mm A"
  $("#test-end-at").datetimepicker 
    format: "YYYY-MM-DD hh:mm A"
    useCurrent: false

  $("#test-start-at").on "dp.change", (e) ->
    $("#test-end-at").data("DateTimePicker").minDate e.date

  $("#test-end-at").on "dp.change", (e) ->
    $("#test-start-at").data("DateTimePicker").maxDate e.date

 # show/hide topic dropdown
  validate_topic = () ->
    if $('#test-form #test_syllabus option:selected').val() == null
      $('#test-form #test_topic').hide()
    else
      $('#test-form #test_topic').show()

  # call ajax method in order to update test topic list
  update_test_topic = () ->
    validate_topic()

    syllabus = $('#test-form #test_syllabus option:selected').val()
    if syllabus == null
      $('#test-form #test_topic').html ''
      return

    $.ajax
      type: "POST"
      url: "/admin/tests/get_topics"
      data:
        syllabus: syllabus
        grade: $('#test-form #test_grade option:selected').val()
        subject: $('#test-form #test_subject option:selected').val()
      success: (data) ->
        # $("#test-section").append "<option value=''>All</option>"
        $('#test-form #test_topic').html ''

        for topic in JSON.parse data.topics
          $('#test-form #test_topic').append $('<option></option>').val(topic.topic).html(topic.topic)
      error: (data) ->
        $('#test-form #test_topic').html ''

  validate_topic()

  $('#test-form #test_syllabus').on 'change', (e) ->
    update_test_topic()

  $('#test-form #test_subject').on 'change', (e) ->
    update_test_topic()

  $('#test-form #test_grade').on 'change', (e) ->
    update_test_topic()    