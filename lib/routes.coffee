# if Meteor.isClient
    # Router.route '/', (->
    #     @redirect('/m/model')
    # )

    # Router.route '/', (->
    #     @layout 'layout'
    #     @render 'home'
    #     ), name:'home'


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

Router.onBeforeAction(force_loggedin, {
    # only: ['admin']
    except: [
        'register'
        'login'
        'verify-email'
        'forgot_password'
        'event_view'
        'delta'
    ]
    })


Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})


Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'

Router.route '/forgot_password', -> @render 'forgot_password'


Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'
