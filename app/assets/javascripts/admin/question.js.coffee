$ ->
  $('.school-disable-link').bind 'ajax:success', (e, data, status, xhr) ->
    $(this).text (if $(this).text() is "Enable" then "Disable" else "Enable")

  $('.user-disable-link').bind 'ajax:success', ->
    $(this).text (if $(this).text() is "Enable" then "Disable" else "Enable")

  # Show/Hide Description fields for for answer type
  $('#question_answer_type').change () ->
    if $('#question_answer_type option:selected').val() == 'RC'
      $("#question_description_title").parents(".form-group").show()
      $("#question_description").parents(".form-group").show()
    else
      $("#question_description_title").parents(".form-group").hide()
      $("#question_description").parents(".form-group").hide()

  readURL = (input) ->
    if input.files && input.files[0]
      reader = new FileReader();

      reader.onload = (e) ->
        $(".question-image").attr "src", e.target.result;

      reader.readAsDataURL(input.files[0]);

  $("#question-image-input").change () ->
    readURL(this);

  # Set position property to question rows
  # set_question_positions = ->
  #   $("#questions-table tbody tr").each (i) ->
  #     $(this).attr "data-pos", i + 1
  #     $(this).find("td:first").text i + 1

  # set_question_positions()

  # Initialize sortable tables
  # temporarily remove this code 
  # $("#questions-table").sortable
  #   containerSelector: "table"
  #   itemPath: "> tbody"
  #   itemSelector: "tr"
  #   placeholder: "<tr class=\"placeholder\"/>"
  #   onDrop: ($item, container, _super) ->
  #     # array to store new order
  #     updated_order = []
      
  #     # set the updated positions
  #     set_question_positions()

  #     # populate the updated_order array with the new task positions
  #     $("#questions-table tbody tr").each (i) ->
  #       updated_order.push
  #         id: $(this).data("id")
  #         position: $(this).data("pos")
      
  #     # send the updated order via ajax
  #     $.ajax
  #       type: "POST"
  #       url: "/admin/questions/sort"
  #       data:
  #         order: updated_order

  #     _super $item, container

  # select all questions
  $('#questions-table #select_all').change () ->
    if this.checked
      $('.available-questions').attr 'checked', true
    else
      $('.available-questions').attr 'checked', false

  $('#q-create-syllabus').selectpicker {}
  $('#q-create-concepts').selectpicker {}
  $('#q-create-type').selectpicker {}

  # selected_filter_type = '';
  # if $("#selected_filter_type").length > 0
  #   selected_filter_type = $("#selected_filter_type").val();
  # $("#q-filter-type").selectpicker "val", selected_filter_type.split(",")

  # Set question type as selected
  selected_question_type = ''
  if $('#selected_question_type').length > 0
    selected_question_type = $('#selected_question_type').val().split(', ')

  $('#q-create-type').selectpicker 'val', selected_question_type

  # Set question syllabus as selected
  selected_syllabus = ''
  if $('#selected_syllabus').length > 0
    selected_syllabus = $('#selected_syllabus').val().split(', ')
  $('#q-create-syllabus').selectpicker 'val', selected_syllabus

  # Set question concepts as selected
  selected_concepts = ''
  if $('#selected_concepts').length > 0
    selected_concepts = $('#selected_concepts').val().split(', ')
  $('#q-create-concepts').selectpicker 'val', selected_concepts

  # show/hide topic dropdown
  validate_topic = () ->
    if $('#q-create-syllabus').selectpicker('val') == null || $('#q-create-subject')   == null || $('#q-create-grade').selectpicker('val') == null
      $('#question-form #question_topic').hide()
    else
      $('#question-form #question_topic').show()

  # call ajax method in order to update question topic list
  update_question_topic = () ->
    validate_topic()
    
    $('#question-form #q-create-concepts').html ''
    $('#question-form #q-create-concepts').siblings().eq(1).children('ul').html ''              
    $('#question-form #q-create-concepts').siblings().eq(0).children('span.filter-option').html 'Choose multi concepts'         

    syllabus = $('#question-form #q-create-syllabus').selectpicker 'val'  
    
    if syllabus == null
      $('#question-form #question_topic').html ''
      return

    $.ajax
      type: "POST"
      url: "/admin/questions/get_topics"
      data:
        syllabus: syllabus
        grade: $('#question-form #question_grade option:selected').val()
        subject: $('#question-form #question_subject option:selected').val()
      success: (data) ->
        # $("#test-section").append "<option value=''>All</option>"
        $('#question-form #question_topic').html ''        
        for topic in JSON.parse data.topics
          $('#question-form #question_topic').append $('<option></option>').val(topic.topic).html(topic.topic)
        update_question_concepts()    
      error: (data) ->
        $('#question-form #question_topic').html ''

  validate_topic()

  $('#q-create-syllabus').on 'hide.bs.select', (e) ->
    update_question_topic()

  $('#question-form #question_subject').on 'change', (e) ->
    update_question_topic()

  $('#question-form #question_grade').on 'change', (e) ->
    update_question_topic()



# show/hide concepts dropdown
  validate_concepts = () ->
    if $('#q-create-syllabus').selectpicker('val') == null || $('#q-create-subject').selectpicker('val') == null || $('#q-create-grade').selectpicker('val') == null || $('#q-create-topic').selectpicker('val')
      $('#question-form #question_concepts').hide()
    else
      $('#question-form #q-create-concepts').show()

  # call ajax method in order to update question concepts list
  update_question_concepts = () ->
    validate_concepts()

    $('#question-form #q-create-concepts').html ''
    $('#question-form #q-create-concepts').siblings().eq(1).children('ul').html ''              
    $('#question-form #q-create-concepts').siblings().eq(0).children('span.filter-option').html 'Choose multi concepts'  
    
    syllabus = $('#question-form #q-create-syllabus').selectpicker 'val'
    if syllabus == null
      $('#question-form #question_concepts').html ''
      return
    $.ajax
      type: "POST"
      url: "/admin/questions/get_concepts"
      data:
        syllabus: syllabus
        grade: $('#question-form #question_grade option:selected').val()
        subject: $('#question-form #question_subject option:selected').val()
        topic: $('#question-form #question_topic option:selected').val()
      success: (data) ->
        # $("#test-section").append "<option value=''>All</option>"
        question_concept = $('#question-form #q-create-concepts').siblings().eq(1).children('ul')
        
       
        for concepts,index in JSON.parse data.concepts
          $('#question-form #q-create-concepts').append $('<option></option>').val(concepts.concept).html(concepts.concept)            
          question_concept.append $('<li data-original-index='+question_concept.children('li').length+'></li>').html('<a tabindex="0" class="" style="" data-tokens="null"><span class="text">'+ concepts.concept+'</span><span class="glyphicon glyphicon-ok check-mark"></span></a>')
            
        $('#question-form #q-create-concepts').siblings().eq(1).children('ul').eq(0).children('li').click ()->      
            if $(this).hasClass('selected') 
                $(this).removeClass('selected') 
            else    
                $(this).addClass('selected')
                
      error: (data) ->
        $('#question-form #question_concepts').html ''


  validate_concepts()

  $('#question-form #question_topic').on 'change', (e) ->
    update_question_concepts()

  