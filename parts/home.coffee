if Meteor.isClient
    @selected_tags = new ReactiveArray []
    @selected_models = new ReactiveArray []
    @selected_sellers = new ReactiveArray []
    @selected_buyers = new ReactiveArray []
    @selected_statuses = new ReactiveArray []
    @selected_location_tags = new ReactiveArray []
    
    Template.body.events
        'click a:not(.select_term)': ->
            # unless Meteor.user().invert_class is 'invert'
            $('.global_container')
            .transition('fade out', 200)
            .transition('fade in', 200)

    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_direction', -1
        @autorun -> Meteor.subscribe('tags',
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('query')
            selected_models.array()
            selected_tags.array()
            selected_location_tags.array()
            selected_sellers.array()
            selected_buyers.array()
            selected_statuses.array()
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
            selected_sellers.array()
            selected_buyers.array()
            selected_statuses.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )

        
    Template.sort_button.events
        'click .toggle_sort': ->
            Session.set('sort_key',@key)
            if Session.equals('sort_direction', 1)
                Session.set('sort_direction', -1)
            else
                Session.set('sort_direction', 1)

            
    Template.sort_button.helpers
        is_selected: -> 
            Session.equals('sort_key', @key)
        sorting_up: -> 
            Session.equals('sort_direction', 1)
        sort_button_class: ->
            if Session.equals('sort_key', @key) then 'black' else 'basic'
    Template.home.helpers
        show_to: ->
            selected_sellers.array().length > 0 or seller_results.find({}).count() > 0
    
        show_from: ->
            selected_buyers.array().length > 0 or buyer_results.find({}).count() > 0
    
        can_debit: -> Meteor.user().points > 0
        docs: ->
            Docs.find {
                # model:$in:selected_models.array()
            },
                sort:
                    "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
        # friends: ->
        #     if Meteor.user()
        #         Meteor.users.find({_id:$in:Meteor.user().friend_ids},
        #             sort:points:1)
            
        selected_tags: -> selected_tags.array()
        selected_sellers: -> selected_sellers.array()
        selected_user: ->
            # console.log @
            Meteor.users.findOne username:@valueOf()
        user_ob: ->
            Meteor.users.findOne username:@name
        
        one_result: ->
            Docs.find().count() < 2
        
        selected_models: -> selected_models.array()
        tag_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                Tag_results.find({ 
                    count:$lt:doc_count 
                })
            else 
                Tag_results.find()
        model_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                Model_results.find { 
                    name:$in:['debit','order','request','offer']
                    count: $lt: doc_count 
                } 
            else 
                Model_results.find({name:$in:['debit','order','request','offer','post']})
        seller_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then seller_results.find { count: $lt: doc_count } else seller_results.find()
        selected_buyers: -> selected_buyers.array()
        buyer_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then buyer_results.find { count: $lt: doc_count } else buyer_results.find()
       
       
        selected_statuses: -> selected_statuses.array()
        status_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then status_results.find { count: $lt: doc_count } else status_results.find()

    Template.home.events
        'click .delete': -> 
            console.log @
            Docs.remove @_id
        
        
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()
    
        'click .select_seller': -> selected_sellers.push @name
        'click .unselect_seller': -> selected_sellers.remove @valueOf()
        'click #clear_sellers': -> selected_sellers.clear()
    
        'click .select_buyer': -> selected_buyers.push @name
        'click .unselect_buyer': -> selected_buyers.remove @valueOf()
        'click #clear_buyers': -> selected_buyers.clear()
    
        'click .select_model': -> selected_models.push @name
        'click .unselect_model': -> selected_models.remove @valueOf()
        'click #clear_models': -> selected_models.clear()
    
        'click .select_status': -> selected_statuses.push @name
        'click .unselect_status': -> selected_statuses.remove @valueOf()
        'click #clear_statuses': -> selected_statuses.clear()
    
        'click .view_debit': ->
            Router.go "/debit/#{@_id}/view"
        'click .view_request': ->
            Router.go "/request/#{@_id}/view"

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
        

        'keydown .search_title': (e,t)->
            search = $('.search_title').val()
            Session.set('query',search)



if Meteor.isServer
    Meteor.publish 'docs', (
        sort_key='_timestamp'
        sort_direction=1
        query=''
        selected_models
        selected_tags
        selected_location_tags
        selected_sellers
        selected_buyers
        selected_statuses
        )->
        match = {}
        if selected_models.length > 0 
            match.model = $all: selected_models
        else
            match.model = $in:['debit','order','request','offer','post']
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0
            match.tags = $in:selected_tags
        if selected_sellers.length > 0
            match.seller_username = $in:selected_sellers
        if selected_buyers.length > 0
            match.buyer_username = $in:selected_buyers
        if selected_statuses.length > 0 then match.status = $all: selected_statuses
        # match.private = $ne:true
        # match["$or"] = 
        #     [ 
        #         { private: $ne: true }, 
        #         { viewable_user_ids: $in:[Meteor.userId()] } 
        #     ]
        # friended_by = 
        #     Meteor.users.find(
        #         {friend_ids:[Meteor.userId()]},
        #         fields:
        #             _id:1
        #     ).fetch()
        # console.log 'friended by',friended_by     
        # plucked_ids = _.pluck friended_by, '_id'

        # match._author_id = $in:plucked_ids
        # console.log plucked_ids
        # console.log sort_direction
        # console.log match
        Docs.find match,
            limit:10
            sort:"#{sort_key}":sort_direction
                        
                        
    Meteor.publish 'tags', (
        sort_key
        sort_direction
        query=''
        selected_models
        selected_tags
        selected_location_tags
        selected_sellers
        selected_buyers
        selected_statuses
        limit=10
        )->
        self = @
        match = {}
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if selected_models.length > 0 then match.model = $all: selected_models
        if selected_sellers.length > 0 then match.seller_username = $all: selected_sellers
        if selected_buyers.length > 0 then match.buyer_username = $all: selected_buyers
        if selected_statuses.length > 0 then match.status = $all: selected_statuses
        # match["$or"] = 
        #     [ 
        #         { private: $ne: true }, 
        #         { viewable_user_ids: $in:[Meteor.userId()] } 
        #     ]
        # friended_by = 
        #     Meteor.users.find(
        #         {friend_ids:[Meteor.userId()]},
        #         fields:
        #             _id:1
        #     ).fetch()
        # console.log 'friended by',friended_by     
        # plucked_ids = _.pluck friended_by, '_id'

        # match._author_id = $in:plucked_ids

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
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
       
        seller_cloud = Docs.aggregate [
            { $match: match }
            { $project: "seller_username": 1 }
            { $group: _id: "$seller_username", count: $sum: 1 }
            { $match: _id: $nin: selected_sellers }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        seller_cloud.forEach (seller, i) ->
            self.added 'seller_results', Random.id(),
                name: seller.name
                count: seller.count
                index: i
        
        status_cloud = Docs.aggregate [
            { $match: match }
            { $group: _id: "$status", count: $sum: 1 }
            { $match: _id: $nin: selected_statuses }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        status_cloud.forEach (status, i) ->
            self.added 'status_results', Random.id(),
                name: status.name
                count: status.count
                index: i
        
        buyer_cloud = Docs.aggregate [
            { $match: match }
            { $project: "buyer_username": 1 }
            { $group: _id: "$buyer_username", count: $sum: 1 }
            { $match: _id: $nin: selected_buyers }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        buyer_cloud.forEach (buyer, i) ->
            self.added 'buyer_results', Random.id(),
                name: buyer.name
                count: buyer.count
                index: i

        self.ready()
                        