@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []
@selected_location_tags = new ReactiveArray []


# Router.configure
	# progressDelay : 100

Template.body.events
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 250)
    #     .transition('fade in', 250)
