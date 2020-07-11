if Meteor.isClient
    @selected_user_tags = new ReactiveArray []
    @selected_user_roles = new ReactiveArray []


    Router.route '/users', (->
        @render 'users'
        ), name:'users'


    Template.users.onCreated ->
        @autorun -> Meteor.subscribe 'selected_users', selected_user_tags.array()

    Template.users.helpers
        users: ->
            match = {}
            if selected_user_tags.array().length > 0 then match.tags = $all: selected_user_tags.array()
            Meteor.users.find match
            # if Meteor.user()
            #     if 'admin' in Meteor.user().roles
            #         Meteor.users.find()
            #     else
            #         Meteor.users.find(
            #             # levels:$in:['l1']
            #             levels:$in:['member']
            #         )
            # else
            #     Meteor.users.find(
            #         levels:$in:['member']
            #     )

    Template.user_item.helpers


    Template.user_item.events

    Template.addtoset_user.helpers
        ats_class: ->
            if @["#{@key}"] is @value
                console.log 'yes'
            else
                console.log 'oh god no'


    Template.addtoset_user.events
        'click .toggle_value': ->
            console.log @
            console.log Template.parentData(1)
            Meteor.users.update Template.parentData(1)._id,
                $addToSet:
                    "#{@key}": @value




    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe('user_tags',
            selected_user_tags.array()
            selected_user_roles.array()
            Session.get('view_mode')
        )
        Session.setDefault('view_mode', 'users')

    Template.user_cloud.helpers
        all_tags: ->
            user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
            if 0 < user_count < 3 then User_tags.find { count: $lt: user_count } else User_tags.find()

        selected_user_tags: ->
            # model = 'event'
            # console.log "selected_#{model}_tags"
            selected_user_tags.array()


    Template.user_cloud.events
        'click .select_tag': -> selected_user_tags.push @name
        'click .unselect_tag': -> selected_user_tags.remove @valueOf()
        'click #clear_tags': -> selected_user_tags.clear()



if Meteor.isServer
    Meteor.publish 'selected_users', (selected_user_tags)->
        match = {}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        Meteor.users.find match
        # if Meteor.user()
        #     if 'admin' in Meteor.user().roles
        #         Meteor.users.find()
        #     else
        #         Meteor.users.find(
        #             # levels:$in:['l1']
        #             roles:$in:['member']
        #         )
        # else
        #     Meteor.users.find(
        #         levels:$in:['member']
        #     )



    Meteor.publish 'user_tags', (
        selected_user_tags,
        view_mode
        limit
    )->
        self = @
        match = {}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        # match.model = 'item'
        # if view_mode is 'users'
        #     match.bought = $ne:true
        #     match._author_id = $ne: Meteor.userId()
        # if view_mode is 'bought'
        #     match.bought = true
        #     match.buyer_id = Meteor.userId()
        # if view_mode is 'selling'
        #     match.bought = $ne:true
        #     match._author_id = Meteor.userId()
        # if view_mode is 'sold'
        #     match.bought = true
        #     match._author_id = Meteor.userId()

        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_user_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (user_tag, i) ->
            self.added 'user_tags', Random.id(),
                name: user_tag.name
                count: user_tag.count
                index: i

        self.ready()
