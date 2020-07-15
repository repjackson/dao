# # Meteor.methods
# #     # stringify_tags: ->
# #     #     docs = Docs.find({
# #     #         tags: $exists: true
# #     #         tags_string: $exists: false
# #     #     },{limit:1000})
# #     #     for doc in docs.fetch()
# #     #         # doc = Docs.findOne id
# #     #         # console.log 'about to stringify', doc
# #     #         tags_string = doc.tags.toString()
# #     #         # console.log 'tags_string', tags_string
# #     #         Docs.update doc._id,
# #     #             $set: tags_string:tags_string
# #     #         # console.log 'result doc', Docs.findOne doc._id
# #     #
#     # tag_coordinates: (doc_id, lat,long)->
#     #     # HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{lat}%2C#{long}&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1",(err,response)=>
#     #     HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=24.77701%2C%20121.02189&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1",(err,response)=>
#     #         console.log response.data
#     #         if err then console.log err
#     #         else
#     #             console.log 'earning'
#     #
#     #     # https://api.opencagedata.com/geocode/v1/json?q=24.77701%2C%20121.02189&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
#     #     # https://api.opencagedata.com/geocode/v1/json?q=Dhumbarahi%2C%20Kathmandu&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1

# #
# #
# #     log_doc_terms: (doc_id)->
# #         doc = Docs.findOne doc_id
# #         if doc.tags
# #             for tag in doc.tags
# #                 Meteor.call 'log_term', tag, ->
# #
# #
# #     log_term: (term_title)->
# #         # console.log 'logging term', term
# #         found_term =
# #             Terms.findOne
# #                 title:term_title
# #         unless found_term
# #             Terms.insert
# #                 title:term_title
# #             # if Meteor.user()
# #             #     Meteor.users.update({_id:Meteor.userId()},{$inc: points: 1}, -> )
# #             # console.log 'added term', term
# #         else
# #             Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
# #             # console.log 'found term', term
# #             Meteor.call 'call_wiki', @term_title, =>
# #                 Meteor.call 'calc_term', @term_title, ->
# #
# #     calc_term: (term_title)->
# #         found_term =
# #             Terms.findOne
# #                 title:term_title
# #         unless found_term
# #             Terms.insert
# #                 title:term_title
# #         if found_term
# #             found_term_docs =
# #                 Docs.find {
# #                     model:'reddit'
# #                     tags:$in:[term_title]
# #                 }, {
# #                     sort:
# #                         points:-1
# #                         ups:-1
# #                     limit:10
# #                 }
# #
# #             # console.log 'found_term docs', term_title, found_term_docs.fetch().length
# #
# #
# #             unless found_term.image
# #                 found_wiki_doc =
# #                     Docs.findOne
# #                         model:$in:['wikipedia']
# #                         # model:$in:['wikipedia','reddit']
# #                         title:term_title
# #                 found_reddit_doc =
# #                     Docs.findOne
# #                         model:$in:['reddit']
# #                         "watson.metadata.image": $exists:true
# #                         # model:$in:['wikipedia','reddit']
# #                         title:term_title
# #                 # console.log 'reddit doc', found_reddit_doc
# #                 if found_wiki_doc
# #                     if found_wiki_doc.watson.metadata.image
# #                         Terms.update term._id,
# #                             $set:image:found_wiki_doc.watson.metadata.image
# #
# #
# #     lookup: =>
# #         selection = @words[4000..4500]
# #         for word in selection
# #             # console.log 'searching ', word
# #             # Meteor.setTimeout ->
# #             Meteor.call 'search_reddit', ([word])
# #             # , 5000
# #
# #     rename_key:(old_key,new_key,parent)->
# #         Docs.update parent._id,
# #             $pull:_keys:old_key
# #         Docs.update parent._id,
# #             $addToSet:_keys:new_key
# #         Docs.update parent._id,
# #             $rename:
# #                 "#{old_key}": new_key
# #                 "_#{old_key}": "_#{new_key}"
# #
# #     remove_tag: (tag)->
# #         # console.log 'tag', tag
# #         results =
# #             Docs.find {
# #                 tags: $in: [tag]
# #             }
# #         # console.log 'pulling tags', results.count()
# #         # Docs.remove(
# #         #     tags: $in: [tag]
# #         # )
# #         for doc in results.fetch()
# #             res = Docs.update doc._id,
# #                 $pull: tags: tag
# #             console.log res
# #
# #     # agg_omega: (query, key, collection)->
# #     omega: (term)->
# #         # agg_res = Meteor.call 'agg_omega2', (err, res)->
# #         #     console.log res
# #         #     console.log 'res from async agg'
# #         term_doc =
# #             Terms.findOne(title:term)
# #         if term_doc
# #             agg_res = Meteor.call 'omega2', term
# #             # console.log 'hi'
# #             # console.log 'agg res', agg_res
# #             # omega = Docs.findOne model:'omega_session'
# #             # doc_count = omega.total_doc_result_count
# #             # doc_count = omega.doc_result_ids.length
# #             # unless omega.selected_doc_id in omega.doc_result_ids
# #             #     Docs.update omega._id,
# #             #         $set:selected_doc_id:omega.doc_result_ids[0]
# #             # console.log 'doc count', doc_count
# #             filtered_agg_res = []
# #
# #             for agg_tag in agg_res
# #                 # if agg_tag.count < doc_count
# #                     # filtered_agg_res.push agg_tag
# #                     if agg_tag.title
# #                         if agg_tag.title.length > 0
# #                             # console.log 'agg tag', agg_tag
# #                             filtered_agg_res.push agg_tag
# #             # console.log 'max term emotion', _.max(filtered_agg_res, (tag)->tag.count)
# #             term_emotion = _.max(filtered_agg_res, (tag)->tag.count).title
# #             Terms.update term_doc._id,
# #                 $set:
# #                     max_emotion_name:term_emotion
# #             # console.log 'term final emotion', term_emotion
# #
# #             # Docs.update omega._id,
# #             #     $set:
# #             #         # agg:agg_res
# #             #         filtered_agg_res:filtered_agg_res
# #     omega2: (term)->
# #         # omega =
# #         #     Docs.findOne
# #         #         model:'omega_session'
# #
# #         # console.log 'running agg omega', omega
# #         match = {tags:$in:[term]}
# #         # if omega.selected_tags.length > 0
# #         #     match.tags =
# #         #         $all: omega.selected_tags
# #         # else
# #         #     match.tags =
# #         #         $all: ['dao']
# #
# #         # console.log 'running agg omega', omega
# #         match.model = $in:['reddit','wikipedia']
# #         # console.log 'doc_count', Docs.find(match).count()
# #         total_doc_result_count =
# #             Docs.find( match,
# #                 {
# #                     fields:
# #                         _id:1
# #                 }
# #             ).count()
# #         # console.log 'doc result count',  total_doc_result_count
# #         # doc_results =
# #         #     Docs.find( match,
# #         #         {
# #         #             limit:20
# #         #             sort:
# #         #                 points:-1
# #         #                 ups:-1
# #         #             fields:
# #         #                 _id:1
# #         #         }
# #         #     ).fetch()
# #         # console.log doc_results
# #         # if doc_results[0]
# #         #     unless doc_results[0].rd
# #         #         if doc_results[0].reddit_id
# #         #             Meteor.call 'get_reddit_post', doc_results[0]._id, doc_results[0].reddit_id, =>
# #         # console.log doc_results
# #         # doc_result_ids = []
# #         # for result in doc_results
# #         #     doc_result_ids.push result._id
# #         # console.log _.keys(doc_results,'_id')
# #         # Docs.update omega._id,
# #         #     $set:
# #         #         doc_result_ids:doc_result_ids
# #         #         total_doc_result_count:total_doc_result_count
# #         # if doc_re
# #         # found_wiki_doc =
# #         #     Docs.findOne
# #         #         model:'wikipedia'
# #         #         title:$in:omega.selected_tags
# #         # if found_wiki_doc
# #         #     Docs.update omega._id,
# #         #         $addToSet:
# #         #             doc_result_ids:found_wiki_doc._id
# #
# #         # Docs.update omega._id,
# #         #     $set:
# #         #         match:match
# #         # limit=20
# #         options = {
# #             explain:false
# #             allowDiskUse:true
# #         }
# #
# #         # if omega.selected_tags.length > 0
# #         #     limit = 42
# #         # else
# #         limit = 33
# #         # console.log 'omega_match', match
# #         # { $match: tags:$all: omega.selected_tags }
# #         pipe =  [
# #             { $match: match }
# #             { $project: max_emotion_name: 1 }
# #             # { $unwind: "$max_emotion_name" }
# #             { $group: _id: "$max_emotion_name", count: $sum: 1 }
# #             # { $group: _id: "$max_emotion_name", count: $sum: 1 }
# #             # { $match: _id: $nin: omega.selected_tags }
# #             { $sort: count: -1, _id: 1 }
# #             { $limit: 5 }
# #             { $project: _id: 0, title: '$_id', count: 1 }
# #         ]
# #
# #         if pipe
# #             agg = global['Docs'].rawCollection().aggregate(pipe,options)
# #             # else
# #             res = {}
# #             if agg
# #                 agg.toArray()
# #                 # printed = console.log(agg.toArray())
# #                 # # console.log(agg.toArray())
# #                 # omega = Docs.findOne model:'omega_session'
# #                 # Docs.update omega._id,
# #                 #     $set:
# #                 #         agg:agg.toArray()
# #         else
# #             return null
# #
# #
# #
# #
# #     # get_top_emotion: ->
# #     #     # console.log 'getting emotion'
# #     #     emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
# #     #     #
# #     #     current_most_emotion = ''
# #     #     current_max_emotion_count = 0
# #     #     current_max_emotion_percent = 0
# #     #     omega = Docs.findOne model:'omega_session'
# #     #     # doc_results =
# #     #         # Docs.find
# #     #
# #     #     match = {_id:$in:omega.doc_result_ids}
# #     #     for doc_id in omega.doc_result_ids
# #     #         doc = Docs.findOne(doc_id)
# #     #         if doc.max_emotion_percent
# #     #             if doc.max_emotion_percent > current_max_emotion_percent
# #     #                 current_max_emotion_percent = doc.max_emotion_percent
# #     #                 if doc.max_emotion_name is 'anger'
# #     #                     emotion_color = 'green'
# #     #                 else if doc.max_emotion_name is 'disgust'
# #     #                     emotion_color = 'teal'
# #     #                 else if doc.max_emotion_name is 'sadness'
# #     #                     emotion_color = 'orange'
# #     #                 else if doc.max_emotion_name is 'fear'
# #     #                     emotion_color = 'grey'
# #     #                 else if doc.max_emotion_name is 'joy'
# #     #                     emotion_color = 'red'
# #     #
# #     #                 Docs.update omega._id,
# #     #                     $set:
# #     #                         current_most_emotion:doc.max_emotion_name
# #     #                         current_max_emotion_percent: current_max_emotion_percent
# #     #                         emotion_color:emotion_color
# #     #     # for emotion in emotion_list
# #     #     #     emotion_match = match
# #     #     #     emotion_match.max_emotion_name = emotion
# #     #     #     found_emotions =
# #     #     #         Docs.find(emotion_match)
# #     #     #
# #     #     #     # Docs.update omega._id,
# #     #     #     #     $set:
# #     #     #     #         "current_#{emotion}_count":found_emotions.count()
# #     #     #     if omega.current_most_emotion < found_emotions.count()
# #     #     #         current_most_emotion = emotion
# #     #     #         current_max_emotion_count = found_emotions.count()
# #     #     # # console.log 'current_most_emotion ', current_most_emotion
# #     #     emotion_match = match
# #     #     emotion_match.max_emotion_name = $exists:true
# #     #     # main_emotion = Docs.findOne(emotion_match)
# #     #
# #     #     # for doc_id in omega.doc_result_ids
# #     #     #     doc = Docs.findOne(doc_id)
# #     #     # if main_emotion
# #     #     #     console.log main_emotion
# #     #     #     Docs.update omega._id,
# #     #     #         $set:
# #     #     #             emotion_color:emotion_color
# #     #     #             max_emotion_name:main_emotion.max_emotion_name
# Meteor.methods
#     log_view: (doc_id)->
#         Docs.update doc_id,
#             $inc:views:1

