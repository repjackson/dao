@picked_tags = new ReactiveArray []
# @selected_models = new ReactiveArray []
# @selected_subreddits = new ReactiveArray []
@selected_emotions = new ReactiveArray []

Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
Template.registerHelper 'seven_tags', ()-> @tags[..7]
Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value


# @log = (input)-> console.log input


Template.registerHelper 'embed', ()->
    if @rd and @rd.media and @rd.media.oembed and @rd.media.oembed.html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @rd.media.oembed.html
        # console.log 'innner html', dom.value
        return dom.value
        # Docs.update @_id,
        #     $set:
        #         parsed_selftext_html:dom.value


Template.registerHelper 'youtube_parse', ()->
    # console.log @url
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @url.match(regExp);
    if match and match[2].length is 11
        return match[2];
    else
        console.log 'no'


Template.registerHelper 'is_image', ()->
    @domain in ['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']

Template.registerHelper 'is_youtube', ()->
    @domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
Template.registerHelper 'is_twitter', ()->
    @domain in ['twitter.com','mobile.twitter.com','vimeo.com']



Template.doc.onRendered ->
    # console.log @data
    # unless @data.watson
    #     # console.log 'call'
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # Meteor.setTimeout =>
    #     if @data.title
    #         window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    # , 1000


        
Template.home.onCreated ->
    # window.speechSynthesis.cancel()
    # window.speechSynthesis.speak new SpeechSynthesisUtterance 'dao'

    Session.setDefault('skip',0)
    Session.setDefault('view_section','content')
    @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())
    # @autorun -> Meteor.subscribe('alpha_single',picked_tags.array())
    @autorun -> Meteor.subscribe('duck',picked_tags.array())
    @autorun -> Meteor.subscribe('doc_count',
        picked_tags.array()
        Session.get('view_mode')
        Session.get('emotion_mode')
        # selected_models.array()
        # selected_subreddits.array()
        selected_emotions.array()
        )
    @autorun => Meteor.subscribe('dtags',
        picked_tags.array()
        Session.get('view_mode')
        Session.get('emotion_mode')
        Session.get('toggle')
        # selected_models.array()
        # selected_subreddits.array()
        selected_emotions.array()
        # Session.get('query')
        )
    @autorun => Meteor.subscribe('docs',
        picked_tags.array()
        Session.get('view_mode')
        Session.get('emotion_mode')
        Session.get('toggle')
        # selected_models.array()
        # selected_subreddits.array()
        selected_emotions.array()
        # Session.get('query')
        Session.get('skip')
        )



Template.alpha.onRendered ->
    # console.log @data
    # unless @data.watson
    #     # console.log 'call'
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[1].plaintext
    if @data.voice
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.voice
    else
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[0].plaintext
    # console.log response.queryresult.pods[1].subpods
    # Meteor.setTimeout( =>
    # , 7000)

Template.alpha.helpers
    split_datatypes: ->
        # console.log 'data', @
        split = @datatypes.split ','
        console.log split
        split

Template.alpha.events
    'click .select_datatype': ->
        console.log @
        picked_tags.push @valueOf().toLowerCase()
    'click .alphatemp': ->
        console.log @plaintext
        console.log @plaintext.split '|'
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @plaintext
        


Template.doc.onRendered ->
    # console.log @data
    unless @data.watson
        # console.log 'call'
        Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.watson
    unless @data.tone
        # console.log 'call'
        Meteor.call 'call_tone', @data._id,->
    Meteor.call 'uniq', @data._id, ->
    unless @data.points
        # console.log 'no points'
        Docs.update @data._id,
            $set:points:0
    if @data.rd and @data.rd.selftext_html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @data.rd.selftext_html
        # console.log 'innner html', dom.value
        # return dom.value
        Docs.update @data._id,
            $set:
                parsed_selftext_html:dom.value
            
    # else 
    #     console.log 'points'
    


