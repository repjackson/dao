if Meteor.isClient
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'



    Template.post_view.onCreated ->
        @autorun -> Meteor.subscribe 'post_tips', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.post_view.events
        'click .tip': ->
            Docs.insert     
                model:'tip'
                post_id:@_id
                

    Template.post_view.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true




if Meteor.isServer
    Meteor.publish 'post_tips', (post_id)->
        Docs.find   
            model:'tip'
            post_id:post_id
    
    
if Meteor.isClient
    Template.post_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.post_edit.events
        'click .delete_post': ->
            Swal.fire({
                title: "delete post?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'post removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )




    Template.post_edit.helpers
    Template.post_edit.events

if Meteor.isServer
    Meteor.methods
        publish_post: (post_id)->
            post = Docs.findOne post_id
            # target = Meteor.users.findOne post.recipient_id
            author = Meteor.users.findOne post._author_id

            console.log 'publishing post', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.price
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
                    
                    