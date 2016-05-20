$ ->
  headers = $('#accordion .accordion-header')
  contentAreas = $('#accordion .ui-accordion-content ').hide()

  # add the accordion functionality
  headers.click () ->
    panel = $(this).next();
    isOpen = panel.is(':visible');
 
    # open or close as necessary
    panel[if isOpen then 'slideUp' else 'slideDown']().trigger if isOpen then 'hide' else 'show'

    # stop the link from causing a pagescroll
    return false

  # when panels open or close, check to see if they're all open
  contentAreas.on () ->
    # whenever we open a panel, check to see if they're all open
    # if all open, swap the button to collapser
    show: () ->
      isAllOpen = !contentAreas.is(':hidden')
      if isAllOpen
        expandLink.text('Collapse All').data 'isAllOpen', true
    # whenever we close a panel, check to see if they're all open
    # if not all open, swap the button to expander
    hide: () ->
      isAllOpen = !contentAreas.is(':hidden')
      if !isAllOpen
        expandLink.text('Expand all').data 'isAllOpen', false

$(document).ready () ->
  
  if $('.topic-charts').length > 0
    #
    # Draw charts by question topic or subject
    #
    topic_charts = $(".topic-charts .chart-section")
    topic_data = JSON.parse $("#available_charts").val()

    topic_charts.each (i, chart_obj) ->

      chart_id = $(chart_obj).attr 'id'

      $('#' + chart_id).highcharts
        chart:
          plotBackgroundColor: null
          plotBorderWidth: null
          plotShadow: false
          type: 'pie'
        title: 
          text: topic_data[i].item
          style:
            fontSize: '15px'
        tooltip: 
          pointFormat: 'Count: <b>{point.y}</b>'
        plotOptions: pie:
          cursor: 'pointer'
          dataLabels: 
            enabled: false
          showInLegend: true
        legend:
          enabled: true
          useHTML: true
          verticalAlign: 'bottom'
          labelFormatter: () ->
            '<span style="margin-right: 5px">' + this.name + '</span><span style="margin-right: 5px">' + this.y + '</span>'
        credits:
          enabled: false
        series: [{
          colorByPoint: true
          data: [
            {
              name: 'Correct'
              y: topic_data[i].correct
            }
            {
              name: 'Wrong'
              y: topic_data[i].wrong
            }
          ]
        }]

    #
    # Draw charts by question type
    #
    type_charts = $(".type-charts .chart-section")
    type_data = JSON.parse $("#available_types").val()

    type_charts.each (i, chart_obj) ->

      chart_id = $(chart_obj).attr 'id'

      $('#' + chart_id).highcharts
        chart:
          type: 'column'
        title:
          text: type_data[i].type
        xAxis:
          type: 'category'
        yAxis:
          allowDecimals: false
          title:
            text: 'Number of answers'
        legend:
          enabled: false
        credits:
          enabled: false
        plotOptions:
          series:
            borderWidth: 0
            dataLabels:
              enabled: true
              format: '{point.y}'
        tooltip:
          pointFormat: '<span>{point.name}</span>: <b>{point.y}</b>'
        series: [{
          colorByPoint: true
          data: [
            {
              name: 'Correct'
              y: type_data[i].correct
            }
            {
              name: 'Wrong'
              y: type_data[i].wrong
            }
          ]
        }]

    #
    # Draw charts by question difficulty
    #
    difficulty_charts = $(".difficulty-charts .chart-section")
    difficulty_data = JSON.parse $("#available_difficulties").val()

    difficulty_charts.each (i, chart_obj) ->

      chart_id = $(chart_obj).attr 'id'

      $('#' + chart_id).highcharts
        chart:
          type: 'bar'
        title:
          text: difficulty_data[i].difficulty
        xAxis:
          categories: ['Correct', 'Wrong']
          title:
            text: null
        yAxis:
          min: 0
          allowDecimals: false
          title:
            text: 'Number of answers'
            align: 'high'
          labels:
            overflow: 'justify'
        legend:
          layout: 'vertical'
          algin: 'right'
          verticalAlign: 'top'
          floating: true
          borderWidth: 1
          enabled: false
        credits:
          enabled: false
        plotOptions:
          bar:
            dataLabels:
              enabled: true
        tooltip:
          pointFormat: '<span>{point.name}</span>: <b>{point.y}</b>'
        series: [{
          name: 'Correct'
          data: [
            {
              name: 'Correct'
              y: difficulty_data[i].correct
              color: '#7CB5EC'
            }
            {
              name: 'Wrong'
              y: difficulty_data[i].wrong
              color: '#434348'
            }
          ]
        }]