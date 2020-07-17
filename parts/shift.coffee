if Meteor.isClient
    Router.route '/shifts/', (->
        @layout 'layout'
        @render 'shifts'
        ), name:'shifts'
    Router.route '/shift/:doc_id/view', (->
        @layout 'layout'
        @render 'shift_view'
        ), name:'shift_view'

    Template.shift_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shifts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift'
    Template.shifts.events
        'click .add_shift': ->
            new_id = 
                Docs.insert
                    model:'shift'
            Router.go "/shift/#{new_id}/edit"
    Template.shifts.helpers
        next_shifts: ->
            Docs.find {model:'shift'}, 
                sort:
                    start_datetime:-1



    Template.shift_view.onRendered ->
        @autorun => Meteor.subscribe 'users'
    Template.shift_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_shift', @_id, =>
                    Router.go "/shift/#{@_id}/view"


# if Meteor.isServer
#     Meteor.methods
        # send_shift: (shift_id)->
        #     shift = Docs.findOne shift_id
        #     target = Meteor.users.findOne shift.recipient_id
        #     gifter = Meteor.users.findOne shift._author_id
        #
        #     console.log 'sending shift', shift
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: shift.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -shift.amount
        #     Docs.update shift_id,
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
    Router.route '/shift/:doc_id/edit', (->
        @layout 'layout'
        @render 'shift_edit'
        ), name:'shift_edit'

    Template.shift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users'
        @autorun => Meteor.subscribe 'all_users'
    Template.shift_edit.onRendered ->


    Template.shift_edit.events
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
                Meteor.call 'send_shift', @_id, =>
                    Router.go "/shift/#{@_id}/view"


    Template.shift_edit.helpers
        shift_leader: ->
            Meteor.users.findOne 
                _id:@leader_user_id
        unselected_stewards: ->
            Meteor.users.find 
                levels:$in:['steward']
    Template.shift_edit.shifts
