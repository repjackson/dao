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
        @autorun -> Meteor.subscribe 'me'
        Session.setDefault 'view_post_section', 'content'
    Template.post_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000

    Template.post_card.events
        'click .view_post': ->
            Router.go "/post/#{@_id}/view"

    Template.post_view.events
        'click .tip': ->
            Meteor.call 'tip', @_id, ->
                
            Meteor.call 'calc_post_stats', @_id, ->
            Meteor.call 'calc_user_stats', Meteor.userId(), ->
            $('body').toast({
                class: 'success'
                position: 'bottom right'
                message: "#{@title} tipped"
            })
    
    
    Template.one_post_view.events
        'click .add_tag': ->
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', @valueOf(), ->
                
            selected_tags.push @valueOf()
            # Router.go '/'
    
    
    Template.post_view.events
        'click .add_tag': ->
            # Meteor.call 'tip', @_id, ->
                
            # Meteor.call 'calc_post_stats', @_id, ->
            # Meteor.call 'calc_user_stats', Meteor.userId(), ->
            # $('body').toast({
            #     class: 'success'
            #     position: 'bottom right'
            #     message: "#{@title} tipped"
            # })
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', @valueOf(), ->

            selected_tags.push @valueOf()
            Router.go '/'
    
    

    Template.post_view.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        tippers: ->
            Meteor.users.find
                _id:$in:@tipper_ids
        
        tipper_tips: ->
            # console.log @
            Docs.find
                model:'tip'
                _author_id:@_id
        
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true




if Meteor.isServer
    Meteor.methods 
        tip: (post_id)->
            Docs.insert     
                model:'tip'
                post_id:post_id
            Docs.update post_id,
                $addToSet:
                    tipper_ids:Meteor.userId()
                    tipper_usernames:Meteor.user().username
            
        calc_post_stats: (post_id)->
            post = Docs.findOne post_id
            tip_total = 0
            
            tip_cur = 
                Docs.find 
                    model:'tip'
                    post_id:post_id
            comment_cur = 
                Docs.find 
                    model:'comment'
                    parent_id:post_id
            # for tip in tip_cur.fetch()
            #     console.log tip
            
            tip_total = 10*tip_cur.count()
            
            total_points = comment_cur.count()+tip_total
            
            
            Docs.update post_id,
                $set:
                    tip_total:tip_total
                    tip_count:tip_cur.count()
                    comment_count:comment_cur.count()
                    total_points:total_points
                    
                    
                    
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
                    
                    
                    
                    