if Meteor.isClient
    @selected_tags = new ReactiveArray []
    # @selected_authors = new ReactiveArray []
    # @selected_upvoters = new ReactiveArray []
    # @selected_sources = new ReactiveArray []
    
    Template.body.events
        # 'click a:not(.select_term)': ->
        #     $('.global_container')
        #     .transition('fade out', 200)
        #     .transition('fade in', 200)
        #     # unless Meteor.user().invert_class is 'invert'

    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'



    Template.home.onCreated ->
        @autorun -> Meteor.subscribe('me')
        @autorun -> Meteor.subscribe('tags',
            # Session.get('query')
            selected_tags.array()
            # selected_authors.array()
            # selected_upvoters.array()
            # selected_sources.array()
            )
        @autorun -> Meteor.subscribe('docs',
            selected_tags.array()
            # Session.get('query')
            # selected_authors.array()
            # selected_upvoters.array()
            # selected_sources.array()
            )

        
    # Template.sort_button.events
    #     'click .toggle_sort': ->
    #         Session.set('sort_key',@key)
    #         if Session.equals('sort_direction', 1)
    #             Session.set('sort_direction', -1)
    #         else
    #             Session.set('sort_direction', 1)


    # Template.sort_button.helpers
        # is_selected: -> 
        #     Session.equals('sort_key', @key)
        # sorting_up: -> 
        #     Session.equals('sort_direction', 1)
        # sort_button_class: ->
        #     if Session.equals('sort_key', @key) then 'black' else 'basic'
    Template.tag_selector.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe('doc_by_title', @data.name)
    Template.tag_selector.helpers
        term: ->
            Docs.findOne 
                title:@name
                
    Template.unselect_tag.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe('doc_by_title', @data)
    Template.unselect_tag.helpers
        term: ->
            Docs.findOne 
                title:@valueOf()
    Template.unselect_tag.events
       'click .unselect_tag': -> 
            selected_tags.remove @valueOf()
            Meteor.call 'search_reddit', selected_tags.array(), ->

                
    Template.home.helpers
        selected_tags_plural: -> selected_tags.array().length > 1
        one_post: ->
            match = {model:$in:['post','wikipedia','reddit']}
            
            # match = {model:'post'}
            if selected_tags.array().length>0
                match.tags = $in:selected_tags.array()

            Docs.find(match).count() is 1
    
        two_posts: -> 
            match = {model:$in:['post','wikipedia','reddit']}
            
            # match = {model:'post'}
            if selected_tags.array().length>0
                match.tags = $in:selected_tags.array()
            Docs.find(match).count() is 2
        three_posts: -> Docs.find().count() is 3
    
    
        docs: ->
            match = {model:$in:['post','wikipedia','reddit']}
            
            # match = {model:'post'}
            # if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
            Docs.find match,
                sort:
                    tags:1
                    _timestamp:-1
                    # "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:5
            
        term: ->
            # console.log @
            Docs.find 
                model:$in:['wikipedia']
                title:@name
        
        one_result: ->
            Docs.find().count() < 2
        
        selected_tags: -> selected_tags.array()
        tag_results: ->
            doc_count = Docs.find({model:$in:['post','wikipedia','reddit']}).count()
            if 0 < doc_count < 3 
                Tag_results.find({ 
                    count:$lt:doc_count 
                })
            else 
                Tag_results.find()

    Template.tag_selector.events
        'click .select_tag': -> 
            selected_tags.push @name
            # if Meteor.user()
            # Meteor.call 'call_wiki', @name, ->
            # Meteor.call 'search_reddit', selected_tags.array(), ->
    Template.home.events
        # 'click .delete': -> 
        #     console.log @
        #     Docs.remove @_id
        'click .post': ->
            new_post_id =
                Docs.insert
                    model:'post'
                    source:'self'
                    # buyer_id:Meteor.userId()
                    # buyer_username:Meteor.user().username
                    
            Router.go "/post/#{new_post_id}/edit"

        
    
        'click #clear_tags': -> selected_tags.clear()
    
    
        'keydown .search_title': (e,t)->
            search = $('.search_title').val().toLowerCase().trim()
            # Session.set('query',search)
            if e.which is 13
                console.log search
                selected_tags.push search
                # if Meteor.user()
                # Meteor.call 'call_wiki', search, ->
                # Meteor.call 'search_reddit', selected_tags.array(), ->
                Session.set('query','')
                search = $('.search_title').val('')
            if e.which is 8
                if search.length is 0
                    selected_tags.pop()