Template.unselect_tag.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data)
    
Template.unselect_tag.helpers
    term: ->
        console.log @valueOf()
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf()
         console.log found
         found
Template.unselect_tag.events
   'click .unselect_tag': -> 
        picked_tags.remove @valueOf()
        Session.set('skip',0)
        if picked_tags.array().length > 0
            # if Session.equals('view_mode','porn')
            #     Meteor.call 'search_ph', picked_tags.array(), ->
            # else
            Meteor.call 'call_alpha', picked_tags.array().toString(), ->
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', picked_tags.array(), ->
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            Meteor.setTimeout( ->
                Session.set('toggle',!Session.get('toggle'))
            , 10000)

    





Template.tag_selector.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data.name)
Template.tag_selector.helpers
    selector_header_class: ()->
        # console.log @
        term = 
            Docs.findOne 
                title:@name
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then 'invert basic green'
                    when 'anger' then 'invert basic red'
                    when 'sadness' then 'invert basic blue'
                    when 'disgust' then 'invert basic orange'
                    when 'fear' then 'invert basic grey'
                    else 'basic'
    term: ->
        Docs.findOne 
            title:@name
            
Template.home.events
    # 'click .select_model': -> selected_models.push @name
    'click .select_emotion': -> selected_emotions.push @name
    # 'click .select_location': -> selected_locations.push @name
    
    # 'click .unselect_location': -> selected_locations.remove @valueOf()
    # 'click .unselect_model': -> selected_models.remove @valueOf()
    # 'click .unselect_subreddit': -> selected_subreddits.remove @valueOf()
    'click .unselect_emotion': -> selected_emotions.remove @valueOf()
            
            
Template.tag_selector.events
    'click .select_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
        picked_tags.push @name
        Session.set('query','')
        Session.set('skip',0)
        $('.search_title').val('')
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        # Meteor.call 'call_alpha', @name, ->
        Meteor.call 'call_wiki', @name, ->
        Meteor.call 'search_ddg', @name, ->
        Session.set('viewing_doc',null)
        Meteor.call 'search_reddit', picked_tags.array(), ->
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
       
       
Template.doc_tag.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data)
Template.doc_tag.helpers
    selector_header_class: ()->
        # console.log @
        term = 
            Docs.findOne 
                title:@valueOf()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then 'joy'
                    when 'anger' then 'red'
                    when 'sadness' then 'blue'
                    when 'disgust' then 'orange'
                    when 'fear' then 'grey'
    term: ->
        Docs.findOne 
            title:@valueOf()
            
            
Template.doc_tag.events
    'click .select_tag': -> 
        # results.update
        window.speechSynthesis.cancel()
        
        picked_tags.push @valueOf()
        Session.set('query','')
        Session.set('skip',0)
        Session.set('viewing_doc',null)

        Meteor.call 'call_wiki', @valueOf(), ->
        # Meteor.call 'call_alpha', @valueOf(), ->
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.call 'search_reddit', picked_tags.array(), ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
       
       
       
       
       
# Template.select_subreddit.onCreated ->
#     # console.log @
#     @autorun => Meteor.subscribe('tribe_by_title', @data.name)
# Template.select_subreddit.helpers
#     tribe_doc: ->
#         found = Docs.findOne 
#             title:@name
#             model:'tribe'
#         # console.log found 
#         found 
            
       
       
       

Template.doc.helpers
    viewing_doc: -> Session.equals('viewing_doc', @_id)
    card_class: -> if Session.equals('viewing_doc', @_id) then 'fluid'
