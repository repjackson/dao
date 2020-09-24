Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'

Template.nav.events
#     'click .logout': ->
#         Session.set 'logging_out', true
#         Meteor.logout ->
#             Session.set 'logging_out', false
#             Router.go '/login'
    
    'click .toggle_nightmode': ->
        if Meteor.user().invert_class is 'invert'
            Meteor.users.update Meteor.userId(),
                $set:invert_class:''
        else
            Meteor.users.update Meteor.userId(),
                $set:invert_class:'invert'



    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'

    'click .home': ->
        Router.go '/'
    'click .reconnect': -> Meteor.reconnect()

    'click .post': ->
        new_post_id =
            Docs.insert
                model:'post'
                source:'self'
                # buyer_id:Meteor.userId()
                # buyer_username:Meteor.user().username
        Router.go "/post/#{new_post_id}/edit"


@selected_tags = new ReactiveArray []

Template.body.events
    # 'click a:not(.select_term)': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)
    #     # unless Meteor.user().invert_class is 'invert'

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'



Template.home.onCreated ->
    @autorun -> Meteor.subscribe('me')
    @autorun -> Meteor.subscribe('tags',
        # Session.get('query')
        selected_tags.array()
        )
    @autorun -> Meteor.subscribe('docs',
        selected_tags.array()
        # Session.get('query')
        )

    
Template.tag_selector.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data.name)
Template.tag_selector.helpers
    term: ->
        Docs.findOne 
            title:@name
Template.tag_selector.events
    'click .select_tag': -> 
        selected_tags.push @name
        # if Meteor.user()
        Meteor.call 'call_wiki', @name, ->
            # Meteor.call 'calc_term', @title, ->
            # Meteor.call 'omega', @title, ->
            
        Meteor.call 'search_reddit', selected_tags.array(), ->
        Meteor.call 'search_ph', selected_tags.array(), ->

Template.unselect_tag.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data)
Template.unselect_tag.helpers
    term: ->
        Docs.findOne 
            model:'wikipedia'
            title:@valueOf()
Template.unselect_tag.events
   'click .unselect_tag': -> 
        selected_tags.remove @valueOf()
        Meteor.call 'search_reddit', selected_tags.array(), ->
        Meteor.call 'search_ph', selected_tags.array(), ->

Template.tone.events
    # 'click .upvote_sentence': ->
    'click .tone_item': ->
        # console.log @
        doc_id = Docs.findOne()._id
        if @weight is 3
            Meteor.call 'reset_sentence', doc_id, @, ->
        else
            Meteor.call 'upvote_sentence', doc_id, @, ->
            
Template.home.helpers
    selected_tags_plural: -> selected_tags.array().length > 1
    one_post: ->
        match = {model:$in:['post','wikipedia','reddit','porn']}
        
        # match = {model:'post'}
        if selected_tags.array().length>0
            match.tags = $in:selected_tags.array()

        Docs.find(match).count() is 1

    two_posts: -> 
        match = {model:$in:['post','wikipedia','reddit','porn']}
        
        # match = {model:'post'}
        if selected_tags.array().length>0
            match.tags = $in:selected_tags.array()
        Docs.find(match).count() is 2
    three_posts: -> Docs.find().count() is 3


    docs: ->
        # match = {model:$in:['porn']}
        match = {model:$in:['post','wikipedia','reddit','porn']}
        
        # match = {model:'post'}
        if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
        Docs.find match,
            sort:
                points:-1
                ups:-1
                _timestamp:-1
                # "#{Session.get('sort_key')}": Session.get('sort_direction')
            limit:1
        
    term: ->
        # console.log @
        Docs.find 
            model:$in:['wikipedia']
            lower_title:@name
    
    selected_tags: -> selected_tags.array()
    tag_results: ->
        doc_count = Docs.find({model:$in:['post','wikipedia','reddit','porn']}).count()
        if 0 < doc_count < 3 
            Tag_results.find({ 
                count:$lt:doc_count 
            })
        else 
            Tag_results.find()

            
Template.vid_card.events
    'click .fork': -> 
        console.log @
        Meteor.call 'tagify_vid', @_id, ->

Template.home.events
    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id
    'click .post': ->
        new_post_id =
            Docs.insert
                model:'post'
                source:'self'
                # buyer_id:Meteor.userId()
                # buyer_username:Meteor.user().username
                
        Router.go "/post/#{new_post_id}/edit"

    

    'click #clear_tags': -> selected_tags.clear()


    'keydown .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        # Session.set('query',search)
        if e.which is 13
            console.log search
            selected_tags.push search
            # if Meteor.user()
            Meteor.call 'search_ph', selected_tags.array(), ->
            Meteor.call 'call_wiki', search, ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
            Session.set('query','')
            search = $('.search_title').val('')
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()
