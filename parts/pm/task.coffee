if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Template.task_view.onRendered ->


    Template.task_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_task', @_id, =>
                    Router.go "/task/#{@_id}/view"


    Template.task_view.helpers
    Template.task_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_task: (task_id)->
        #     task = Docs.findOne task_id
        #     target = Meteor.users.findOne task.recipient_id
        #     gifter = Meteor.users.findOne task._author_id
        #
        #     console.log 'sending task', task
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: task.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -task.amount
        #     Docs.update task_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Template.task_edit.onRendered ->


    Template.task_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_task', @_id, =>
                    Router.go "/task/#{@_id}/view"


    Template.task_edit.helpers
    Template.task_edit.events

if Meteor.isServer
    Meteor.methods
        reward_task: (task_id, target_id)->
            task = Docs.findOne task_id
            target = Meteor.users.findOne target_id

            console.log 'rewarding task', task
            Meteor.users.update target._id,
                $addToSet:
                    rewarded_task_ids: task._id