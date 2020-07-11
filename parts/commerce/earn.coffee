if Meteor.isClient
    Router.route '/generate', (->
        @layout 'layout'
        @render 'earn'
        ), name:'earn'


    Template.earn.onCreated ->
        @autorun -> Meteor.subscribe('earn_tag_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            selected_tribes.array()
            Session.get('view_complete')
            Session.get('view_incomplete')
            )
        @autorun -> Meteor.subscribe('earn_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            selected_tribes.array()
            Session.get('view_complete')
            Session.get('view_incomplete')
            )
    Template.earn.events

        # 'click .toggle_complete': ->
        #     Session.set('view_complete', !Session.get('view_complete'))
        'click .new_earn': (e,t)->
            if currentUser
                new_earn_id =
                    Docs.insert
                        model:'earn'
                Router.go "/earn/#{new_earn_id}/edit"

    Template.earn.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        earn_docs: ->
            Docs.find
                model:'earn'




    Template.earn_card_template.onRendered ->
    Template.earn_card_template.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.earn_card_template.events
    Template.earn_card_template.helpers
        # earn_segment_class: ->
        #     cl=''
        #     if @complete
        #         classes += ' green'
        #     if Session.equals('selected_earn_id', @_id)
        #         classes += ' inverted blue'
        #     classes


    Template.earn_card_template.events
        'click .record_earn': ->
            if Meteor.user()
                # console.log 'hi'
                Meteor.users.update Meteor.userId(),
                    $inc: points:@points
                $('body')
                  .toast({
                    class: 'success'
                    position: 'bottom right'
                    message: "#{@points} added to account"
                  })
                Docs.insert
                    model:'earn_item'
                    parent_id: @_id



if Meteor.isServer
    Meteor.methods
        refresh_earn_stats: (earn_id)->
            earn = Docs.findOne earn_id
            # console.log earn
            reservations = Docs.find({model:'reservation', earn_id:earn_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_earn_hours = 0
            average_earn_duration = 0

            # shorearn_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_earn_hours += parseFloat(res.hour_duration)

            average_earn_cost = total_earnings/reservation_count
            average_earn_duration = total_earn_hours/reservation_count

            Docs.update earn_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_earn_hours: total_earn_hours.toFixed(0)
                    average_earn_cost: average_earn_cost.toFixed(0)
                    average_earn_duration: average_earn_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header earn ranking #reservations
            # .ui.small.header earn ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg earn time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
