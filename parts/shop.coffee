if Meteor.isClient
    Router.route '/shop/', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'

    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.products.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.products.events
        'click .add_product': ->
            new_id = 
                Docs.insert
                    model:'product'
            Router.go "/product/#{new_id}/edit"
    Template.products.helpers
        product_docs: ->
            Docs.find {model:'product'}, 
                sort:
                    start_datetime:-1

    Template.product_view.events
        'click .delete_product': ->
            if confirm 'delete product?'
                Docs.remove @_id

        'click .submit': ->
            # if confirm 'confirm?'
                # Meteor.call 'send_product', @_id, =>
                #     Router.go "/product/#{@_id}/view"

        'click .buy': ->
            console.log 'hi'
            if confirm "buy for #{@usd_price}?"
                console.log 'yeah'


    Template.product_view.helpers
    Template.product_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_product: (product_id)->
        #     product = Docs.findOne product_id
        #     target = Meteor.users.findOne product.recipient_id
        #     gifter = Meteor.users.findOne product._author_id
        #
        #     console.log 'sending product', product
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: product.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -product.amount
        #     Docs.update product_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'

    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_edit.onRendered ->


    Template.product_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_product', @_id, =>
                    Router.go "/product/#{@_id}/view"


    Template.product_edit.helpers
    Template.product_edit.events

if Meteor.isServer
    Meteor.methods
        send_product: (product_id)->
            product = Docs.findOne product_id
            target = Meteor.users.findOne product.recipient_id
            gifter = Meteor.users.findOne product._author_id

            console.log 'sending product', product
            Meteor.users.update target._id,
                $inc:
                    points: product.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -product.amount
            Docs.update product_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Router.current().params.doc_id,
                $set:
                    submitted:true