#     create_delta: ->
#         # console.log @
#         Docs.insert
#             model:'model'
#             slug:'model'



#     add_user: (username)->
#         options = {}
#         options.username = username

#         res= Accounts.createUser options
#         if res
#             return res
#         else
#             Throw.new Meteor.Error 'err creating user'

#     parse_keys: ->
#         cursor = Docs.find
#             model:'key'
#         for key in cursor.fetch()
#             # new_building_number = parseInt key.building_number
#             new_unit_number = parseInt key.unit_number
#             Docs.update key._id,
#                 $set:
#                     unit_number:new_unit_number


#     change_username:  (user_id, new_username) ->
#         user = Meteor.users.findOne user_id
#         Accounts.setUsername(user._id, new_username)
#         return "Updated Username to #{new_username}."


#     add_email: (user_id, new_email) ->
#         Accounts.addEmail(user_id, new_email);
#         Accounts.sendVerificationEmail(user_id, new_email)
#         return "updated Email to #{new_email}"

#     remove_email: (user_id, email)->
#         # user = Meteor.users.findOne username:username
#         Accounts.removeEmail user_id, email


#     verify_email: (user_id, email)->
#         user = Meteor.users.findOne user_id
#         console.log 'sending verification', user.username
#         Accounts.sendVerificationEmail(user_id, email)

