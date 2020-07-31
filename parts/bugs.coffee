if Meteor.isClient
    Router.route '/bugs', (->
        @layout 'layout'
        @render 'bugs'
        ), name:'bugs'




    Template.bugs.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'bug'
        @autorun => Meteor.subscribe 'all_users'
        


    Template.bug_segment.events
        'click .view_bug': ->
            Router.go "/m/bug/#{@_id}/view"
        
        
        
    Template.bugs.events
        'click .add_bug': ->
            new_id = 
                Docs.insert 
                    model:'bug'
            Router.go "/m/bug/#{new_id}/edit"
            
    Template.bugs.helpers
        bugs: ->
            ticket_count = 
                Docs.find({ 
                    model:'bug'
                }, 
                    sort:points:-1
                )
                
                
        members: ->
            Meteor.users.find()
                
                
                
                