if Meteor.isClient
    # Template.post_view.onCreated ->
        # @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
  
    Template.post_edit.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000

    Template.post_view.onRendered ->
        # Meteor.call 'log_view', Router.current().params.doc_id
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
        # Meteor.call 'mark_read', Router.current().params.doc_id, ->
        
    Template.post_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000
    Template.post_card.events
        'click .view_post': ->
            Router.go "/post/#{@_id}/view"
    Template.vid_card.events
        'click .remove': ->
            if confirm 
                Docs.remove @_id

    Template.one_post_view.events
        'click .add_tag': ->
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
                
                
    Template.post_card.events
        'click .add_tag': ->
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            # Meteor.call 'search_ph', selected_tags.array(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
                
    # Template.vid_card.events
    #     'click .add_tag': ->
    #         selected_tags.push @valueOf()
    #         Meteor.call 'call_wiki', @valueOf(), ->
    #         Meteor.call 'search_reddit', selected_tags.array(), ->
            # Meteor.call 'search_ph', selected_tags.array(), ->
                
    Template.post_tag.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe('doc_by_title', @data)
    Template.post_tag.helpers
    Template.post_tag.events
        'click .add_tag': ->
            selected_tags.push @valueOf()
            Meteor.call 'call_wiki', @valueOf(), ->
            Meteor.call 'search_reddit', selected_tags.array(), ->

            Router.go '/'
    
if Meteor.isClient
    Template.post_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.post_edit.events
        'click .delete_post': ->
            Swal.fire({
                title: "delete post?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'post removed',
                        showConfirmButton: false,
                        timer: 1000
                    )
                    Router.go "/"
            )