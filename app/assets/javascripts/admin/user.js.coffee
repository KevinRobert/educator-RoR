# Initialize
$(document).ready () ->
  show_grade_section = () ->
    $("#edit-user-form #user_grade").parents(".form-group").show()
    $("#edit-user-form #user_section_id").parents(".form-group").show()

  hide_grade_section = () ->
    $("#edit-user-form #user_grade").parents(".form-group").hide()
    $("#edit-user-form #user_section_id").parents(".form-group").hide()

  if $("#edit-user-form #user_role").val() == "student"
    show_grade_section()
  else
    hide_grade_section()

  # show/hide Grade and School select box
  $("#edit-user-form #user_role").change (e) ->
    if $("#edit-user-form #user_role").val() == "student"
      show_grade_section()
    else
      hide_grade_section()


  # show/hide section dropdown
  validate_section_id = () ->
    if $('#edit-user-form #user_grade option:selected').val() == null
      $('#edit-user-form #user_section_id').parents(".form-group").hide()
    else
      $('#edit-user-form #user_section_id').parents(".form-group").show()

  # call ajax method in order to update user section list
  update_user_section_id = () ->
    validate_section_id()

    school_id = ''
    if $('#edit-user-form #user_school_id option').length > 0
      school_id = $('#edit-user-form #user_school_id option:selected').val()
    else
      school_id = $('#edit-user-form #school_name').data('id')

    $.ajax
      type: "POST"
      url: "/admin/users/get_sections"
      data:
        school: school_id
        grade: $('#edit-user-form #user_grade option:selected').val()
      success: (data) ->
        # $("#user_section_id").append "<option value=''>All</option>"
        $('#edit-user-form #user_section_id').html ''

        for section in JSON.parse data.sections
          $('#edit-user-form #user_section_id').append $('<option></option>').val(section.id).html(section.name)
      error: (data) ->
        $('#edit-user-form #user_section_id').html ''

  validate_section_id()

  $('#edit-user-form #user_school_id').on 'change', (e) ->
    update_user_section_id()

  $('#edit-user-form #user_grade').on 'change', (e) ->
    update_user_section_id()   
