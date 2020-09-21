Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
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
        'home'
        'post_view'
        'post_edit'
        'register'
        'login'
        'verify-email'
        'forgot_password'
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


Router.route '/post/:doc_id/view', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view'

Router.route '/post/:doc_id/edit', (->
    @layout 'layout'
    @render 'post_edit'
    ), name:'post_edit'

Router.route '/reddit/:doc_id/view', (->
    @layout 'layout'
    @render 'reddit_view'
    ), name:'reddit_view'

Router.route '/reddit/:doc_id/edit', (->
    @layout 'layout'
    @render 'reddit_edit'
    ), name:'reddit_edit'


Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'home'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'

Router.route '/forgot_password', -> @render 'forgot_password'
Router.route '/user/:username', -> @render 'profile'


Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'
