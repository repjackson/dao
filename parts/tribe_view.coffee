if Meteor.isClient
    Template.tribe_view.onCreated ->
        @autorun -> Meteor.subscribe 'tribe_tips', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'tribe_events', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'tribe_posts', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'tribe_badges', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'tribe_docs', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'me'
        Session.setDefault 'view_tribe_section', 'images'
    Template.tribe_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000


    Template.tribe_badges.helpers
        badges: ->
            Docs.find 
                model:'badge'
                # tribe_id:@tribe_id
    Template.tribe_badges.events
        'click .add_badge': ->
            new_id = 
                Docs.insert
                    model:'badge'
                    tribe_id:@_id
            Router.go "/m/badge/#{new_id}/edit"
    
    Template.tribe_events.helpers
        events: ->
            Docs.find 
                model:'event'
                # tribe_id:@tribe_id
    Template.tribe_events.events
        'click .add_event': ->
            new_id = 
                Docs.insert
                    model:'event'
                    tribe_id:@_id
            Router.go "/m/event/#{new_id}/edit"
    
    
    
    Template.tribe_finance.helpers
        events: ->
            Docs.find 
                model:'event'
                # tribe_id:@tribe_id
    Template.tribe_finance.events
        'click .calc_tribe_finance': ->
            Meteor.call 'calc_tribe_finance', Router.current().params.doc_id, ->
                
    
    
    
    Template.tribe_view.events
        'click .add_tribe_post': ->
            new_id = 
                Docs.insert
                    model:'post'
                    tribe_id:@_id
            Router.go "/m/post/#{new_id}/edit"
        'click .add_tribe_gift': ->
            new_id = 
                Docs.insert
                    model:'debit'
                    tribe_id:@_id
            Router.go "/m/debit/#{new_id}/edit"
        'click .add_tribe_request': ->
            new_id = 
                Docs.insert
                    model:'request'
                    tribe_id:@_id
            Router.go "/m/request/#{new_id}/edit"
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
    
    Template.tribe_view.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        tribe_posts: ->
            Docs.find   
                model:'post'
                tribe_id:@_id
        
        latest_photos: ->
            Docs.find   
                model:'post'
                tribe_id:@_id
        
        latest_updates: ->
            Docs.find {
                tribe_id:@_id
            }, sort: _timestamp:-1
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
    

if Meteor.isServer
    Meteor.methods 
        calc_tribe_finance: (tribe_id)->
            tribe = Docs.findOne tribe_id
            child_doc_count = 
                Docs.find(
                    tribe_id:tribe_id
                ).count()
            Docs.update tribe_id, 
                $set:total_child_docs:child_doc_count
    
    
    Meteor.publish 'tribe_docs', (tribe_id)->
        Docs.find
            tribe_id:tribe_id