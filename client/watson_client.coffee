Template.doc_emotion.onCreated ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 1000
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 1000

Template.small_sentiment.onCreated ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 1000

Template.small_sentiment.helpers
    sentiment_score_percent: ->
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'


Template.doc_emotion.helpers
    sadness_percent: -> (@sadness*100).toFixed()
    joy_percent: -> (@joy*100).toFixed()
    disgust_percent: -> (@disgust*100).toFixed()
    anger_percent: -> (@anger*100).toFixed()
    fear_percent: -> (@fear*100).toFixed()


    sentiment_score_percent: ->
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()


    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'

    is_positive: -> if @doc_sentiment_label is 'positive' then true else false


Template.keywords.helpers
    relevance_percent: -> (@relevance*100).toFixed()

    sentiment_percent: ->
        (@sentiment.score*100).toFixed()

    sadness_percent: -> (@sadness*100).toFixed()
    # joy_percent: -> (@joy*100).toFixed()
    disgust_percent: -> (@disgust*100).toFixed()
    anger_percent: -> (@anger*100).toFixed()
    fear_percent: -> (@fear*100).toFixed()

Template.keywords.onRendered ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 2000
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 2000

Template.tone.events
    'keyup .tag_sentence': (e,t)->
        # console.log 
        if e.which is 13
            # $(e.currentTarget).closest('.button')
            tag = $(e.currentTarget).closest('.tag_sentence').val().toLowerCase().trim()
            Meteor.call 'tag_sentence', Template.currentData()._id, @, tag, =>
                $(e.currentTarget).closest('.tag_sentence').val('')
            # console.log tag
    'click .upvote_sentence': ->
        Meteor.call 'upvote_sentence', Template.currentData()._id, @, ->
    'click .downvote_sentence': ->
        console.log @
        console.log Template.currentData()
        console.log Template.parentData()
        Meteor.call 'downvote_sentence', Template.currentData()._id, @, ->
    # 'click .tone_item': ->
    #     # console.log @
    #     doc_id = Docs.findOne()._id
    #     if @weight is 3
    #         Meteor.call 'reset_sentence', Template.currentData()._id, @, ->
    #     else
    #         Meteor.call 'upvote_sentence', Template.currentData()._id, @, ->

Template.call_watson.events
    'click .autotag': ->
        # console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        if @rd and @rd.selftext_html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @rd.selftext_html
            # console.log 'innner html', dom.value
            # return dom.value
            Docs.update @_id,
                $set:
                    parsed_selftext_html:dom.value
        
        doc = Template.parentData()
        Meteor.call 'call_watson', Router.current().params.doc_id, parent.key, @mode, ->
        # Meteor.call 'call_watson', doc._id, @key, @mode, ->

Template.autotag.events
    'click .autotag': ->
        # console.log @
        if @rd and @rd.selftext_html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @rd.selftext_html
            console.log 'innner html', dom.value
            # return dom.value
            Docs.update @_id,
                $set:
                    parsed_selftext_html:dom.value
        
        doc = Template.parentData()
        Meteor.call 'call_watson', @_id, 'url', 'url', ->


Template.call_tone.events
    'click .call': ->
        console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        doc = Template.parentData()
        Meteor.call 'call_tone', Router.current().params.doc_id, parent.key, @mode, ->
        # Meteor.call 'call_watson', doc._id, @key, @mode, ->




Template.call_visual.events
    'click #call_visual': ->
        console.log @
        Meteor.call 'call_visual_link', Router.current().params._id, @valueOf(),->

Template.tone.events
    'click #call_tone': ->
        console.log Router.current().params._id
        console.log parent.key
        console.log @mode
        # Meteor.call 'call_tone', Router.current().params._id, parent.key, @mode, ->



Template.doc_sentiment.onRendered ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 2000


Template.doc_sentiment.helpers
    sentiment_score_percent: ->
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()


    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'

    is_positive: -> if @doc_sentiment_label is 'positive' then true else false