Template.home.helpers
    viewing_doc: -> Session.get('viewing_doc')
    alphas: ->
        Docs.find 
            model:'alpha'
            # query: $in: picked_tags.array()
            query: picked_tags.array().toString()
    # alpha_singles: ->
    #     Docs.find 
    #         model:'alpha'
    #         query: $in: picked_tags.array()
    #         # query: picked_tags.array().toString()
    ducks: ->
        Docs.find 
            model:'duck'
            # query: $in: picked_tags.array()
            query: picked_tags.array().toString()
    many_tags: -> picked_tags.array().length > 1
    doc_count: -> Counts.get('result_counter')
    result_docs: ->
        if Session.get('viewing_doc')
            Docs.find Session.get('viewing_doc')
        else
            match = {model:$in:['post','wikipedia','reddit']}
            # match = {model:$in:['post','wikipedia','reddit']}
            # match = {model:'wikipedia'}
            # if picked_tags.array().length>0
            match.tags = $all:picked_tags.array()
         
            Docs.find match,
                sort:
                    points:-1
                    ups:-1
                    # _timestamp:-1
                    # "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
                # skip:Session.get('skip')
            # if cur.count() is 1
            # Docs.find match

    loading_class: ->
        if Template.instance().subscriptionsReady()
            console.log 'ready'
            ''
        else
            console.log 'NOT READY'
            'disabled loading'

    # term: ->
    #     # console.log @
    #     Docs.find 
    #         model:'wikipedia'
    #         title:@valueOf()
    
    picked_tags: -> picked_tags.array()
    # selected_models: -> selected_models.array()
    # selected_subreddits: -> selected_subreddits.array()
    selected_emotions: -> selected_emotions.array()
   
    emotion_results: -> Results.find(model:'emotion')
    # model_results: -> Results.find(model:'model')
    # subreddit_results: -> Results.find(model:'subreddit')
    tag_results: ->
        # match = {model:'wikipedia'}
        # doc_count = Docs.find(match).count()
        # if 0 < doc_count < 3 
        #     Results.find({ 
        #         count:$lt:doc_count 
        #         model:'tag'
        #     })
        # else 
        Results.find(model:'tag')


Template.duck.events
    'click .topic': (e,t)-> 
        console.log @
        window.speechSynthesis.speak new SpeechSynthesisUtterance @Text
        # console.log @FirstURL.replace(/\s+/g, '-')
        url = new URL(@FirstURL);
        console.log url
        console.log url.pathname
        picked_tags.push @Text.toLowerCase()
        Meteor.call 'call_wiki', picked_tags.array().toString(), ->
        Meteor.call 'search_reddit', picked_tags.array(), ->

    'click .abstract': (e,t)-> 
        console.log @
        window.speechSynthesis.speak new SpeechSynthesisUtterance @AbstractText

    # 'click .tagger': (e,t)->
    #     Meteor.call 'call_watson', @_id, 'url', 'url', ->


Template.doc.events
    'click .toggle_view': (e,t)-> 
        if Session.equals('viewing_doc', @_id)
            Session.set('viewing_doc', null)
            # window.speechSynthesis.cancel()
        else
            window.speechSynthesis.cancel()
            Session.set('viewing_doc', @_id)
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
            if @tone 
                for sentence in @tone.result.sentences_tone
                    console.log sentence
                    Session.set('current_reading_sentence',sentence)
                    window.speechSynthesis.speak new SpeechSynthesisUtterance sentence.text
    'click .read': (e,t)-> 
        if @tone 
            window.speechSynthesis.cancel()
            for sentence in @tone.result.sentences_tone
                console.log sentence
                Session.set('current_reading_sentence',sentence)
                window.speechSynthesis.speak new SpeechSynthesisUtterance sentence.text
    'click .print_me': (e,t)-> console.log @
    # 'click .tagger': (e,t)->
    #     Meteor.call 'call_watson', @_id, 'url', 'url', ->
    'keyup .tag_post': (e,t)->
        # console.log 
        if e.which is 13
            # $(e.currentTarget).closest('.button')
            tag = $(e.currentTarget).closest('.tag_post').val().toLowerCase().trim()
            # console.log tag
            console.log @
            Docs.update @_id,
                $addToSet: tags: tag
            $(e.currentTarget).closest('.tag_post').val('')
            # console.log tag
    'click .add_tag': -> 
        # console.log @valueOf()
        picked_tags.push @valueOf()
        # # if Meteor.user()
        Session.set('viewing_doc',null)

        Meteor.call 'call_wiki', @valueOf(), ->
        Meteor.call 'search_reddit', picked_tags.array(), ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()

    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id
    'click .vote_up': -> 
        Docs.update @_id,
            $inc: points: 1
        # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'yeah'
    'click .vote_down': -> 
        Docs.update @_id,
            $inc: points: -1
            # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'ouch'
            

