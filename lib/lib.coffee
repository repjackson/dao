@Docs = new Meteor.Collection 'docs'

@Tags = new Meteor.Collection 'tags'
@Tag_results = new Meteor.Collection 'tag_results'
@Terms = new Meteor.Collection 'terms'
@User_tags = new Meteor.Collection 'user_tags'
# @ph_tags = new Meteor.Collection 'ph_tags'
# @Dtag_results = new Meteor.Collection 'dtag_results'
# @Category_results = new Meteor.Collection 'category_results'
# @Pornstar_results = new Meteor.Collection 'pornstar_results'


if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    # console.log Meteor.settings.private.cloudinary_key
    # console.log Meteor.settings.private.cloudinary_secret
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.private.cloudinary_key
        api_secret: Meteor.settings.private.cloudinary_secret

Docs.helpers
    _author: -> Meteor.users.findOne @_author_id
    recipient: -> Meteor.users.findOne @recipient_id
    seller: -> Meteor.users.findOne @seller_id
    buyer: -> Meteor.users.findOne @buyer_id
    when: -> moment(@_timestamp).fromNow()
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    is_read: -> @read_ids and Meteor.userId() in @read_ids
    seven_tags: ->
        if @tags
            @tags[..7]
    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters

Meteor.users.helpers
    email_address: -> if @emails and @emails[0] then @emails[0].address
    email_verified: -> if @emails and @emails[0] then @emails[0].verified
    five_tags: ->
        if @tags
            @tags[..5]
    three_tags: ->
        if @tags
            @tags[..3]
    has_points: -> @points > 0
    name: ->
        if @nickname
            @nickname
        else 
            @username

Docs.before.insert (userId, doc)->
    if Meteor.user()
        doc._author_id = Meteor.userId()
        doc._author_username = Meteor.user().username
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")

    doc.app = 'dao'

    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    doc.points = 0
    if Meteor.user()
        Meteor.users.update Meteor.userId(),
            $inc:points:1
    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array
    return



Meteor.methods
    add_facet_filter: (delta_id, key, filter)->
        # if key is '_keys'
        #     new_facet_ob = {
        #         key:filter
        #         filters:[]
        #         res:[]
        #     }
        #     Docs.update { _id:delta_id },
        #         $addToSet: facets: new_facet_ob
        console.log delta_id
        console.log key
        console.log filter
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fum', delta_id, (err,res)->


    remove_facet_filter: (delta_id, key, filter)->
        # if key is '_keys'
        #     Docs.update { _id:delta_id },
        #         $pull:facets: {key:filter}
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fum', delta_id, (err,res)->


    upvote_sentence: (doc_id, sentence)->
        # console.log sentence
        if sentence.weight
            Docs.update(
                { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
                { $inc: { "tone.result.sentences_tone.$.weight": 1 } }
            )
        else
            Docs.update(
                { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
                { $set: { "tone.result.sentences_tone.$.weight": 1 } }
            )
    tag_sentence: (doc_id, sentence, tag)->
        # console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $addToSet: { "tone.result.sentences_tone.$.tags": tag } }
        )

    reset_sentence: (doc_id, sentence)->
        # console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $set: { "tone.result.sentences_tone.$.weight": -2 } }
        )


    downvote_sentence: (doc_id, sentence)->
        # console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $inc: { "tone.result.sentences_tone.$.weight": -1 } }
        )

    upvote: (doc_id,amount)->
        # console.log 'doc_id', doc_id
        # console.log '1', 1
        post = Docs.findOne doc_id
        Docs.update doc_id,
            $inc:points:1
        if Meteor.user()
            console.log 'doc_id', doc_id
            console.log 'amount', amount
            parent_doc = Docs.findOne doc_id
            voting_doc = 
                Docs.findOne 
                    model:'vote'
                    parent_id:doc_id
            unless voting_doc
                new_id = 
                    Docs.insert
                        model:'vote'
                        parent_id:doc_id
                voting_doc = Docs.findOne new_id   
            Docs.update voting_doc._id, 
                $inc:points:amount
            Meteor.users.update Meteor.userId(),
                $inc:points:-amount
            unless parent_doc._author_id is Meteor.userId()
                Meteor.users.update parent_doc._author_id,
                    $inc:points:amount
            voting_doc = Docs.findOne voting_doc._id
            if voting_doc.points > 0
                Docs.update doc_id,
                    $addToSet:
                        upvoter_ids:Meteor.userId()  
                        upvoter_usernames:Meteor.user().username  
                    $pull:
                        downvoter_usernames:Meteor.user().username  
                        downvoter_ids:Meteor.userId()  
            parent = Docs.findOne doc_id
            # console.log 'upvoting usernames', parent
                    
            # Meteor.call 'calc_user_stats', Meteor.userId(), ->

    downvote: (doc_id)->
        # console.log 'doc_id', doc_id
        # console.log '1', 1
        post = Docs.findOne doc_id
        Docs.update doc_id,
            $inc:points:-1
        if Meteor.user()
            vote_doc = 
                Docs.findOne 
                    model:'vote'
                    parent_id:doc_id
                    _author_id:Meteor.userId()
            unless vote_doc
                new_id = 
                    Docs.insert
                        model:'vote'
                        parent_id:doc_id
                        post_id:doc_id
                        post_author_username:post._author_username
                        post_author_id:post._author_id
                        post_title:post.title
                        post_tags:post.tags
                vote_doc = Docs.findOne new_id   
            Docs.update vote_doc._id, 
                $inc:points:1
            # console.log 'vote doc', vote_doc
            Meteor.users.update Meteor.userId(),
                $inc:points:-1
            unless post._author_id is Meteor.userId()
                Meteor.users.update post._author_id,
                    $inc:points:1
            # vote_doc = Docs.findOne vote_doc._id
            # if vote_doc.points > 0
            Docs.update doc_id,
                $addToSet:
                    upvoter_ids:Meteor.userId()  
                    upvoter_usernames:Meteor.user().username  
            # parent = Docs.findOne doc_id
            # console.log 'parent', parent
            Meteor.call 'calc_post_votes', doc_id, ->
            
            # console.log 'upvoting usernames', parent
                    
            # Meteor.call 'calc_user_stats', Meteor.userId(), ->
                