if Meteor.isClient
    @selected_tags = new ReactiveArray []
    @selected_models = new ReactiveArray []
    @selected_authors = new ReactiveArray []
    @selected_location_tags = new ReactiveArray []
    
    Template.body.events
        'click a:not(.select_term)': ->
            unless Meteor.user().invert_class is 'invert'
                $('.global_container')
                .transition('fade out', 200)
                .transition('fade in', 200)

    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_direction', 1
        @autorun -> Meteor.subscribe('tags',
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('query')
            selected_models.array()
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )
        @autorun -> Meteor.subscribe('docs',
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('query')
            selected_models.array()
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )

        
    Template.home.helpers
        sorting_up: -> Session.equals('sort_direction',1)
        can_debit: -> Meteor.user().points > 0
        docs: ->
            Docs.find {
                # model:$in:selected_models.array()
            },
                sort:
                    "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
        friends: ->
            if Meteor.user()
                Meteor.users.find({_id:$in:Meteor.user().friend_ids},
                    sort:points:1)
            
        selected_tags: -> selected_tags.array()
        selected_authors: -> selected_authors.array()
        selected_models: -> selected_models.array()
        tag_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tag_results.find { count: $lt: doc_count } else Tag_results.find()
        model_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Model_results.find { count: $lt: doc_count } else Model_results.find()
        author_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Author_results.find { count: $lt: doc_count } else Author_results.find()

    Template.home.events
        'click .delete': -> 
            console.log @
            Docs.remove @_id
        
        
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()
    
        'click .select_author': -> selected_authors.push @name
        'click .unselect_author': -> selected_authors.remove @valueOf()
        'click #clear_authors': -> selected_authors.clear()
    
        'click .select_model': -> selected_models.push @name
        'click .unselect_model': -> selected_models.remove @valueOf()
        'click #clear_models': -> selected_models.clear()
    
        'click .view_debit': ->
            Router.go "/debit/#{@_id}/view"
        'click .view_request': ->
            Router.go "/request/#{@_id}/view"
        'click .view_offer': ->
            Router.go "/offer/#{@_id}/view"

        'click .refresh_stats': ->
            Meteor.call 'calc_global_stats'
        # 'click .debit': ->
        #     new_debit_id =
        #         Docs.insert
        #             model:'debit'
        #     Router.go "/debit/#{new_debit_id}/edit"
        # 'click .request': ->
        #     new_request_id =
        #         Docs.insert
        #             model:'request'
        #     Router.go "/request/#{new_request_id}/edit"
        # 'click .offer': ->
        #     new_offer_id =
        #         Docs.insert
        #             model:'offer'
        #     Router.go "/offer/#{new_offer_id}/edit"
        
        'click .when': ->
            Session.set('sort_key', '_timestamp')
        'click .price': ->
            Session.set('sort_key', 'price')
        'click .title': ->
            Session.set('sort_key', 'title')
        'click .sort_down': ->
            Session.set('sort_direction', -1)
        'click .sort_up': ->
            Session.set('sort_direction', 1)

        'keydown .search_title': (e,t)->
            search = $('.search_title').val()
            Session.set('query',search)



if Meteor.isServer
    Meteor.publish 'docs', (
        sort_key
        sort_direction
        query=''
        selected_models
        selected_tags
        selected_location_tags
        selected_authors
        )->
        match = {}
        if selected_models.length > 0 then match.model = $all: selected_models
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0
            match.tags = $in:selected_tags
        if selected_authors.length > 0
            match._author_username = $in:selected_authors
        console.log sort_key
        console.log sort_direction
        Docs.find match,
            limit:20
            "#{sort_key}":sort_direction
                        
                        
    Meteor.publish 'tags', (
        sort_key
        sort_direction
        query=''
        selected_models
        selected_tags
        selected_location_tags
        selected_authors
        limit=20
        )->
        self = @
        match = {}
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if selected_models.length > 0 then match.model = $all: selected_models
        if selected_authors.length > 0 then match._author_username = $all: selected_authors
        
        
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        tag_cloud.forEach (tag, i) ->
            self.added 'tag_results', Random.id(),
                name: tag.name
                count: tag.count
                index: i
       
        model_cloud = Docs.aggregate [
            { $match: match }
            { $project: "model": 1 }
            { $group: _id: "$model", count: $sum: 1 }
            { $match: _id: $nin: selected_models }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        model_cloud.forEach (model, i) ->
            self.added 'model_results', Random.id(),
                name: model.name
                count: model.count
                index: i
       
        author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_author_username": 1 }
            { $group: _id: "$_author_username", count: $sum: 1 }
            { $match: _id: $nin: selected_authors }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        author_cloud.forEach (model, i) ->
            self.added 'author_results', Random.id(),
                name: model.name
                count: model.count
                index: i

        self.ready()
                        