if Meteor.isClient
    Router.route '/gift', (->
        @layout 'layout'
        @render 'gift'
        ), name:'gift'

    Template.gift.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'gift'
        # @autorun => Meteor.subscribe 'all_users'
        @autorun -> Meteor.subscribe('gift_tag_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )
        @autorun -> Meteor.subscribe('gift_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )

    Template.gift.helpers
        gift_items: ->
            Docs.find
                model:'gift'
    Template.gift.events
        'click .add_gift': ->
            new_id =
                Docs.insert
                    model:'gift'
            Router.go "/gift/#{new_id}/edit"


    Template.gift_card.events
        'click .record_gift': ->
            if Meteor.user()
                Meteor.users.update Meteor.userId(),
                    $inc: points:-@points
                $('body').toast({
                    class: 'info',
                    message: "#{@points} gifted"
                })
                Docs.insert
                    model:'gift_item'
                    parent_id: @_id
