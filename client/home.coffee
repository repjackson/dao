
@selected_tags = new ReactiveArray []

# Template.body.events
#     'click a:not(.select_term)': ->
#         $('.global_container')
#         .transition('fade out', 200)
#         .transition('fade in', 200)
#         # unless Meteor.user().invert_class is 'invert'

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

Template.home.onCreated ->
    # @autorun -> Meteor.subscribe('me')
    @autorun => Meteor.subscribe('dtags',
        # Session.get('query')
        selected_tags.array()
        Session.get('toggle')
        )
    @autorun => Meteor.subscribe('docs',
        selected_tags.array()
        Session.get('toggle')
        # Session.get('query')
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
        selected_tags.push @name
        # if Meteor.user()
        Meteor.call 'call_wiki', @name, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
            
        Meteor.call 'search_reddit', selected_tags.array(), ->
Template.reddit_card.helpers
    key_value_is: ->
        Template.currentData()["#{@key}"] is @value
Template.reddit_card.events
    'click .add_tag': -> 
        selected_tags.push @valueOf()
        # if Meteor.user()
        # Meteor.call 'call_wiki', @valueOf, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
            
        Meteor.call 'search_reddit', selected_tags.array(), ->

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
        Meteor.call 'search_reddit', selected_tags.array(), ->

            
Template.home.helpers
    many_tags: -> selected_tags.array().length > 1
    one_post: ->
        match = {model:$in:['reddit']}
        if selected_tags.array().length>0
            match.tags = $in:selected_tags.array()

        Docs.find(match).count() is 1



    docs: ->
        match = {model:$in:['reddit']}
        # match = {model:'post'}
        if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
        # cur = Docs.find match
        Docs.find match,
            sort:
                # points:-1
                ups:-1
                views:-1
                _timestamp:-1
                # "#{Session.get('sort_key')}": Session.get('sort_direction')
            limit:10
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
        doc_count = Docs.find({model:'reddit'}).count()
        if 0 < doc_count < 3 
            Tag_results.find({ 
                count:$lt:doc_count 
            })
        else 
            Tag_results.find()

Template.home.events
    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id

    'click #clear_tags': -> selected_tags.clear()


    'click .search_title': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
    'keydown .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        # Session.set('query',search)
        if e.which is 13
            # console.log search
            if search.length>0
                selected_tags.push search
                # if Meteor.user()
                # Meteor.call 'search_ph', selected_tags.array(), ->
                Meteor.call 'call_wiki', search, ->
                Meteor.call 'search_reddit', selected_tags.array(), ->
                Session.set('query','')
                search = $('.search_title').val('')
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()
