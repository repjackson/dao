if Meteor.isClient
    Template.registerHelper 'current_user', () -> Meteor.users.findOne username:Router.current().params.username

    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/u/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne username:Router.current().params.username

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'remove email?'
                current_user = Meteor.users.findOne username:Router.current().params.username
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
