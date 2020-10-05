
@selected_tags = new ReactiveArray []
# @selected_authors = new ReactiveArray []
@selected_domains = new ReactiveArray []
# @selected_subreddits = new ReactiveArray []
@selected_models = new ReactiveArray []

Template.body.events
    # 'click a:not(.select_term)': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)
    #     # unless Meteor.user().invert_class is 'invert'

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

Template.reddit_card.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.registerHelper 'key_value_is', (key,value)->
    Template.currentData()["#{key}"] is value
    # @["#{key}"] is value

Template.registerHelper 'is_image', ()->
    @domain in ['i.imgur.com','i.reddit.com','i.redd.it']

Template.registerHelper 'is_youtube', ()->
    @domain in ['youtube.com','youtu.be','vimeo.com']
Template.registerHelper 'is_twitter', ()->
    @domain in ['twitter.com','mobile.twitter.com','vimeo.com']


Template.reddit_card.events
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
        selected_tags.push @valueOf()
        # if Meteor.user()
        # Meteor.call 'call_wiki', @valueOf, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
            
        Meteor.call 'search_reddit', selected_tags.array(), ->

Template.home.onCreated ->
    @autorun -> Meteor.subscribe('doc_count',
        selected_tags.array()
        selected_domains.array()
        selected_models.array()
        Session.get('view_mode')
        )
    @autorun => Meteor.subscribe('dtags',
        selected_tags.array()
        Session.get('toggle')
        Session.get('query')
        selected_domains.array()
        selected_models.array()
        Session.get('view_mode')
        )
    @autorun => Meteor.subscribe('docs',
        selected_tags.array()
        Session.get('toggle')
        Session.get('query')
        selected_domains.array()
        selected_models.array()
        Session.get('view_mode')
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
        # if Meteor.user()
        Meteor.call 'call_wiki', @name, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
        Meteor.call 'search_reddit', selected_tags.array(), ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
        # Meteor.call 'search_stack', @name, ->
        # Meteor.setTimeout( ->
        #     Session.set('toggle',!Session.get('toggle'))
        # , 7000)
       
Template.pull_reddit.events
    'click .pull': -> 
        Meteor.call 'get_reddit_post', @_id, @reddit_id, ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
       
       
Template.call_watson.events
    'click .pull': -> 
        Meteor.call 'call_watson', @_id, 'url','url', ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
       
       
            

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
        # Meteor.call 'search_reddit', selected_tags.array(), ->
        # Meteor.setTimeout( ->
        #     Session.set('toggle',!Session.get('toggle'))
        # , 7000)

            
            
Template.home.helpers
    selected_authors: -> selected_authors.array()
    author_results: ->
        match = {}
        match = {model:$in:['post','wikipedia','reddit','page']}
        doc_count = Docs.find(match).count()
        if 0 < doc_count < 3 
            results.find({ 
                model:'author'
                count:$lt:doc_count 
            })
        else 
            results.find(model:'author')
            
    # selected_subreddits: -> selected_subreddits.array()
    # subreddit_results: ->
    #     match = {}
    #     match = {model:$in:['post','wikipedia','reddit','page']}
    #     doc_count = Docs.find(match).count()
    #     if 0 < doc_count < 3 
    #         results.find({ 
    #             model:'subreddit'
    #             count:$lt:doc_count 
    #         })
    #     else 
    #         results.find(model:'subreddit')
            
    selected_domains: -> selected_domains.array()
    domain_results: ->
        match = {}
        match = {model:$in:['post','wikipedia','reddit','page']}
        doc_count = Docs.find(match).count()
        if 0 < doc_count < 3 
            results.find({ 
                model:'domain'
                count:$lt:doc_count 
            })
        else 
            results.find(model:'domain')
            
            
    selected_models: -> selected_models.array()
    model_results: ->
        match = {}
        match = {model:$in:['post','wikipedia','reddit','page']}
        doc_count = Docs.find(match).count()
        if 0 < doc_count < 3 
            results.find({ 
                model:'model'
                count:$lt:doc_count 
            })
        else 
            results.find(model:'model')
            
            
    many_tags: -> selected_tags.array().length > 1
    one_post: ->
        match = {model:$in:['post','wikipedia','reddit']}
        if selected_tags.array().length>0
            match.tags = $in:selected_tags.array()

        Docs.find(match).count() is 1

    doc_count: -> Counts.get('result_counter') 
    docs: ->
        match = {model:$in:['post','wikipedia','reddit','page']}
        # match = {model:$in:['post','wikipedia','reddit']}
        # match = {model:'post'}
        if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
        # cur = Docs.find match
        if Session.equals('view_mode','grid')
            limit = 10
        else if Session.equals('view_mode','list')
            limit = 10
        else if Session.equals('view_mode','single')
            limit = 1
        else
            limit = 1

     
        Docs.find match,
            sort:
                # points:-1
                ups:-1
                views:-1
                _timestamp:-1
                # "#{Session.get('sort_key')}": Session.get('sort_direction')
            limit:limit
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
            model:$in:['wikipedia']
            lower_title:@name
    
    selected_tags: -> selected_tags.array()
    tag_results: ->
        # match = {model:$in:['post','wikipedia','reddit','page']}
        match = {model:$in:['post','wikipedia','reddit']}
        doc_count = Docs.find(match).count()
        if 0 < doc_count < 3 
            results.find({ 
                count:$lt:doc_count 
                model:'tag'
            })
        else 
            results.find(model:'tag')

    images_button_class: ->
        if Session.equals('view_mode', 'images')
            'active'
        else 
            'basic'

Template.home.events
    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id
    'click .set_grid': -> Session.set('view_mode','grid')
    'click .set_list': -> Session.set('view_mode','list')
    'click .set_single': -> Session.set('view_mode','single')
    'click .set_page': -> Session.set('view_mode','page')
    'click .toggle_images': -> 
        if Session.equals('view_mode','images')
            Session.set('view_mode','grid')
        else
            Session.set('view_mode','images')
            
        
    # 'click .set_porn': -> Session.set('view_mode','porn')
    
    
    
    'click #clear_tags': -> selected_tags.clear()

    'click .select_domain': -> selected_domains.push @name
    'click .unselect_domain': -> selected_domains.remove @valueOf()
    'click #clear_domains': -> selected_domains.clear()

    'click .select_model': -> selected_models.push @name
    'click .unselect_model': -> selected_models.remove @valueOf()
    'click #clear_models': -> selected_models.clear()





    'click .search_title': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
    'keydown .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        # Session.set('query',search)
        if e.which is 13
            # console.log search
            if search.length>0
                Meteor.call 'check_url', search, (err,res)->
                    console.log res
                    if res
                        alert 'url'
                        Meteor.call 'lookup_url', search, (err,res)=>
                            console.log res
                            for tag in res.tags
                                selected_tags.push tag
                                
                    else
                        selected_tags.push search
                        
                        # if Meteor.user()
                        # Meteor.call 'search_ph', selected_tags.array(), ->
                        Meteor.call 'call_wiki', search, ->
                        # Meteor.call 'search_stack', search, ->
        
                        Meteor.call 'search_reddit', selected_tags.array(), ->
                        Session.set('query','')
                        search = $('.search_title').val('')
                        Meteor.setTimeout( ->
                            Session.set('toggle',!Session.get('toggle'))
                        , 7000)
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()

Template.registerHelper 'session_is', (key)-> Session.get(key)
Template.registerHelper 'session_key_value', (key,value)-> Session.equals("#{key}",value)


Template.session_boolean_toggle.events
    'click .toggle_session_key': ->
        console.log @key
        Session.set(@key, !Session.get(@key))

Template.session_boolean_toggle.helpers
    calculated_class: ->
        res = ''
        # console.log @
        if @classes
            res += @classes
        if Session.get(@key)
            res += ' black'
        else
            res += ' basic'

        # console.log res
        res

