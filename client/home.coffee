@selected_tags = new ReactiveArray []

Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
Template.registerHelper 'seven_tags', ()-> @tags[..7]
    

Template.post_card.events
    'click .add_tag': -> 
        # console.log @valueOf()
        selected_tags.push @valueOf()
        # # if Meteor.user()
        Meteor.call 'call_wiki', @valueOf(), ->
        #     # Meteor.call 'calc_term', @title, ->
        #     # Meteor.call 'omega', @title, ->
            

Template.post_card.onCreated ->
    @autorun -> Meteor.subscribe('doc_count',
        selected_tags.array()
        )
Template.home.onCreated ->
    @autorun -> Meteor.subscribe('doc_count',
        selected_tags.array()
        )
    @autorun => Meteor.subscribe('dtags',
        selected_tags.array()
        Session.get('toggle')
        Session.get('query')
        )
    @autorun => Meteor.subscribe('docs',
        selected_tags.array()
        Session.get('toggle')
        Session.get('query')
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
        # Session.set('query','')
        Meteor.call 'call_wiki', @name, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 7000)
       
       
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
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 7000)

            
            
Template.post_card.helpers
    one_post: -> Counts.get('result_counter') is 1
    two_posts: -> Counts.get('result_counter') is 2

Template.home.helpers
    many_tags: -> selected_tags.array().length > 1
    doc_count: -> Counts.get('result_counter')
    docs: ->
        # match = {model:$in:['post','wikipedia','reddit','page']}
        # match = {model:$in:['post','wikipedia','reddit']}
        match = {model:'wikipedia'}
        if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
     
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
    
    'click #clear_tags': -> selected_tags.clear()

    'click .search_title': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
    # 'keyup .search_title': _.throttle((e,t)->
    'keyup .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        # _.throttle( =>
        # if search.length > 2
        #     Session.set('query',search)
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
                    # Meteor.setTimeout( ->
                    #     Session.set('toggle',!Session.get('toggle'))
                    # , 1000)
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()
    # , 1000)

# Template.registerHelper 'session_is', (key)-> Session.get(key)
# Template.registerHelper 'session_key_value', (key,value)-> Session.equals("#{key}",value)


