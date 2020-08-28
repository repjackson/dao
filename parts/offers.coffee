if Meteor.isClient
    Router.route '/offers', (->
        @layout 'layout'
        @render 'offers'
        ), name:'offers'
        
    @selected_offer_tags = new ReactiveArray []

    Template.offers.onCreated ->
        @autorun -> Meteor.subscribe 'offer_tags', 
            Session.get('offer_search')
            selected_offer_tags.array()
            Session.get 'offer_limit'
        
        @autorun => Meteor.subscribe 'offers',
            Session.get('offer_search')
            selected_offer_tags.array()
    
    Template.offers.events
        'click .add_offer': ->
            new_id = 
                Docs.insert 
                    model:'offer'
            Router.go "/offer/#{new_id}/edit"
            
            
        'keyup .offer_title': (e,t)->
            query = $('.offer_title').val()
            Session.set('offer_search', query)
        'click .select_offer_tag': -> selected_offer_tags.push @name
        'click .unselect_offer_tag': -> selected_offer_tags.remove @valueOf()
        'click #clear_offer_tags': -> selected_offer_tags.clear()

            
    Template.offers.helpers
        offers: ->
            Docs.find {
                model:'offer'
                },
                    sort:_timestamp:-1
                # complete:$ne:true
                # published:true
                
        selected_offer_tags: -> selected_offer_tags.array()
            
        offer_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Offer_tags.find { count: $lt: doc_count } else Offer_tags.find()

    Template.offer_item.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    Template.offer_item.events
        'click .offer_item': ->
            Router.go "/offer/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1



if Meteor.isServer
    Meteor.publish 'offer_tags', (
        query
        selected_offer_tags
        limit=20
        )->
        self = @
        match = {model:'offer'}
        if selected_offer_tags.length > 0 then match.tags = $all: selected_offer_tags
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_offer_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (tag, i) ->
            self.added 'offer_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()