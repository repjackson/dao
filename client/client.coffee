@selected_tags = new ReactiveArray []

Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
Template.registerHelper 'seven_tags', ()-> @tags[..7]
Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value

Template.registerHelper 'youtube_parse', ()->
    console.log @url
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @url.match(regExp);
    if match and match[2].length is 11
        return match[2];
    else
        console.log 'no'


Template.registerHelper 'is_image', ()->
    @domain in ['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']

Template.registerHelper 'is_youtube', ()->
    @domain in ['youtube.com','youtu.be','vimeo.com']
Template.registerHelper 'is_twitter', ()->
    @domain in ['twitter.com','mobile.twitter.com','vimeo.com']


Template.reddit.onRendered ->
    # console.log @data
    unless @data.watson
        # console.log 'call'
        Meteor.call 'call_watson', @data._id, 'url','url',->
    unless @data.points
        console.log 'no points'
        Docs.update @data._id,
            $set:points:0
    # else 
    #     console.log 'points'
    
Template.home.events
    'click .tagger': (e,t)->
        Meteor.call 'call_watson', @_id, 'url', 'url', ->
    'keyup .tag_post': (e,t)->
        # console.log 
        if e.which is 13
            # $(e.currentTarget).closest('.button')
            tag = $(e.currentTarget).closest('.tag_post').val().toLowerCase().trim()
            Docs.update @_id,
                $addToSet: tags: tag
            $(e.currentTarget).closest('.tag_post').val('')
            # console.log tag
    'click .add_tag': -> 
        # console.log @valueOf()
        selected_tags.push @valueOf()
        # # if Meteor.user()
        Meteor.call 'call_wiki', @valueOf(), ->
        #     # Meteor.call 'calc_term', @title, ->
        #     # Meteor.call 'omega', @title, ->
        Meteor.call 'search_reddit', selected_tags.array(), ->



Template.post.events
    'click .add_tag': -> 
        # console.log @valueOf()
        selected_tags.push @valueOf()
        # # if Meteor.user()
        Meteor.call 'call_wiki', @valueOf(), ->
        #     # Meteor.call 'calc_term', @title, ->
        #     # Meteor.call 'omega', @title, ->
        Meteor.call 'search_reddit', selected_tags.array(), ->


        
Template.home.onCreated ->
    Session.setDefault('skip',0)
    @autorun -> Meteor.subscribe('doc_count',
        selected_tags.array()
        Session.get('view_mode')
        Session.get('skip')
        )
    @autorun => Meteor.subscribe('dtags',
        selected_tags.array()
        Session.get('view_mode')
        Session.get('skip')
        Session.get('toggle')
        Session.get('query')
        )
    @autorun => Meteor.subscribe('docs',
        selected_tags.array()
        Session.get('view_mode')
        Session.get('toggle')
        Session.get('query')
        Session.get('skip')
        )

    
Template.tag_selector.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data.name)
Template.tag_selector.helpers
    term: ->
        Docs.findOne 
            title:@name
Template.tag_selector.events
    'click .select_tag': -> 
        # results.update
        selected_tags.push @name
        Session.set('query','')
        Meteor.call 'call_wiki', @name, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 7000)
        Meteor.call 'search_reddit', selected_tags.array(), ->
       
       
Template.call_watson.events
    'click .pull': -> 
        Meteor.call 'call_watson', @_id, 'url','url', ->
            

Template.unselect_tag.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data)
    
Template.unselect_tag.helpers
    term: ->
        Docs.findOne 
            model:'wikipedia'
            title:@valueOf()
            
Template.unselect_tag.events
   'click .unselect_tag': -> 
        selected_tags.remove @valueOf()
        # Meteor.setTimeout( ->
        #     Session.set('toggle',!Session.get('toggle'))
        # , 7000)

        Meteor.call 'search_reddit', selected_tags.array(), ->
    
            
            

Template.home.helpers
    many_tags: -> selected_tags.array().length > 1
    doc_count: -> Counts.get('result_counter')
    docs: ->
        match = {model:$in:['post','wikipedia','reddit','page']}
        # match = {model:$in:['post','wikipedia','reddit']}
        # match = {model:'wikipedia'}
        if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
     
        Docs.find match,
            sort:
                points:-1
                ups:-1
                views:-1
                _timestamp:-1
                # "#{Session.get('sort_key')}": Session.get('sort_direction')
            limit:1
            skip:Session.get('skip')
        # if cur.count() is 1
        # Docs.find match

    home_button_class: ->
        if Template.instance().subscriptionsReady()
            ''
        else
            'disabled loading'

    term: ->
        # console.log @
        Docs.find 
            model:'wikipedia'
            title:@name
    
    selected_tags: -> selected_tags.array()
    tag_results: ->
        # match = {model:'wikipedia'}
        # doc_count = Docs.find(match).count()
        # if 0 < doc_count < 3 
        #     results.find({ 
        #         count:$lt:doc_count 
        #         model:'tag'
        #     })
        # else 
        results.find(model:'tag')


Template.home.events
    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id
    'click .vote_up': -> 
        Docs.update @_id,
            $inc: points: 1
    'click .vote_down': -> 
        Docs.update @_id,
            $inc: points: -1
    'click .forward': -> 
        current_skip = Session.get('skip')
        console.log current_skip
        next = current_skip+1
        Session.set('skip',next)
        # Session.get('skip')
    'click .back': -> 
        current_skip = Session.get('skip')
        console.log current_skip
        unless current_skip is 0
            prev = current_skip-1
            Session.set('skip',prev)
            # Session.get('skip')

    'click #clear_tags': -> selected_tags.clear()

    'click .search_title': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
    # 'keyup .search_title': _.throttle((e,t)->
    'keyup .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        # _.throttle( =>
        if search.length > 4
            Session.set('query',search)
        if e.which is 13
            # console.log search
            if search.length>0
                # Meteor.call 'check_url', search, (err,res)->
                #     console.log res
                #     if res
                #         alert 'url'
                #         Meteor.call 'lookup_url', search, (err,res)=>
                #             console.log res
                #             for tag in res.tags
                #                 selected_tags.push tag
                                
                #     else
                unless search in selected_tags.array()
                    selected_tags.push search
                    Meteor.call 'call_wiki', search, ->
                    # Session.set('query','')
                    search = $('.search_title').val('')
                    Meteor.setTimeout( ->
                        Session.set('toggle',!Session.get('toggle'))
                    , 7000)
                    # Meteor.setTimeout( ->
                    #     Session.set('toggle',!Session.get('toggle'))
                    # , 1000)
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()
    # , 1000)

# Template.registerHelper 'session_is', (key)-> Session.get(key)
# Template.registerHelper 'session_key_value', (key,value)-> Session.equals("#{key}",value)

Template.view_mode.helpers
    toggle_mode_class: -> if Session.equals('view_mode',@key) then "#{@icon} blue circular" else "#{@icon} grey"

Template.view_mode.events
    'click .toggle_mode': -> Session.set('view_mode', @key)



Template.pull_reddit.events
    'click .pull': -> 
        Meteor.call 'get_reddit_post', @_id, @reddit_id, ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
Template.call_watson.events
    'click .pull': -> 
        Meteor.call 'call_watson', @_id, 'url','url', ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
       

# Template.reddit.onRendered ->
#     Meteor.setTimeout( =>
#         console.log @
#         $('.ui.embed').embed({
#             source: 'youtube',
#             url: @data.url
#             # placeholder: '/images/bear-waving.jpg'
#         });
#     , 1000)