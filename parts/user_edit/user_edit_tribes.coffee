if Meteor.isClient
    Router.route '/user/:username/edit/tribes', (->
        @layout 'user_edit_layout'
        @render 'user_edit_tribes'
        ), name:'user_edit_tribes'

    Template.user_edit_tribes.onRendered ->

    Template.user_edit_tribes.events
        'click .switch': ->
            Swal.fire({
                title: "switch to #{@title}?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm' 
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    Meteor.users.update Meteor.userId(),
                        $set:
                            current_tribe:@_id
                    Swal.fire(
                        'topup initiated',
                        ''
                        'success'
                    )
            )
