if Meteor.isClient
    # Router.route '/user/:username/m/:model_slug', (->
    #     @render 'udelta'
    #     ), name:'udelta'

    Template.udelta.onCreated ->
        Session.setDefault('current_user_delta_model','post')
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'model_from_slug', Meteor.user().current_user_delta_model
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Meteor.user().current_user_delta_model
        @autorun -> Meteor.subscribe 'my_delta'
        @autorun -> Meteor.subscribe 'all_users'

        Session.set 'loading', true
        Meteor.call 'set_facets', Meteor.user().current_user_delta_model, ->
            Session.set 'loading', false
    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.udelta.helpers
        result_column_class: ->
            delta = Docs.findOne model:'delta'
            model = Docs.findOne {model:'model',slug:Meteor.user().current_user_delta_model}
            if model.show_facets
                'twelve wide column'
            else
                'sixteen wide column'

        subs_ready: ->
            Template.instance().subscriptionsReady()
        table_header_column: ->
            console.log @


        model_fields: ->
            delta = Docs.findOne model:'delta'
            model = Docs.findOne model:'model'
            Docs.find
                model:'field'
                parent_id: model._id
        query_class:->
            delta = Docs.findOne model:'delta'
            if delta
                if delta.search_query
                    'focus'
                else
                    'small'
        current_delta_model: ->
            delta = Docs.findOne model:'delta'
            model = Docs.findOne model:'model'
            console.log 'delta',delta
            console.log 'model',model

        current_model: ->
            Docs.findOne
                model:'model'
                slug: Meteor.user().current_user_delta_model

        sorting_up: ->
            delta = Docs.findOne model:'delta'
            if delta
                if delta.sort_direction is 1 then true

        selected_tags: -> selected_tags.list()
        view_mode_template: ->
            # console.log @
            delta = Docs.findOne model:'delta'
            if delta
                "delta_#{delta.view_mode}"

        sorted_facets: ->
            current_delta =
                Docs.findOne
                    model:'delta'
            if current_delta
                # console.log _.sortBy current_delta.facets,'rank'
                _.sortBy current_delta.facets,'rank'

        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            false
            # delta = Docs.findOne model:'delta'
            # count = delta.result_ids.length
            # if count is 1 then true else false

        model_stats_exists: ->
            current_model = Meteor.user().current_user_delta_model
            if Template["#{current_model}_stats"]
                return true
            else
                return false
        model_stats: ->
            current_model = Meteor.user().current_user_delta_model
            "#{current_model}_stats"


    Template.udelta.events
        'click .toggle_sort_column': ->
            console.log @
            delta = Docs.findOne model:'delta'
            console.log delta


        'click .go_home': ->
            Session.set 'loading', true
            Router.go "/m/model"
            # Meteor.call 'log_view', @_id, ->
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        'click .create_model': ->
            new_model_id = Docs.insert
                model:'model'
                slug: Meteor.user().current_user_delta_model
            new_model = Docs.findOne new_model_id
            Router.go "/model/edit/#{new_model._id}"


        'click .clear_query': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $unset:search_query:1
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .set_sort_key': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:sort_key:@key
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .set_sort_direction': (e,t)->
            # console.log @
            # $(e.currentTarget).closest('.button').transition('pulse', 250)

            delta = Docs.findOne model:'delta'
            if delta.sort_direction is -1
                Docs.update delta._id,
                    $set:sort_direction:1
            else
                Docs.update delta._id,
                    $set:sort_direction:-1
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .create_delta': (e,t)->
            console.log 'create delta'
            Docs.insert
                model:'delta'
                view_mode:'cards'
                app:'dao'
                model_filter: Meteor.user().current_user_delta_model

        'click .print_delta': (e,t)->
            delta = Docs.findOne model:'delta'
            console.log delta

        'click .reset': ->
            model_slug =  Meteor.user().current_user_delta_model
            Session.set 'loading', true
            Meteor.call 'set_facets', model_slug, true, ->
                Session.set 'loading', false

        'click .delete_delta': (e,t)->
            delta = Docs.findOne model:'delta'
            if delta
                if confirm "delete  #{delta._id}?"
                    Docs.remove delta._id

        # 'mouseenter .add_model_doc': (e,t)->
    	# 	$(e.currentTarget).addClass('spinning')

        'click .add_model_doc': ->
            model = Docs.findOne
                model:'model'
                slug: Meteor.user().current_user_delta_model
            # console.log model
            if model.collection and model.collection is 'users'
                name = prompt 'first and last name'
                split = name.split ' '
                first_name = split[0]
                last_name = split[1]
                username = name.split(' ').join('_')
                # console.log username
                Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                    if err
                        alert err
                    else
                        Meteor.users.update res,
                            $set:
                                first_name:first_name
                                last_name:last_name
                        Router.go "/m/#{model.slug}/#{res}/edit"
            # else if model.slug is 'gift'
            #     new_doc_id = Docs.insert
            #         model:model.slug
            #     Router.go "/debit/#{new_doc_id}/edit"
            else if model.slug is 'model'
                new_doc_id = Docs.insert
                    model:'model'
                Router.go "/model/edit/#{new_doc_id}"
            else
                console.log model
                new_doc_id = Docs.insert
                    model:model.slug
                Router.go "/m/#{model.slug}/#{new_doc_id}/edit"


        'click .edit_model': ->
            model = Docs.findOne
                model:'model'
                slug: Meteor.user().current_user_delta_model
            Router.go "/model/edit/#{model._id}"

        # 'click .page_up': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false
        #
        # 'click .page_down': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:-1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false

        # 'click .select_tag': -> selected_tags.push @name
        # 'click .unselect_tag': -> selected_tags.remove @valueOf()
        # 'click #clear_tags': -> selected_tags.clear()
        #
        # 'keyup #search': (e)->
            # switch e.which
            #     when 13
            #         if e.target.value is 'clear'
            #             selected_tags.clear()
            #             $('#search').val('')
            #         else
            #             selected_tags.push e.target.value.toLowerCase().trim()
            #             $('#search').val('')
            #     when 8
            #         if e.target.value is ''
            #             selected_tags.pop()
        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:search_query:query
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)




    Template.utoggle_visible_field.events
        'click .toggle_visibility': ->
            console.log @
            delta = Docs.findOne model:'delta'
            console.log 'viewable fields', delta.viewable_fields
            if @_id in delta.viewable_fields
                Docs.update delta._id,
                    $pull:viewable_fields: @_id
            else
                Docs.update delta._id,
                    $addToSet: viewable_fields: @_id

    Template.utoggle_visible_field.helpers
        field_visible: ->
            delta = Docs.findOne model:'delta'
            @_id in delta.viewable_fields

    Template.uset_limit.events
        'click .set_limit': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:limit:@amount
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

    Template.uset_view_mode.events
        'click .set_view_mode': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:view_mode:@title
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false





    Template.ufacet.onCreated ->
        @viewing_facet = new ReactiveVar true

    Template.ufacet.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500

    Template.ufacet.events
        # 'click .ui.accordion': ->
        #     $('.accordion').accordion()
        'click .toggle_view_facet': (e,t)->
            t.viewing_facet.set !t.viewing_facet.get()

        'click .toggle_selection': ->
            delta = Docs.findOne model:'delta'
            facet = Template.currentData()

            Session.set 'loading', true
            if facet.filters and @name in facet.filters
                Meteor.call 'remove_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false
            else
                Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false

        'keyup .add_filter': (e,t)->
            # console.log @
            if e.which is 13
                delta = Docs.findOne model:'delta'
                facet = Template.currentData()
                if @field_type is 'number'
                    filter = parseInt t.$('.add_filter').val()
                else
                    filter = t.$('.add_filter').val()
                Session.set 'loading', true
                Meteor.call 'add_facet_filter', delta._id, facet.key, filter, ->
                    Session.set 'loading', false
                t.$('.add_filter').val('')




    Template.ufacet.helpers
        viewing_results: ->
            Template.instance().viewing_facet.get()
        filtering_res: ->
            delta = Docs.findOne model:'delta'
            filtering_res = []
            if @key is '_keys'
                @res
            else
                for filter in @res
                    if filter.count < delta.total
                        filtering_res.push filter
                    else if filter.name in @filters
                        filtering_res.push filter
                filtering_res
        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne model:'delta'
            if Session.equals 'loading', true
                 'disabled basic'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''