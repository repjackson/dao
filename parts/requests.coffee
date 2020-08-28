if Meteor.isClient
    Router.route '/requests', (->
        @layout 'layout'
        @render 'requests'
        ), name:'requests'
    Template.requests.onCreated ->
        @autorun -> Meteor.subscribe 'request_tags', 
            Session.get('request_search')
            selected_request_tags.array()
            Session.get 'request_limit'
            
        @autorun => Meteor.subscribe 'requests',
            Session.get('request_search')
            selected_request_tags.array()
        
        
    @selected_request_tags = new ReactiveArray []
        
        
    Template.requests.events
        'click .add_request': ->
            new_id = 
                Docs.insert 
                    model:'request'
            Router.go "/request/#{new_id}/edit"
        
        'keyup .request_title': (e,t)->
            query = $('.request_title').val()
            Session.set('request_search', query)
        'click .select_request_tag': -> selected_request_tags.push @name
        'click .unselect_request_tag': -> selected_request_tags.remove @valueOf()
        'click #clear_request_tags': -> selected_request_tags.clear()

    Template.requests.helpers
        requests: ->
            Docs.find 
                model:'request'
                complete:$ne:true
                published:true
        
        request_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Request_tags.find { count: $lt: doc_count } else Request_tags.find()


    Template.request_item.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    Template.request_item.events
        'click .request_item': ->
            Router.go "/request/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1



if Meteor.isServer
    Meteor.publish 'request_tags', (
        selected_request_tags
        filter
        limit
        )->
        self = @
        match = {model:'request'}
        if selected_request_tags.length > 0 then match.tags = $all: selected_request_tags
        if limit
            console.log 'limit', limit
            calc_limit = limit
        else
            calc_limit = 20
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_request_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: calc_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (tag, i) ->
            self.added 'request_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()