#     validate_email: (email) ->
#         re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
#         re.test String(email).toLowerCase()


#     notify_message: (message_id)->
#         message = Docs.findOne message_id
#         if message
#             to_user = Meteor.users.findOne message.to_user_id

#             message_link = "https://www.dao.af/user/#{to_user.username}/messages"

#         	Email.send({
#                 to:["<#{to_user.emails[0].address}>"]
#                 from:"relay@dao.af"
#                 subject:"dao message from #{message._author_username}"
#                 html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
#                     "<br><h4>view your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
#             })

#     checkout_students: ()->
#         now = Date.now()
#         # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()
#         checkedin_sessions = Docs.find(
#             model:'healthclub_session',
#             active:true
#             garden_key:$ne:true
#             ).fetch()


#         for session in checkedin_sessions
#             # checkedin_doc =
#             #     Docs.findOne
#             #         user_id:student._id
#             #         model:'healthclub_checkin'
#             #         active:true
#             diff = now-session._timestamp
#             minute_difference = diff/1000/60
#             if minute_difference>60
#                 # Meteor.users.update(student._id,{$set:healthclub_checkedin:false})
#                 Docs.update session._id,
#                     $set:
#                         active:false
#                         logout_timestamp:Date.now()
#                 # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()

#     check_student_status: (user_id)->
#         user = Meteor.users.findOne user_id



