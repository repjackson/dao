
if Meteor.isClient
    # @selected_keys = new ReactiveArray []
    @selected_tags = new ReactiveArray []
    # @selected_models = new ReactiveArray []
    # @selected_sellers = new ReactiveArray []
    # @selected_buyers = new ReactiveArray []
    # @selected_statuses = new ReactiveArray []
    # @selected_location_tags = new ReactiveArray []
    
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
            Meteor.call 'call_watson', Router.current().params.doc_id, 'html', 'html', ->
                Meteor.call 'call_tone', Router.current().params.doc_id, 'html', 'html', ->


    Template.home.onCreated ->
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_direction', -1
        @autorun -> Meteor.subscribe('me')
        @autorun -> Meteor.subscribe('tags',
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('query')
            selected_tags.array()
            )
        @autorun -> Meteor.subscribe('docs',
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('query')
            selected_tags.array()
            )

        
    Template.sort_button.events
        'click .toggle_sort': ->
            Session.set('sort_key',@key)
            if Session.equals('sort_direction', 1)
                Session.set('sort_direction', -1)
            else
                Session.set('sort_direction', 1)


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

            
    Template.sort_button.helpers
        is_selected: -> 
            Session.equals('sort_key', @key)
        sorting_up: -> 
            Session.equals('sort_direction', 1)
        sort_button_class: ->
            if Session.equals('sort_key', @key) then 'black' else 'basic'
    Template.home.helpers
        selected_tags_plural: -> selected_tags.array().length > 1
        one_post: -> Docs.find().count() is 1
    
        two_posts: -> Docs.find().count() is 2
        three_posts: -> Docs.find().count() is 3
        four_posts: -> Docs.find().count() is 4
        five_posts: -> Docs.find().count() is 5
        six_posts: -> Docs.find().count() is 6
        seven_posts: -> Docs.find().count() is 7
        eight_posts: -> Docs.find().count() is 8
        nine_posts: -> Docs.find().count() is 9
        ten_posts: -> Docs.find().count() is 10
        more_than_ten: -> Docs.find().count() > 10
        one_result: ->
            Docs.find().count() is 1
    
        # show_to: ->
        #     selected_sellers.array().length > 0 or seller_results.find({}).count() > 0
    
        # show_from: ->
        #     selected_buyers.array().length > 0 or buyer_results.find({}).count() > 0
    
        can_debit: -> Meteor.user().points > 0
        docs: ->
            Docs.find {
                # model:$in:['debit','order','request','offer','post','alpha']
                model:$in:['post','alpha']
            },
                sort:
                    "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
        # friends: ->
        #     if Meteor.user()
        #         Meteor.users.find({_id:$in:Meteor.user().friend_ids},
        #             sort:points:1)
            
        selected_tags: -> selected_tags.array()
        # selected_sellers: -> selected_sellers.array()
        # selected_user: ->
        #     # console.log @
        #     Meteor.users.findOne username:@valueOf()
        # user_ob: ->
        #     Meteor.users.findOne username:@name
        
        one_result: ->
            Docs.find().count() < 2
        
        # selected_models: -> selected_models.array()
        tag_results: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 
                Tag_results.find({ 
                    count:$lt:doc_count 
                })
            else 
                Tag_results.find()

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

        
        'click .select_tag': -> 
            selected_tags.push @name
            Meteor.call 'call_wiki', @name, ->
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()
    
    
        'click .view_debit': ->
            Router.go "/debit/#{@_id}/view"

        'keydown .search_title': (e,t)->
            search = $('.search_title').val()
            Session.set('query',search)
            if e.which is 13
                selected_tags.push search
                Meteor.call 'call_wiki', search, ->
                Session.set('query','')
                search = $('.search_title').val('')
            if e.which is 8
                if search.legnth is 0
                    selected_tags.pop()


if Meteor.isServer
    Meteor.publish 'docs', (
        sort_key='_timestamp'
        sort_direction=1
        query=''
        # selected_models
        selected_tags
        )->
        match = {}
        # if selected_models.length > 0 
        #     match.model = $all: selected_models
        # else
            # match.model = $in:['debit','order','request','offer','post','alpha']
        match.model = $in:['post','alpha']
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0
            match.tags = $all:selected_tags
        console.log match
        Docs.find match,
            limit:4
            sort:"#{sort_key}":sort_direction
                        
                        
    Meteor.publish 'tags', (
        sort_key
        sort_direction
        query=''
        # selected_models
        selected_tags
        limit=20
        )->
        self = @
        match = {}
        # match.model = $in:['post','alpha']
        match.model = $in:['post']
        
        if query.length > 0
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_tags.length > 0 then match.tags = $all: selected_tags

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 33 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
        tag_cloud.forEach (tag, i) ->
            self.added 'tag_results', Random.id(),
                name: tag.name
                count: tag.count
                index: i
       
        self.ready()
                        