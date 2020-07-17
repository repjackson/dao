if Meteor.isClient
    Router.route '/join', (->
        @layout 'layout'
        @render 'join'
        ), name:'join'

    Template.page.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'page_doc', Router.current().params.slug
    Template.page.events
        'click .create_page': ->
            Docs.insert
                model:'page'
                slug:Router.current().params.slug
    Template.page.helpers
        page_doc: ->
            console.log 'looking for '
            Docs.findOne
                model:'page'
                slug:Router.current().params.slug


    Template.join.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'model_docs', 'person'
    Template.join.events
        # 'click .create_page': ->
        #     Docs.insert
        #         model:'page'
        #         slug:Router.current().params.slug

    Template.join.helpers
        founders: ->
            Docs.find
                model:'person'
                founder:true
        contributors: ->
            Docs.find
                model:'person'
                contributor:true

# if Meteor.isServer
#     Meteor.publish 'page_doc', (page_slug)->
#         Docs.find
#             model:'page'
#             slug:page_slug