#     checkout_user: (user_id)->
#         Meteor.users.update user_id,
#             $set:
#                 healthclub_checkedin:false
#         checkedin_doc =
#             Docs.findOne
#                 user_id:user_id
#                 model:'healthclub_checkin'
#                 active:true
#         if checkedin_doc
#             Docs.update checkedin_doc._id,
#                 $set:
#                     active:false
#                     logout_timestamp:Date.now()

#         Docs.insert
#             model:'log_event'
#             parent_id:user_id
#             object_id:user_id
#             user_id:user_id
#             body: "#{@first_name} #{@last_name} checked out."



#     lookup_user: (username_query, role_filter)->
#         if role_filter
#             Meteor.users.find({
#                 username: {$regex:"#{username_query}", $options: 'i'}
#                 roles:$in:[role_filter]
#                 },{limit:10}).fetch()
#         else
#             Meteor.users.find({
#                 username: {$regex:"#{username_query}", $options: 'i'}
#                 },{limit:10}).fetch()

#     lookup_user_by_code: (healthclub_code)->
#         unless isNaN(healthclub_code)
#             Meteor.users.findOne({
#                 healthclub_code:healthclub_code
#                 })

#     lookup_doc: (guest_name, model_filter)->
#         Docs.find({
#             model:model_filter
#             guest_name: {$regex:"#{guest_name}", $options: 'i'}
#             },{limit:10}).fetch()

#     lookup_project: (project_title)->
#         Docs.find({
#             model:'project'
#             title: {$regex:"#{project_title}", $options: 'i'}
#             }).fetch()

#     lookup_task_list: (title)->
#         Docs.find({
#             model:'task_list'
#             title: {$regex:"#{title}", $options: 'i'}
#             }).fetch()

#     # lookup_username: (username_query)->
#     #     found_users =
#     #         Docs.find({
#     #             model:'person'
#     #             username: {$regex:"#{username_query}", $options: 'i'}
#     #             }).fetch()
#     #     found_users

#     # lookup_first_name: (first_name)->
#     #     found_people =
#     #         Docs.find({
#     #             model:'person'
#     #             first_name: {$regex:"#{first_name}", $options: 'i'}
#     #             }).fetch()
#     #     found_people
#     #
#     # lookup_last_name: (last_name)->
#     #     found_people =
#     #         Docs.find({
#     #             model:'person'
#     #             last_name: {$regex:"#{last_name}", $options: 'i'}
#     #             }).fetch()
#     #     found_people


#     set_password: (user_id, new_password)->
#         Accounts.setPassword(user_id, new_password)


#     keys: (specific_key)->
#         start = Date.now()

#         if specific_key
#             cursor = Docs.find({
#                 "#{specific_key}":$exists:true
#                 _keys:$exists:false
#                 }, { fields:{_id:1} })
#         else
#             cursor = Docs.find({
#                 _keys:$exists:false
#             }, { fields:{_id:1} })

