if Meteor.isClient
    Router.route '/debit/:doc_id/edit', (->
        @layout 'layout'
        @render 'debit_edit'
        ), name:'debit_edit'
        
        
    Template.debit_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_debit_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.debit_edit.onRendered ->


    Template.debit_edit.helpers
        recipient: ->
            debit = Docs.findOne Router.current().params.doc_id
            if debit.recipient_id
                Meteor.users.findOne
                    _id: debit.recipient_id
        members: ->
            debit = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
                username: $ne: Meteor.userId()
            }, {
                sort:points:-1
                })
        # subtotal: ->
        #     debit = Docs.findOne Router.current().params.doc_id
        #     debit.amount*debit.recipient_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            debit = Docs.findOne Router.current().params.doc_id
            debit.amount and debit.recipient_id
    Template.debit_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_tag': (e,t)->
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                Meteor.call 'log_term', element_val, ->
                t.$('.new_tag').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
    
    
        # 'click .result': (e,t)->
        #     selected_tags.push @title
        #     $('#search').val('')
        #     Meteor.call 'call_wiki', @title, ->
        #     Meteor.call 'calc_term', @title, ->
        #     Meteor.call 'omega', @title, ->
        #     Session.set('current_query', '')
        #     Session.set('searching', false)
    
        #     Meteor.call 'search_reddit', selected_tags.array(), ->
        #     # Meteor.setTimeout ->
        #     #     Session.set('dummy', !Session.get('dummy'))
        #     # , 7000

    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    
        'blur .point_amount': (e,t)->
            # console.log @
            val = parseInt t.$('.point_amount').val()
            Docs.update Router.current().params.doc_id,
                $set:amount:val



        'click .cancel_debit': ->
            Swal.fire({
                title: "confirm cancel?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'red'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go '/'
            )
            
        'click .submit': ->
            Swal.fire({
                title: "confirm send #{@amount}pts?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'green'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_debit', @_id, =>
                        Swal.fire(
                            title:"#{@amount} sent"
                            icon:'success'
                            showConfirmButton: false
                            timer: 1000
                        )
                        Router.go "/debit/#{@_id}/view"
            )


    Template.debit_edit.helpers
    Template.debit_edit.events

if Meteor.isServer
    Meteor.methods
        send_debit: (debit_id)->
            debit = Docs.findOne debit_id
            recipient = Meteor.users.findOne debit.recipient_id
            debiter = Meteor.users.findOne debit._author_id

            console.log 'sending debit', debit
            Meteor.users.update recipient._id,
                $inc:
                    points: debit.amount
            Meteor.users.update debiter._id,
                $inc:
                    points: -debit.amount
            Docs.update debit_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update debit_id,
                $set:
                    submitted:true
