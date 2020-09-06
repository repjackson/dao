

if Meteor.isClient
    @selected_tags = new ReactiveArray []
    @selected_authors = new ReactiveArray []
    @selected_upvoters = new ReactiveArray []
    
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

    Template.tone.helpers
        tone_label_class: ->
            # console.log @
            if @tone_id is 'analytical'
                'orange'
            else if @tone_id is 'sadness'
                'blue'
            else if @tone_id is 'joy'
                'green'
            else if @tone_id is 'anger'
                'red'
            else if @tone_id is 'tentative'
                'yellow'
            else if @tone_id is 'confident'
                'teal'
    Template.call_watson.events
        'click .autotag': ->
            console.log @
            Meteor.call 'call_watson', Router.current().params.doc_id, @key, @mode, ->
                Meteor.call 'call_tone', Router.current().params.doc_id, @key, @mode, ->



    Template.home.onCreated ->
        @autorun -> Meteor.subscribe('me')
        @autorun -> Meteor.subscribe('tags',
            Session.get('query')
            selected_tags.array()
            selected_authors.array()
            selected_upvoters.array()
            )
        @autorun -> Meteor.subscribe('docs',
            Session.get('query')
            selected_tags.array()
            selected_authors.array()
            selected_upvoters.array()
            )

        
    # Template.sort_button.events
    #     'click .toggle_sort': ->
    #         Session.set('sort_key',@key)
    #         if Session.equals('sort_direction', 1)
    #             Session.set('sort_direction', -1)
    #         else
    #             Session.set('sort_direction', 1)


    Template.tone.events
        # 'click .upvote_sentence': ->
        'click .tone_item': ->
            # console.log @
            doc_id = Docs.findOne()._id
            if @weight is 3
                Meteor.call 'reset_sentence', doc_id, @, ->
            else
                Meteor.call 'upvote_sentence', doc_id, @, ->
        # 'click .downvote_sentence': ->
        #     # console.log @
        #     Meteor.call 'downvote_sentence', omega.selected_doc_id, @, ->

            
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
                
                
    Template.home.helpers
        selected_tags_plural: -> selected_tags.array().length > 1
        one_post: -> Docs.find().count() is 1
    
        two_posts: -> Docs.find().count() is 2
        three_posts: -> Docs.find().count() is 3
        one_result: -> Docs.find().count() is 1
    
    
        can_debit: -> Meteor.user().points > 0
        docs: ->
            match = {model:'post'}
            if selected_tags.array().length>0
                match.tags = $in:selected_tags.array()
            Docs.find match,
                sort:
                    points:-1
                    _timestamp:-1
                    # "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
            
        term: ->
            # console.log @
            Docs.find 
                model:'post'
                title:@name
        
        one_result: ->
            Docs.find().count() < 2
        
        selected_tags: -> selected_tags.array()
        tag_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                Tag_results.find({ 
                    count:$lt:doc_count 
                })
            else 
                Tag_results.find()
        selected_authors: -> selected_authors.array()
        author_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                author_results.find({ 
                    count:$lt:doc_count 
                })
            else 
                author_results.find()
        selected_upvoters: -> selected_upvoters.array()
        upvoter_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                upvoter_results.find({ 
                    count:$lt:doc_count 
                })
            else 
                upvoter_results.find()

    Template.tag_selector.events
        'click .select_tag': -> 
            selected_tags.push @name
            Meteor.call 'call_wiki', @name, ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
    Template.home.events
        'click .delete': -> 
            console.log @
            Docs.remove @_id
        'click .post': ->
            new_post_id =
                Docs.insert
                    model:'post'
                    buyer_id:Meteor.userId()
                    buyer_username:Meteor.user().username
            Router.go "/post/#{new_post_id}/edit"

        
    
        'click .unselect_tag': -> 
            selected_tags.remove @valueOf()
            Meteor.call 'search_reddit', selected_tags.array(), ->
        'click #clear_tags': -> selected_tags.clear()
    
        'click .select_author': -> 
            selected_authors.push @name
        'click .unselect_author': -> selected_authors.remove @valueOf()
        'click #clear_authors': -> selected_authors.clear()
    
        'click .select_upvoter': -> 
            selected_upvoters.push @name
        'click .unselect_upvoter': -> selected_upvoters.remove @valueOf()
        'click #clear_upvoters': -> selected_upvoters.clear()
    
    
        'click .view_debit': ->
            Router.go "/debit/#{@_id}/view"

        'keydown .search_title': (e,t)->
            search = $('.search_title').val().toLowerCase().trim()
            # Session.set('query',search)
            if e.which is 13
                selected_tags.push search
                Meteor.call 'call_wiki', search, ->
                Meteor.call 'search_reddit', selected_tags.array(), ->
                Session.set('query','')
                search = $('.search_title').val('')
            if e.which is 8
                if search.legnth is 0
                    selected_tags.pop()


if Meteor.isServer
    Meteor.publish 'doc_by_title', (title)->
        # console.log title
        Docs.find
            title:title
            model:'post'
    
    
    Meteor.publish 'docs', (
        query=''
        selected_tags
        selected_authors
        selected_upvoters
        )->
        match = {}
        match.model = 'post'
        if Meteor.user()
            match.downvoter_ids = $nin:[Meteor.userId()]
        if query.length > 1
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0
            match.tags = $all:selected_tags
        if selected_authors.length > 0
            match._author_username = $all:selected_authors
        if selected_upvoters.length > 0
            match.upvoter_usernames = $all:selected_upvoters
        console.log match
        Docs.find match,
            limit:10
            sort:points:-1
                        
                        
    Meteor.publish 'tags', (
        query=''
        selected_tags
        selected_authors
        selected_upvoters
        limit=20
        )->
        self = @
        match = {}
        # match.model = $in:['post','alpha']
        match.model = 'post'
        
        if query.length > 1
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if selected_authors.length > 0 then match._author_username = $all: selected_authors
        if Meteor.user()
            match.downvoter_ids = $nin:[Meteor.userId()]
        if selected_upvoters.length > 0
            match.upvoter_usernames = $all:selected_upvoters

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        tag_cloud.forEach (tag, i) ->
            self.added 'tag_results', Random.id(),
                name: tag.name
                count: tag.count
                index: i
       
        author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_author_username": 1 }
            { $group: _id: "$_author_username", count: $sum: 1 }
            { $match: _id: $nin: selected_authors }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        author_cloud.forEach (author, i) ->
            self.added 'author_results', Random.id(),
                name: author.name
                count: author.count
                index: i
       
        upvoter_cloud = Docs.aggregate [
            { $match: match }
            { $project: "upvoter_usernames": 1 }
            { $unwind: "$upvoter_usernames" }
            { $group: _id: "$upvoter_usernames", count: $sum: 1 }
            { $match: _id: $nin: selected_upvoters }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        upvoter_cloud.forEach (upvoter, i) ->
            self.added 'upvoter_results', Random.id(),
                name: upvoter.name
                count: upvoter.count
                index: i
       
        self.ready()
                        