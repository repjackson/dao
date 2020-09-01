if Meteor.isClient
    Router.route '/alpha/:doc_id/edit', (->
        @layout 'layout'
        @render 'alpha_doc_edit'
        ), name:'alpha_doc_edit'
    Template.alpha_doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'block'
        @autorun => Meteor.subscribe 'model_docs', 'module'

    Template.module_edit.helpers
        alpha_field_edit: ->
            console.log @
            "a#{@block_slug}_edit"
        viewing_module: ->
            Session.equals('expand_module', @_id)

    Template.module_edit.events
        'click .toggle_section': ->
            if Session.equals('expand_module', @_id)
                Session.set('expand_module', null)
            else
                Session.set('expand_module', @_id)

        'blur .module_key': (e,t)->
            val = t.$('.module_key').val()
            console.log val
            console.log @
            doc_id = Router.current().params.doc_id
            # Docs.update(
            #     { _id:doc_id, "modules": sentence.sentence_id },
            #     { $inc: { "tone.result.sentences_tone.$.weight": 1 } }
            # )
                
                
    Template.alpha_doc_edit.helpers
        blocks: ->
            Docs.find
                model:'block'

        old_modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id

        # modules: ->
            # Docs.find
            #     model:'module'
            #     parent_id: Router.current().params.doc_id




    Template.alpha_doc_edit.events
        'click .print_this': ->
            console.log @

        'click .add_module': ->
            doc = Docs.findOne Router.current().params.doc_id
            module_count = doc.modules.length
            next_module = module_count+1
            console.log 'next module', next_module
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    modules: 
                        block_slug:@slug
                        block_title:@title
                        block_id:@_id
                        module_key:"#{@slug}#{next_module}"

        'click .remove_module': ->
            if confirm 'delete?'
                Docs.update Router.current().params.doc_id,
                    $pull:
                        modules:@
                
        # 'click .remove_module': ->
        #     if confirm 'delete?'
        #         Docs.remove @_id
                
                
                
                
                
                
                
                
if Meteor.isClient
    Router.route '/alpha/:doc_id/view', (->
        @layout 'layout'
        @render 'alpha_doc_view'
        ), name:'alpha_doc_view'


    Template.alpha_doc_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'block'
        @autorun => Meteor.subscribe 'model_docs', 'module'



    Template.module_view.helpers
        alpha_field_view: ->
            console.log @
            "a#{@block_slug}_view"

    Template.alpha_doc_view.helpers
        blocks: ->
            Docs.find
                model:'block'

        modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id                