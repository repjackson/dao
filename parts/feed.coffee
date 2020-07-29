if Meteor.isClient
    Router.route '/feed', (->
        @layout 'layout'
        @render 'feed'
        ), name:'feed'




    Template.feed.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'post'
        @autorun => Meteor.subscribe 'all_users'
        


    Template.feed.events
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
            Router.go "/post/#{new_id}/edit"
            
    Template.feed.helpers
        posts: ->
            ticket_count = 
                Docs.find({ 
                    model:'post'
                })
                
                
        members: ->
            Meteor.users.find()
                
                
                
                