#         found = cursor.count()

#         for doc in cursor.fetch()
#             Meteor.call 'key', doc._id

#         stop = Date.now()

#         diff = stop - start

#     key: (doc_id)->
#         doc = Docs.findOne doc_id
#         keys = _.keys doc

#         light_fields = _.reject( keys, (key)-> key.startsWith '_' )

#         Docs.update doc._id,
#             $set:_keys:light_fields


#     global_remove: (keyname)->
#         result = Docs.update({"#{keyname}":$exists:true}, {
#             $unset:
#                 "#{keyname}": 1
#                 "_#{keyname}": 1
#             $pull:_keys:keyname
#             }, {multi:true})


#     count_key: (key)->
#         count = Docs.find({"#{key}":$exists:true}).count()




#     slugify: (doc_id)->
#         doc = Docs.findOne doc_id
#         slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
#         return slug
#         # # Docs.update { _id:doc_id, fields:field_object },
#         # Docs.update { _id:doc_id, fields:field_object },
#         #     { $set: "fields.$.slug": slug }


#     rename: (old, newk)->
#         old_count = Docs.find({"#{old}":$exists:true}).count()
#         new_count = Docs.find({"#{newk}":$exists:true}).count()
#         result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
#         result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

#         # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
#         cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

#         for doc in cursor.fetch()
#             Meteor.call 'key', doc._id




#     detect_fields: (doc_id)->
#         doc = Docs.findOne doc_id
#         keys = _.keys doc
#         light_fields = _.reject( keys, (key)-> key.startsWith '_' )

#         Docs.update doc._id,
#             $set:_keys:light_fields

#         for key in light_fields
#             value = doc["#{key}"]

#             meta = {}

#             js_type = typeof value


#             if js_type is 'object'
#                 meta.object = true
#                 if Array.isArray value
#                     meta.array = true
#                     meta.length = value.length
#                     meta.array_element_type = typeof value[0]
#                     meta.field = 'array'
#                 else
#                     if key is 'watson'
#                         meta.field = 'object'
#                         # meta.field = 'watson'
#                     else
#                         meta.field = 'object'

#             else if js_type is 'boolean'
#                 meta.boolean = true
#                 meta.field = 'boolean'

#             else if js_type is 'number'
#                 meta.number = true
#                 d = Date.parse(value)
#                 # nan = isNaN d
#                 # !nan
#                 if value < 0
#                     meta.negative = true
#                 else if value > 0
#                     meta.positive = false

#                 integer = Number.isInteger(value)
#                 if integer
#                     meta.integer = true
#                 meta.field = 'number'


#             else if js_type is 'string'
#                 meta.string = true
#                 meta.length = value.length

#                 html_check = /<[a-z][\s\S]*>/i
#                 html_result = html_check.test value

#                 url_check = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
#                 url_result = url_check.test value

#                 youtube_check = /((\w|-){11})(?:\S+)?$/
#                 youtube_result = youtube_check.test value

#                 if key is 'html'
#                     meta.html = true
#                     meta.field = 'html'
#                 if key is 'youtube_id'
#                     meta.youtube = true
#                     meta.field = 'youtube'
#                 else if html_result
#                     meta.html = true
#                     meta.field = 'html'
#                 else if url_result
#                     meta.url = true
#                     image_check = (/\.(gif|jpg|jpeg|tiff|png)$/i).test value
#                     if image_check
#                         meta.image = true
#                         meta.field = 'image'
#                     else
#                         meta.field = 'url'
#                 # else if youtube_result
#                 #     meta.youtube = true
#                 #     meta.field = 'youtube'
#                 else if Meteor.users.findOne value
#                     meta.user_id = true
#                     meta.field = 'user_ref'
#                 else if Docs.findOne value
#                     meta.doc_id = true
#                     meta.field = 'doc_ref'
#                 else if meta.length is 20
#                     meta.field = 'image'
#                 else if meta.length > 20
#                     meta.field = 'textarea'
#                 else
#                     meta.field = 'text'

#             Docs.update doc_id,
#                 $set: "_#{key}": meta

#         # Docs.update doc_id,
#         #     $set:_detected:1

#         return doc_id


#     send_enrollment_email: (user_id, email)->
#         user = Meteor.users.findOne(user_id)
#         console.log 'sending enrollment email to username', user.username
#         Accounts.sendEnrollmentEmail(user_id)