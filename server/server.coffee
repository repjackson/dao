# tsqp-gebk-xhpz-eobp-agle



Docs.allow
    insert: (user_id, doc) ->
        true
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        # else
        #     user_id is doc._author_id
    update: (user_id, doc) ->
        user = Meteor.users.findOne user_id
        console.log user_id
        console.log doc._author_id
        if user_id is doc._author_id
            true
        else if user.roles and 'admin' in user.roles
            true
        else if doc.model is 'event'
            if Meteor.userId() is doc.facilitator_id
                true
    remove: (user_id, doc) ->
        user = Meteor.users.findOne user_id
        if user.roles and 'admin' in user.roles
            true
        else
            user_id is doc._author_id


Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'dev' in user.roles
            true
        else
            if user_id and doc._id == user_id
                true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'dev' in user.roles
            true
        # if userId and doc._id == userId
        #     true
