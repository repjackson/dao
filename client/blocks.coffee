if Meteor.isClient
    Template.print_this.events
        'click .print_this': ->
            console.log @
    Template.smart_tagger.onCreated ->
        # @autorun => @subscribe 'tag_results',
        #     # Router.current().params.doc_id
        #     selected_tags.array()
        #     Session.get('searching')
        #     Session.get('current_query')
        #     Session.get('dummy')

    Template.smart_tagger.helpers        
        # terms: -> Terms.find()
        # suggestions: -> Tag_results.find()

    Template.smart_tagger.events
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                selected_tags.push element_val
                # Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Meteor.call 'add_tag', @_id, ->
    
                # Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 250)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            selected_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            # Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # selected_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            selected_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            # Session.set('dummy', !Session.get('dummy'))


    Template.vote.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'author_vote', @data._id

    Template.vote.helpers
        user_vote: ->
            Docs.findOne 
                model:'vote'
                parent_id:@_id
                _author_id:Meteor.userId()
            
    Template.vote.events
        'click .upvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            # if Meteor.user()
            Meteor.call 'upvote', @_id, ->
            #     Meteor.call 'calc_post_votes', @_id, ->
            # else
            #     Router.go "/register"
        'click .downvote': (e,t)->
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            # if Meteor.user()
            Meteor.call 'downvote', @_id, ->
            # Meteor.call 'calc_post_votes', @_id, ->
            # else
            #     Router.go "/register"
