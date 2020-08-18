@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []
@selected_location_tags = new ReactiveArray []


# Router.configure
	# progressDelay : 100

Template.body.events
    'click a:not(.select_term)': ->
        unless Meteor.user().invert_class is 'invert'
            $('.global_container')
            .transition('fade out', 200)
            .transition('fade in', 200)


Template.home.events
    'click .check_notifications': ->
        Notification.requestPermission (result) ->
            console.log result
        


    'click .send_notification': ->
        if Notification.permission is "granted"
            notification = new Notification("Hi there!")
    #   navigator.serviceWorker.register('/sw.js').then (swRegistration) ->
    #     #you can do something with the service wrker registration (swRegistration)
    #     return
        
    #     img = '/images/jason-leung-HM6TMmevbZQ-unsplash.jpg'
    #     text = 'Take a look at this brand new t-shirt!'
    #     title = 'New Product Available'
    #     options = 
    #         body: text
    #         icon: '/images/jason-leung-HM6TMmevbZQ-unsplash.jpg'
    #         vibrate: [
    #             200
    #             100
    #             200
    #             ]
    #         tag: 'new-product'
    #         image: img
    #         badge: 'https://spyna.it/icons/android-icon-192x192.png'
    #         actions: [ {
    #             action: 'Detail'
    #             title: 'View'
    #             icon: 'https://via.placeholder.com/128/ff0000'
    #         } ]
    #     navigator.serviceWorker.ready.then (serviceWorker) ->
    #         serviceWorker.showNotification title, options


# isPushNotificationSupported = ->
#   'serviceWorker' of navigator and 'PushManager' of window
