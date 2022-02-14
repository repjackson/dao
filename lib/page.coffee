if Meteor.isClient
    Template.page.onCreated ->
        @autorun => @subscribe 'page_doc', @data.key, ->
        
        
    Template.page.events
        'click .create_doc': ->
            Docs.insert 
                model:'page'
                key:@key
                
                
    Template.page.helpers
        page_doc: ->
            Docs.findOne 
                model:'page'
                key:@key
        
if Meteor.isServer 
    Meteor.publish 'page_doc', (key)->
        Docs.find 
            model:'page'
            key:key