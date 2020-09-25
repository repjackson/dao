Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @url.match(regExp)
    if match && match[2].length == 11
        # console.log match[2]
        return match[2];
    else
        # console.log 'error, not vid'
        null
        
        
Template.registerHelper 'editing_mode', () ->
    # Meteor.user().edit_mode and 
    if Meteor.user().edit_mode
        if Router.current().params.username is Meteor.user().username
            true
Template.registerHelper 'user_id_in', (key)->
    if Meteor.user()
        if Meteor.userId() in @["#{key}"]
            true
        else
            false
    else
        false

Template.registerHelper 'current_tribe', () ->
    if Meteor.user()
        Docs.findOne 
            _id:Meteor.user().current_tribe_id
    
Template.registerHelper 'enabled_features', () ->
    # console.log @
    Docs.find
        model:'feature'
        _id:@enabled_feature_ids
    
    
Template.registerHelper 'user_from_id', (user_id) ->
    # console.log @
    Meteor.users.findOne _id:user_id

        
Template.registerHelper 'i_have_points', () ->
    if Meteor.user().username is 'dev'
        true
    else
        Meteor.user().points > 0
        
        
Template.registerHelper 'post_header_class', (metric) ->
    # console.log @
    if @max_emotion_name
        if @max_emotion_name is 'joy' then 'green invert'
        else if @max_emotion_name is 'anger' then 'red invert'
        else if @max_emotion_name is 'sadness' then 'blue invert'
        else if @max_emotion_name is 'disgust' then 'orange invert'
    
Template.registerHelper 'calculated_size', (metric) ->
    # console.log 'metric', metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log 'whole', whole

    if whole is 2 then 'f7'
    else if whole is 3 then 'f8'
    else if whole is 4 then 'f9'
    else if whole is 5 then 'f10'
    else if whole is 6 then 'f11'
    else if whole is 7 then 'f12'
    else if whole is 8 then 'f13'
    else if whole is 9 then 'f14'
    else if whole is 10 then 'f15'
    
    
Template.registerHelper 'connection', () ->
    # console.log Meteor.status()
    Meteor.status()

Template.registerHelper 'connected', () -> Meteor.status().connected
    
    
Template.registerHelper 'tone_size', () ->
    # console.log 'this weight', @weight
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    if @weight
        if @weight is -5 then 'f6'
        else if @weight is -4 then 'f7'
        else if @weight is -3 then 'f8'
        else if @weight is -2 then 'f9'
        else if @weight is -1 then 'f10'
        else if @weight is 0 then 'f12'
        else if @weight is 1 then 'f12'
        else if @weight is 2 then 'f13'
        else if @weight is 3 then 'f14'
        else if @weight is 4 then 'f15'
        else if @weight is 5 then 'f16'
    else
        'f11'
  
Template.registerHelper 'is_dao', () -> @username is 'dao'

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")

Template.registerHelper 'tag_term', () ->
    Docs.findOne 
        model:'wikipedia'
        title:@valueOf()


# Template.registerHelper 'field_value', () ->
#     # console.log @
#     parent = Template.parentData()
#     # console.log 'parent', parent
#     if parent
#         parent["#{@key}"]

Template.registerHelper 'is_logging_out', () -> Session.get('logging_out')


Template.registerHelper 'is_admin', () ->
    # Meteor.users.findOne username:Router.current().params.username
    if Meteor.user() and Meteor.user().roles
        if 'admin' in Meteor.user().roles then true else false

Template.registerHelper 'is_dev', () ->
    # Meteor.users.findOne username:Router.current().params.username
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false


Template.registerHelper 'is_author', () ->
    # if @_author_id and Meteor.userId()
    @_author_id is Meteor.userId()


Template.registerHelper 'can_edit', () ->
    # if @_author_id and Meteor.userId()
    # @_author_id is Meteor.userId()
    # if Meteor.user().roles
    if Meteor.user()
        if Meteor.user().roles and 'dev' in Meteor.user().roles or @_author_id is Meteor.userId() then true else false



Template.registerHelper 'lowered_title', ()-> @title.toLowerCase()


Template.registerHelper 'recipient', () ->
    Meteor.users.findOne @recipient_id
Template.registerHelper 'target', () ->
    Meteor.users.findOne @target_user_id
Template.registerHelper 'to', () ->
    Meteor.users.findOne @to_user_id




Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)

    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    # console.log 'parent', parent
    if parent
        parent["#{@key}"]



Template.registerHelper 'lowered', (input)-> input.toLowerCase()
Template.registerHelper 'money_format', (input)-> (input/100).toFixed(2)

Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)




Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    number.toFixed(2)
    # (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

# Template.registerHelper 'upvote_class', () ->
#     if Meteor.userId()
#         if @upvoter_ids and Meteor.userId() in @upvoter_ids then '' else 'outline'
#     else ''
# Template.registerHelper 'downvote_class', () ->
#     if Meteor.userId()
#         if @downvoter_ids and Meteor.userId() in @downvoter_ids then '' else 'outline'
#     else ''

Template.registerHelper 'current_doc', ()->
    Docs.findOne Router.current().params.doc_id

Template.registerHelper 'is_image', ()->
    if @domain in ['i.redd.it','i.imgur.com','imgur.com','gyfycat.com','v.redd.it','giphy.com']
        true
    else 
        false

Template.registerHelper 'is_youtube', ()->
    if @domain in ['youtube.com','youtu.be','m.youtube.com']
        true
    else 
        false


Template.registerHelper 'session_is', (key)->
    Session.get(key)

Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'long_time', (input)-> 
        console.log 'long time', input
        moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'home_long_date', (input)-> moment(input).format("dd MMM D h:mma")
Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper 'made_when', ()-> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

Template.registerHelper 'is_eric', ()-> if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c'] then true else false
Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()



Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'from_now', (input)-> moment(input).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
