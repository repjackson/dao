if Meteor.isClient
    Router.route '/locations/', (->
        @layout 'layout'
        @render 'locations'
        ), name:'locations'
    Router.route '/location/:doc_id/view', (->
        @layout 'layout'
        @render 'location_view'
        ), name:'location_view'

    Template.location_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        @autorun => Meteor.subscribe 'location_template_from_location_id', Router.current().params.doc_id

    Template.locations.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'location'
        @autorun => Meteor.subscribe 'model_docs', 'location_template'
    Template.locations.events
        'click .add_location': ->
            new_id = 
                Docs.insert
                    model:'location'
            Router.go "/location/#{new_id}/edit"
        'click .add_location_template': ->
            new_id = 
                Docs.insert
                    model:'location_template'
            Router.go "/location_template/#{new_id}/edit"
  
    Template.locations.helpers
        locations: ->
            Docs.find {model:'location'}, 
                sort:
                    start_datetime:-1



    Template.location_view.onRendered ->
        @autorun => Meteor.subscribe 'users'
        @autorun => Meteor.subscribe 'location_template_from_location_id', Router.current().params.doc_id
    Template.location_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_location', @_id, =>
                    Router.go "/location/#{@_id}/view"


if Meteor.isServer
    Meteor.publish 'location_template_from_location_id', (location_id)->
        location = Docs.findOne location_id
        Docs.find 
            model:'location_template'
            _id:location.template_id
#     Meteor.methods
        # send_location: (location_id)->
        #     location = Docs.findOne location_id
        #     target = Meteor.users.findOne location.recipient_id
        #     gifter = Meteor.users.findOne location._author_id
        #
        #     console.log 'sending location', location
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: location.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -location.amount
        #     Docs.update location_id,
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
    Router.route '/location/:doc_id/edit', (->
        @layout 'layout'
        @render 'location_edit'
        ), name:'location_edit'

    Template.location_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.location_edit.onRendered ->


    Template.location_edit.events
        'click .select_leader': ->
            Docs.update Router.current().params.doc_id,     
                $set:leader_user_id:@_id
                
        'click .clear_leader': ->
            Docs.update Router.current().params.doc_id,     
                $unset:leader_user_id:1
                
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_location', @_id, =>
                    Router.go "/location/#{@_id}/view"


    Template.location_edit.helpers
        unselected_stewards: ->
            Meteor.users.find 
                levels:$in:['steward']
    Template.location_edit.locations
