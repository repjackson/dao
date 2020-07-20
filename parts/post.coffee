if Meteor.isClient
    Router.route '/posts/', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'

    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'post_tickets', Router.current().params.doc_id
        

    Template.post_view.onRendered ->



    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.posts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'post'
    Template.posts.events
        'click .add_post': ->
            new_id = 
                Docs.insert
                    model:'post'
            Router.go "/post/#{new_id}/edit"
    Template.posts.helpers
        post_docs: ->
            match = {model:'post'}
            unless Meteor.user() and 'admin' in Meteor.user().roles
                match.published = true
            Docs.find match, 
                sort:
                    _timestamp:-1

    Template.post_view.onRendered ->
    Template.post_item.events
        # 'click .pick_going': ->
        #     console.log 'going'
        #     Docs.update @_id,
        #         $addToSet:
        #             going_user_ids: Meteor.userId()
        #         $pull:
        #             maybe_user_ids: Meteor.userId()
        #             not_user_ids: Meteor.userId()
    
        # 'click .pick_maybe': ->
        #     Docs.update @_id,
        #         $addToSet:
        #             maybe_user_ids: Meteor.userId()
        #         $pull:
        #             going_user_ids: Meteor.userId()
        #             not_user_ids: Meteor.userId()
    
        # 'click .pick_not': ->
        #     Docs.update @_id,
        #         $addToSet:
        #             not_user_ids: Meteor.userId()
        #         $pull:
        #             going_user_ids: Meteor.userId()
        #             maybe_user_ids: Meteor.userId()
    
    Template.post_view.events
        'click .pick_going': ->
            console.log 'going'
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    going_user_ids: Meteor.userId()
                $pull:
                    maybe_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_maybe': ->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    maybe_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
    
        'click .pick_not': ->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    not_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    maybe_user_ids: Meteor.userId()
    
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_post', @_id, =>
                    Router.go "/post/#{@_id}/view"


    Template.post_item.helpers
        
        going: ->
            post = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:post.going_user_ids
        maybe_going: ->
            post = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:post.maybe_user_ids
        not_going: ->
            post = Docs.findOne @_id
            Meteor.users.find 
                _id:$in:post.not_user_ids
    Template.post_view.helpers
        tickets_left: ->
            ticket_count = 
                Docs.find({ 
                    model:'transaction'
                    transaction_type:'ticket_purchase'
                    post_id: Router.current().params.doc_id
                }).count()
            @max_attendees-ticket_count
        tickets: ->
            Docs.find 
                model:'transaction'
                transaction_type:'ticket_purchase'
                post_id: Router.current().params.doc_id
        going: ->
            post = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:post.going_user_ids
        maybe_going: ->
            post = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:post.maybe_user_ids
        not_going: ->
            post = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$in:post.not_user_ids

if Meteor.isServer
    Meteor.publish 'post_tickets', (post_id)->
        Docs.find
            model:'transaction'
            transaction_type:'ticket_purchase'
            post_id:post_id
#     Meteor.methods
        # send_post: (post_id)->
        #     post = Docs.findOne post_id
        #     target = Meteor.users.findOne post.recipient_id
        #     gifter = Meteor.users.findOne post._author_id
        #
        #     console.log 'sending post', post
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: post.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -post.amount
        #     Docs.update post_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'

    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onRendered ->


    Template.post_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_post', @_id, =>
                    Router.go "/post/#{@_id}/view"


    Template.post_edit.helpers

if Meteor.isServer
    Meteor.methods
        send_post: (post_id)->
            post = Docs.findOne post_id
            target = Meteor.users.findOne post.recipient_id
            gifter = Meteor.users.findOne post._author_id

            console.log 'sending post', post
            Meteor.users.update target._id,
                $inc:
                    points: post.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -post.amount
            Docs.update post_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
