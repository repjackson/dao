if Meteor.isClient
    Router.route '/tribes', (->
        @layout 'layout'
        @render 'tribes'
        ), name:'tribes'
    Router.route '/tribe/:doc_id/view', (->
        @layout 'layout'
        @render 'tribe_view'
        ), name:'tribe_view'
    Router.route '/tribe/:doc_id/edit', (->
        @layout 'layout'
        @render 'tribe_edit'
        ), name:'tribe_edit'


    Template.tribes.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'tribe'
    Template.tribes.helpers
        tribe_docs: ->
            Docs.find 
                model:'tribe'
    Template.tribes.events 
        'click .add_tribe': ->
            new_id = 
                Docs.insert 
                    model:'tribe'
            Router.go "/tribe/#{new_id}/edit"        
            
            
    Template.tribe_view.onCreated ->
        @autorun -> Meteor.subscribe 'tribe_tips', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'tribe_posts', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'me'
        Session.setDefault 'view_tribe_section', 'content'
    Template.tribe_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
    Template.tribe_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000


    Template.tribe_card.events
        'click .view_tribe': ->
            Router.go "/tribe/#{@_id}/view"

    Template.tribe_view.events
        'click .add_tribe_post': ->
            new_id = 
                Docs.insert
                    model:'post'
                    tribe_id:@_id
            Router.go "/post/#{new_id}/edit"
        'click .tip': ->
            if Meteor.user()
                Meteor.call 'tip', @_id, ->
                    
                Meteor.call 'calc_tribe_stats', @_id, ->
                Meteor.call 'calc_user_stats', Meteor.userId(), ->
                $('body').toast({
                    class: 'success'
                    position: 'bottom right'
                    message: "#{@title} tipped"
                })
            else 
                Router.go '/login'
    
    
    # Template.one_tribe_view.events
    #     'click .add_tag': ->
    #         selected_tags.push @valueOf()
    #         Meteor.call 'call_wiki', @valueOf(), ->
    #         Meteor.call 'search_reddit', selected_tags.array(), ->
                
    #         # Router.go '/'
    
    
    Template.tribe_view.events
        'click .add_tag': ->
            # Meteor.call 'tip', @_id, ->
                
            # Meteor.call 'calc_tribe_stats', @_id, ->
            # Meteor.call 'calc_user_stats', Meteor.userId(), ->
            # $('body').toast({
            #     class: 'success'
            #     position: 'bottom right'
            #     message: "#{@title} tipped"
            # })
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->

            Router.go '/'
    
    
    Template.join.helpers
        is_member: ->
            Meteor.userId() in @member_ids
    
    Template.join.events 
        'click .join':->
            Docs.update 
                $addToSet:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        'click .leave':->
            Docs.update 
                $pull:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        


    Template.tribe_view.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        tribe_posts: ->
            Docs.find   
                model:'post'
                tribe_id:@_id
        
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
                    
                    
    Meteor.publish 'tribe_posts', (tribe_id)->
        Docs.find   
            model:'post'
            tribe_id:tribe_id
    
    Meteor.publish 'tribe_tips', (tribe_id)->
        Docs.find   
            model:'tip'
            tribe_id:tribe_id
    
    Meteor.publish 'tribe_votes', (tribe_id)->
        Docs.find   
            model:'vote'
            parent_id:tribe_id
    
    
if Meteor.isClient
    Template.tribe_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.tribe_edit.events
        'click .delete_tribe': ->
            Swal.fire({
                title: "delete tribe?"
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
                        title: 'tribe removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )




    Template.tribe_edit.helpers
    Template.tribe_edit.events

if Meteor.isServer
    Meteor.methods
        publish_tribe: (tribe_id)->
            tribe = Docs.findOne tribe_id
            # target = Meteor.users.findOne tribe.recipient_id
            author = Meteor.users.findOne tribe._author_id

            console.log 'publishing tribe', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.price
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
                    
                    