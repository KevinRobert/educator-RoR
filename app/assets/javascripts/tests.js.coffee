# Timeout handler
timer_is_on = false
timer = undefined
time_limit = undefined
test_time_limit = undefined
current_time = 0

parseSeconds = (seconds) ->
  minutes = parseInt seconds / 60, 10
  seconds = parseInt seconds % 60, 10
  minutes = if minutes < 10 then '0' + minutes else minutes
  seconds = if seconds < 10 then '0' + seconds else seconds

  $('.q-ellapse-time').text(minutes + ':' + seconds)

countTime = ->
  if test_time_limit > 0
    if ++current_time >= test_time_limit
      current_time = test_time_limit

      $('#timeout-modal').modal 'show'
      $('#timeout-modal .message-body').text('Time has expired. You didn\'t complete the test within the time.');
      setTimeout((->
        $('#timeout-modal').modal('hide');
      ), 2000)

    parseSeconds test_time_limit - current_time
    $('#test_response_answer_time').val(current_time - parseInt($('#elapsed_time').val()))
  else if time_limit > 0
    if ++current_time >= time_limit
      current_time = time_limit

      $('#timeout-modal').modal 'show'
      setTimeout((->
        $('#timeout-modal').modal('hide');
      ), 2000)

    parseSeconds time_limit - current_time
    $('#test_response_answer_time').val(current_time)
  else
    current_time++
    parseSeconds 0
    $('#test_response_answer_time').val(current_time)

startCountTime = ->
  if !timer_is_on
    timer_is_on = true
    timer = setInterval((->
      countTime()
    ), 1000)

init = ->
  # Choose answer options and set styling
  $('.q-section .q-option').on 'click', (e) ->
    if $('#answer-type').val() == "Single"
      $('.question-answer-checkbox').prop 'checked', false
      $(@).find('.question-answer-checkbox').prop 'checked', true

      $('.q-option').removeClass 'selected'
      $(@).addClass 'selected'

      $('.q-option-index').removeClass 'selected'
      $(@).find('.q-option-index').addClass 'selected'
    else
      $(@).find('.question-answer-checkbox').prop 'checked', !$(@).find('.question-answer-checkbox').prop('checked')
      $(@).toggleClass 'selected'
      $(@).find('.q-option-index').toggleClass 'selected'

  showPauseScreen = ->
    $('.pause-screen').css 
      'display': 'block'

    $('body').css 'overflow', 'hidden'
    $('.q-pause-desc').css 'display', 'block'

  $('.q-pause').click showPauseScreen

  $('.q-resume-btn').click ->
    $('.q-pause-desc').css 'display', 'none'
    $('.pause-screen').css 'display', 'none'

  # Start timer
  time_limit = parseInt $('#timeout').val()
  test_time_limit = parseInt $('#test_timeout').val()
  if test_time_limit > 0
    current_time = parseInt $('#elapsed_time').val()
    parseSeconds test_time_limit - current_time
  else if time_limit > 0
    current_time = 0
    parseSeconds time_limit - current_time
  else 
    current_time = 0
    parseSeconds current_time

  if $('#elapsed_time').length > 0
    startCountTime()

  # pause timer
  $('#pause-test').click ->
    clearInterval timer
    timer_is_on = false

  # resume timer
  $('.q-resume-btn').click ->
    startCountTime()

  # Show prompt message when click Submit button without answer choose
  $('#submit-answer').click ->
    if $('.question-answer-checkbox:checked').length == 0
      $('#choose-answer-modal').modal 'show'
      return false

    if $('#last-question').val() == 'true'
      if $('#all-answered').val() != 'true'
        $('#final-question-modal').modal 'show'
        return false        

  $('#timeout-modal').on 'hidden.bs.modal', (e) ->
    $('#question-form').submit()

  $("#final-question-modal .btn-confirm-yes").on "click", (e) ->
    $('#question-form').submit();

  $('.q-next').on 'click', (e)->
    e.stopPropagation()
    $('#nav-type').val 'next'
    $('#question-form').submit()

  $('.q-prev').on 'click', (e)->
    e.stopPropagation()
    $('#nav-type').val 'prev'
    $('#question-form').submit()
    
  # handle end test
  $('#end-test-modal .btn-confirm-yes').on 'click', (e) ->
    if $('#end-test-form input[name=save]:checked').val() == "yes"
      $('#question-form #test_response_force_end').val true
      $("#question-form").submit()

      e.preventDefault()
      e.stopPropagation()
    else
      $('#question-form #force-end').val false

# Draw line numbers for readign comprehension
drawLineNumber = ->

  if $('.q-reading-desc').length > 0
    divHeight = $('.q-reading-desc').innerHeight()
    lineHeight = parseInt($('.q-reading-desc').css('lineHeight'))
    lines = divHeight / lineHeight
    $('.q-reading-line').html ''
    i = 5

    while i < lines
      top = i * lineHeight
      $('.q-reading-line').append '<span style=\"top:' + top + 'px;\">' + i + '</span>'
      i = i + 5

# Initialize
$(document).ready ->
  init()
  drawLineNumber()

  $('#contact-modal .btn-send').on 'click', ->
    $.ajax
      url: "/tests/contact"
      type: "POST"
      dataType: "json"
      data:
        name: $('#contact-modal #contact-name').val()
        email: $('#contact-modal #contact-email').val()
        message: $('#contact-modal #contact-message').val()
      success: (data) ->
        $('#contact-modal').modal('hide')
      error: (data) ->
        $('#contact-modal .alert').show()
        $('#contact-modal .error-message').text data.responseJSON["errors"]

# When resize the window, draw the line number again
$(window).resize ->
  setTimeout (->
    drawLineNumber()
  ), 200