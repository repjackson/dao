if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'debit'
        @autorun => Meteor.subscribe 'model_docs', 'offer'
        @autorun => Meteor.subscribe 'model_docs', 'shift'
        @autorun => Meteor.subscribe 'model_docs', 'email_signup'
        @autorun => Meteor.subscribe 'all_users'
        @autorun -> Meteor.subscribe('home_tag_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )
        @autorun -> Meteor.subscribe('home_results',
            selected_tags.array()
            selected_location_tags.array()
            selected_authors.array()
            Session.get('view_purchased')
            # Session.get('view_incomplete')
            )

    Template.home.helpers
        view_section: (input)->
            Session.equals('view_section',input)
        stewards: ->
            Meteor.users.find
                levels:$in:['steward']
        regenerators: ->
            Meteor.users.find
                levels:$in:['regenerator']
        memberss: ->
            Meteor.users.find
                levels:$in:['members']
        explorers: ->
            Meteor.users.find
                levels:$in:['explorer']
        news_items: ->
            Docs.find {
                model:'debit'
            },
                sort:
                    _timestamp: -1
                limit:10
        upcoming_shifts: ->
            Docs.find {model:'shift'},
                sort:
                    date:1
                limit:10
        most_given: ->
            Meteor.users.find {global_debit_count_rank:$exists:true},
                sort:
                    global_debit_count_rank:1
                limit:10
        most_received: ->
            Meteor.users.find {global_credit_count_rank:$exists:true},
                sort:
                    global_credit_count_rank:1
                limit:10
        one_score_users: ->
            Meteor.users.find {one_score:$exists:true},
                sort:
                    one_score:-1
                limit:10
        offers: ->
            Docs.find
                model:'offer'
        credits: ->
            Docs.find
                model:'credit'
        debits: ->
            Docs.find
                model:'debit'
        email_signups: ->
            Docs.find
                model:'email_signup'

    Template.home.events
        'click .set_shifts': -> Session.set('view_section', 'upcoming_shifts')
        'click .set_one_score': -> Session.set('view_section', 'one_score')
        'click .set_latest_celebrations': -> Session.set('view_section', 'latest_celebrations')
        'click .set_most_given': -> Session.set('view_section', 'most_given')
        'click .set_most_received': -> Session.set('view_section', 'most_received')
        'click .set_offers': -> Session.set('view_section', 'offers')
        'click .add_home': ->
            new_id =
                Docs.insert
                    model:'home'
            Router.go "/home/#{new_id}/edit"
        'keydown .submit_email': (e,t)->
            # email = $('submit_email').val()
            if e.which is 13
                email = $('.submit_email').val()
                if email.length > 0
                    Docs.insert
                        model:'email_signup'
                        email_address:email
                    $('body')
                      .toast({
                        class: 'success'
                        position: 'top right'
                        message: "#{email} added to list"
                      })
                    $('.submit_email').val('')




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
