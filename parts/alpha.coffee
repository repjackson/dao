if Meteor.isClient
    Router.route '/alpha', (->
        @layout 'layout'
        @render 'alpha'
        ), name:'alpha'

    Template.registerHelper 'alpha_value', () ->
        console.log @doc_key
        alpha_doc = Docs.findOne Router.current().params.doc_id
        alpha_doc["#{@doc_key}"]

    Template.registerHelper 'afield_value', () ->
        # console.log @
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
    
        page_doc = Docs.findOne Router.current().params.doc_id
    
        page_doc["#{@doc_key}"]
    


    Template.alpha.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'alpha'
        @autorun => Meteor.subscribe 'model_docs', 'alpha_session'
    Template.alpha.helpers
        alpha_docs: ->
            Docs.find
                model:'alpha'
    Template.alpha.events
        'click .add_alpha': ->
            new_id =
                Docs.insert
                    model:'alpha'
            Router.go "/alpha/#{new_id}/edit"



    Template.block_editor.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'block'
    Template.block_editor.events
        'click .add_block': ->
            Docs.insert
                model:'block'
    Template.block_editor.helpers
        blocks: ->
            Docs.find
                model:'block'


if Meteor.isServer
    Meteor.publish 'blocks', ->
        Docs.find
            model:'block'