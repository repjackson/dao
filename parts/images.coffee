if Meteor.isClient
    Router.route '/pictures', (->
        @layout 'layout'
        @render 'pictures'
        ), name:'pictures'
    Router.route '/picture/:doc_id/view', (->
        @layout 'layout'
        @render 'picture_view'
        ), name:'picture_view'
    Router.route '/picture/:doc_id/edit', (->
        @layout 'layout'
        @render 'picture_edit'
        ), name:'picture_edit'


    Template.pictures.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'picture'
    Template.pictures.helpers
        picture_docs: ->
            Docs.find 
                model:'picture'
    Template.pictures.events 
        'click .picture': ->
            new_id = 
                Docs.insert 
                    model:'picture'
            Router.go "/picture/#{new_id}/edit"        
            
            
    Template.picture_view.onCreated ->
        @autorun -> Meteor.subscribe 'picture_tips', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'picture_posts', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'me'
        Session.setDefault 'picture_section', 'content'
    Template.picture_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
    Template.picture_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000


    Template.picture_card.events
        'click .picture': ->
            Router.go "/picture/#{@_id}/view"

    Template.picture_view.events
        'click .picture_post': ->
            new_id = 
                Docs.insert
                    model:'post'
                    picture_id:@_id
            Router.go "/post/#{new_id}/edit"
        'click .tip': ->
            if Meteor.user()
                Meteor.call 'tip', @_id, ->
                    
                Meteor.call 'picture_stats', @_id, ->
                Meteor.call 'calc_user_stats', Meteor.userId(), ->
                $('body').toast({
                    class: 'success'
                    position: 'bottom right'
                    message: "#{@title} tipped"
                })
            else 
                Router.go '/login'
    
    
    # Template.picture_view.events
    #     'click .add_tag': ->
    #         selected_tags.push @valueOf()
    #         Meteor.call 'call_wiki', @valueOf(), ->
    #         Meteor.call 'search_reddit', selected_tags.array(), ->
                
    #         # Router.go '/'
    
    
    Template.picture_view.events
        'click .add_tag': ->
            # Meteor.call 'tip', @_id, ->
                
            # Meteor.call 'picture_stats', @_id, ->
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
        


    Template.picture_view.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        picture_posts: ->
            Docs.find   
                model:'post'
                picture_id:@_id
        
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
                    
                    
    Meteor.publish 'picture_posts', (picture_id)->
        Docs.find   
            model:'post'
            picture_id:picture_id
    
    Meteor.publish 'picture_tips', (picture_id)->
        Docs.find   
            model:'tip'
            picture_id:picture_id
    
    Meteor.publish 'picture_votes', (picture_id)->
        Docs.find   
            model:'vote'
            parent_id:picture_id
    
    
if Meteor.isClient
    Template.picture_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.picture_edit.events
        'click .picture': ->
            Swal.fire({
                title: "delete picture?"
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
                        title: 'picture removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )




    Template.picture_edit.helpers
    Template.picture_edit.events

if Meteor.isServer
    Meteor.methods
        picture: (picture_id)->
            picture = Docs.findOne picture_id
            # target = Meteor.users.findOne picture.recipient_id
            author = Meteor.users.findOne picture._author_id

            console.log 'publishing picture', offer
            Meteor.users.update author._id,
                $inc:
                    points: -offer.price
            Docs.update offer_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
                    
                    