Template.home.events
    'click #clear_tags': -> 
        # picked_tags.clear()
        window.speechSynthesis.cancel()


    'click .search_title': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
        # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'hail satan'

    # 'keyup .search_title': _.throttle((e,t)->
    'keyup .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        # _.throttle( =>

        # if search.length > 4
        #     Session.set('query',search)
        # else if search.length is 0
        #     Session.set('query','')
        if e.which is 13
            window.speechSynthesis.cancel()
            # console.log search
            if search.length > 0
                # Meteor.call 'check_url', search, (err,res)->
                #     console.log res
                #     if res
                #         alert 'url'
                #         Meteor.call 'lookup_url', search, (err,res)=>
                #             console.log res
                #             for tag in res.tags
                #                 picked_tags.push tag
                #             Session.set('skip',0)
                #             Session.set('query','')
                #             $('.search_title').val('')
                #     else
                # unless search in picked_tags.array()
                picked_tags.push search
                # console.log 'selected tags', picked_tags.array()
                # Meteor.call 'call_alpha', search, ->
                Meteor.call 'search_ddg', search, ->
                # if Session.equals('view_mode','porn')
                #     Meteor.call 'search_ph', search, ->
                # else
                # window.speechSynthesis.speak new SpeechSynthesisUtterance search
                window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
                Meteor.call 'call_alpha', picked_tags.array().toString(), ->
                Meteor.call 'call_wiki', search, ->
                Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('viewing_doc',null)

                Session.set('skip',0)
                # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()

                # Session.set('query','')
                $('.search_title').val('')
                Meteor.setTimeout( ->
                    Session.set('toggle',!Session.get('toggle'))
                , 10000)
        # if e.which is 8
        #     if search.length is 0
        #         picked_tags.pop()
    # , 1000)


Template.view_mode.helpers
    toggle_view_class: -> if Session.equals('view_mode',@key) then "#{@icon} huge #{@color}" else "#{@icon} big grey"

Template.view_mode.events
    'click .toggle_view': -> 
        if Session.equals('view_mode', @key)
            Session.set('view_mode', null)
        else
            Session.set('view_mode', @key)
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @key


Template.emotion_mode.helpers
    toggle_emotion_class: -> 
        if Session.equals('emotion_mode',@key) then "#{@icon} huge orange" else "#{@icon} big grey"
    selected_emotion: ->  Session.equals('emotion_mode',@key)

Template.emotion_mode.events
    'click .toggle_emotion': -> 
        if Session.equals('emotion_mode', @key)
            Session.set('emotion_mode', null)
        else
            Session.set('emotion_mode', @key)
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @key



Template.pull_reddit.events
    'click .pull': -> 
        Meteor.call 'get_reddit_post', @_id, @reddit_id, ->
        # Meteor.call 'search_stack', picked_tags.array(), ->
Template.call_watson.events
    'click .pull': -> 
        Meteor.call 'call_watson', @_id, 'url','url', ->
        # Meteor.call 'search_stack', picked_tags.array(), ->
       

Template.doc.onRendered ->
    # Meteor.setTimeout( =>
    #     # console.log @
    #     $('.ui.embed').embed({
    #         source: 'youtube',
    #         # url: @data.url
    #         # placeholder: '/images/bear-waving.jpg'
    #     });
    # , 1000)

