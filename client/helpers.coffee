Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)

Template.registerHelper 'calculated_size', (metric) ->
    # console.log 'metric', metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log 'whole', whole

    if whole is 2 then 'f7'
    else if whole is 3 then 'f8'
    else if whole is 4 then 'f9'
    else if whole is 5 then 'f10'
    else if whole is 6 then 'f11'
    else if whole is 7 then 'f12'
    else if whole is 8 then 'f13'
    else if whole is 9 then 'f14'
    else if whole is 10 then 'f15'

Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'lowered', (input)-> input.toLowerCase()


Template.registerHelper 'tone_size', () ->
    # console.log 'this weight', @weight
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    switch @weight
        when -5 then 'f6'
        when -4 then 'f7'
        when -3 then 'f8'
        when -2 then 'f9'
        when -1 then 'f10'
        when 0 then 'f12'
        when 1 then 'f12'
        when 2 then 'f13'
        when 3 then 'f14'
        when 4 then 'f15'
        when 5 then 'f16'
        else 'f11'


Template.registerHelper 'post_header_class', (metric) ->
    # console.log @
    switch @max_emotion_name
        when 'joy' then 'green'
        when 'anger' then 'red'
        when 'sadness' then 'blue'
        when 'disgust' then 'orange'
        when 'fear' then ''
        else 'grey'

Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value
