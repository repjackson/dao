Meteor.publish 'model_docs', (model,limit)->
    if limit
        Docs.find {
            model: model
            # app:'nf'
        }, 
            limit:limit
    else
        Docs.find {
            # app:'nf'
            model: model
        }, sort:_timestamp:-1
Meteor.publish 'me', ->
    Meteor.users.find({_id:@userId},{
        # fields:
        #     username:1
        #     image_id:1
        #     tags:1
        #     points:1
    })

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug



Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find doc._author_id
