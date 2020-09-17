if Meteor.isClient
    # @selected_overlap_tags = new ReactiveArray []

    # Template.user_dashboard.onCreated ->
    #     Session.setDefault('target_username','')
    #     @autorun -> Meteor.subscribe('overlap_tags',
    #         Session.get('query')
    #         selected_overlap_tags.array()
    #         Session.get('target_username')
    #         # Router.current().params.username
    #         )
    #     @autorun -> Meteor.subscribe('overlap_docs',
    #         Session.get('query')
    #         selected_overlap_tags.array()
    #         Session.get('target_username')
    #         # Router.current().params.username
    #         )

    
        
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'expenses_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'debit'
        # @autorun -> Meteor.subscribe 'model_docs', 'message'
    
    Template.profile.onRendered ->
        # Meteor.setTimeout ->
        #     $('.profile_nav_item')
        #         .popup()
        # , 1000
        # Meteor.call 'calc_user_stats', user._id, ->
        # Meteor.setTimeout ->
        #     user = Meteor.users.findOne(username:Router.current().params.username)
        #     if user
        #         Meteor.call 'calc_user_stats', user._id, ->
        #         Meteor.call 'calc_authored_tags', user._id, ->
        #         Meteor.call 'calc_upvoted_tags', user._id, ->
        #         Meteor.call 'calc_credit_tags', user._id, ->
        # , 2000


    # Template.user_dashboard.events
    #     'click .select_tag': ->
    #         console.log @
    #         Meteor.call 'call_wiki', @title, ->
    #         Meteor.call 'search_reddit', @title, ->
                
    #         selected_tags.push @title
    #         Router.go '/'
    #     'click .select_user': ->
    #         Session.set('target_username', @username)

    #     'keyup .new_post': (e,t)->
    #         if e.which is 13
    #             val = t.$('.new_post').val()
    #             user = Meteor.users.findOne(username:Router.current().params.username)
    #             Docs.insert
    #                 model:'message'
    #                 type:'wall_post'
    #                 recipient_id:user._id
    #                 text:val

    Template.profile.helpers
        # route_slug: -> "user_#{@slug}"
        user: -> Meteor.users.findOne username:Router.current().params.username
        expenses: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'vote'
                _author_id:user._id
   
   
    Template.votes_in.onCreated ->
        @autorun => Meteor.subscribe 'votes_in', Router.current().params.username
    Template.votes_in.helpers
        votes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'vote'
                # points:$gt:0
                post_author_id:user._id
  
    Template.votes_out.onCreated ->
        @autorun => Meteor.subscribe 'votes_out', Router.current().params.username
    Template.votes_out.helpers
        votes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'vote'
                # points:$gt:0
                _author_id:user._id
  
  
  
    Template.profile.events
        'click .refresh_user_stats': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.call 'calc_user_stats', user._id, ->
            # Meteor.call 'calc_user_stats', user._id, ->
            # Meteor.call 'calc_user_tags', user._id, ->
            Meteor.call 'calc_authored_tags', user._id, ->
            Meteor.call 'calc_upvoted_tags', user._id, ->
            Meteor.call 'calc_credit_tags', user._id, ->

    Template.profile.events
        'click .send': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            if Meteor.userId() is user._id
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        price:10
            else
                new_debit_id =
                    Docs.insert
                        model:'debit'
                        price:10
                        seller_id: user._id
            Router.go "/debit/#{new_debit_id}/edit"

        # 'click .calc_user_cloud': ->
        #     Meteor.call 'calc_user_cloud', Router.current().params.username, ->

        'click .logout': ->
            # Router.go '/login'
            # Session.set 'logging_out', true
            Meteor.logout()
            # Session.set 'logging_out', false




if Meteor.isServer
    Meteor.publish 'votes_in', (username)->
        user = Meteor.users.findOne username:username
        Docs.find    
            model:'vote'
            post_author_id:user._id
        
    Meteor.publish 'votes_out', (username)->
        user = Meteor.users.findOne username:username
        Docs.find    
            model:'vote'
            _author_id:user._id
        
        
        