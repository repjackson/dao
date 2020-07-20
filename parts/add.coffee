if Meteor.isClient
    Router.route '/add', (->
        @layout 'layout'
        @render 'add'
        ), name:'add'

    Template.add.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.add.onRendered ->


    Template.add.events
        'click .add_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
            Router.go "/event/#{new_id}/edit"
            
        'click .add_request': ->
            new_id = 
                Docs.insert 
                    model:'request'
            Router.go "/request/#{new_id}/edit"
            
        'click .add_shift': ->
            new_id = 
                Docs.insert 
                    model:'shift'
            Router.go "/shift/#{new_id}/edit"
            
        'click .add_gift': ->
            new_id = 
                Docs.insert 
                    model:'gift'
            Router.go "/gift/#{new_id}/edit"
            
        'click .add_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
            Router.go "/product/#{new_id}/edit"
            
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
            Router.go "/post/#{new_id}/edit"
            
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    Router.go "/event/#{@_id}/view"


    Template.add.helpers
    Template.add.events
