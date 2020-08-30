if Meteor.isClient
    Template.debit_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id
    Template.offer_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id
    Template.request_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id

    # Template.home_card.events
    #     'click .record_home': ->
    #         Meteor.users.update Meteor.userId(),
    #             $inc: points:-@points
    #         $('body').toast({
    #             class: 'info',
    #             message: "#{@points} spent"
    #         })
    #         Docs.insert
    #             model:'home_item'
    #             parent_id: @_id
