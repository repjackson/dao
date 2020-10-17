Meteor.methods
    remove_tag: (tag)->
        # console.log 'tag', tag
        results =
            Docs.find {
                tags: $in: [tag]
            }
        # console.log 'pulling tags', results.count()
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag
            console.log res



    omega: (term)->
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        #     console.log res
        #     console.log 'res from async agg'
        if term
            term_doc =
                Docs.findOne(
                    title:term
                    model:'term'
                )
            unless term_doc
                console.log 'creating term doc'
                new_id = 
                    Docs.insert 
                        model:'term'
                        title:term
                term_doc = Docs.findOne new_id 
            if term_doc
                agg_res = Meteor.call 'omega2', term
                # console.log 'hi'
                console.log 'agg res', agg_res
                # omega = Docs.findOne model:'omega_session'
                # doc_count = omega.total_doc_result_count
                # doc_count = omega.doc_result_ids.length
                # unless omega.selected_doc_id in omega.doc_result_ids
                #     Docs.update omega._id,
                #         $set:selected_doc_id:omega.doc_result_ids[0]
                # console.log 'doc count', doc_count
                # filtered_agg_res = []
    
                # for agg_tag in agg_res
                #     # if agg_tag.count < doc_count
                #         # filtered_agg_res.push agg_tag
                #         if agg_tag.title
                #             if agg_tag.title.length > 0
                #                 # console.log 'agg tag', agg_tag
                #                 filtered_agg_res.push agg_tag
                # console.log 'max term emotion', _.max(filtered_agg_res, (tag)->tag.count)
                # term_emotion = _.max(filtered_agg_res, (tag)->tag.count).title
                # if term_emotion
                #     Docs.update term_doc._id,
                #         $set:
                #             agg_emotion_name:term_emotion
                # console.log 'term final emotion', term_emotion
    
                # Docs.update omega._id,
                #     $set:
                #         # agg:agg_res
                #         filtered_agg_res:filtered_agg_res
    omega2: (term)->
        # omega =
        #     Docs.findOne
        #         model:'omega_session'

        console.log 'running agg omega', term
        match = {tags:$in:[term]}
        # match = {max_emotion_name:$exists:true}
        # if omega.selected_tags.length > 0
        #     match.tags =
        #         $all: omega.selected_tags
        # else
        #     match.tags =
        #         $all: ['dao']

        # console.log 'running agg omega', omega
        match.model = $in:['wikipedia']
        # console.log 'doc_count', Docs.find(match).count()
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        console.log 'doc result count',  total_doc_result_count
        # doc_results =
        #     Docs.find( match,
        #         {
        #             limit:20
        #             sort:
        #                 points:-1
        #                 ups:-1
        #             fields:
        #                 _id:1
        #         }
        #     ).fetch()
        # console.log doc_results
        # if doc_results[0]
        #     unless doc_results[0].rd
        #         if doc_results[0].reddit_id
        #             Meteor.call 'get_reddit_post', doc_results[0]._id, doc_results[0].reddit_id, =>
        # console.log doc_results
        # doc_result_ids = []
        # for result in doc_results
        #     doc_result_ids.push result._id
        # console.log _.keys(doc_results,'_id')
        # Docs.update omega._id,
        #     $set:
        #         doc_result_ids:doc_result_ids
        #         total_doc_result_count:total_doc_result_count
        # if doc_re
        # found_wiki_doc =
        #     Docs.findOne
        #         model:'wikipedia'
        #         title:$in:omega.selected_tags
        # if found_wiki_doc
        #     Docs.update omega._id,
        #         $addToSet:
        #             doc_result_ids:found_wiki_doc._id

        # Docs.update omega._id,
        #     $set:
        #         match:match
        # limit=20
        options = {
            explain:false
            allowDiskUse:true
        }

        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 33
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: max_emotion_name: 1 }
            # { $unwind: "$max_emotion_name" }
            { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 5 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
                # printed = console.log(agg.toArray())
                # # console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null




    # get_top_emotion: ->
    #     # console.log 'getting emotion'
    #     emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
    #     #
    #     current_most_emotion = ''
    #     current_max_emotion_count = 0
    #     current_max_emotion_percent = 0
    #     omega = Docs.findOne model:'omega_session'
    #     # doc_results =
    #         # Docs.find
    #
    #     match = {_id:$in:omega.doc_result_ids}
    #     for doc_id in omega.doc_result_ids
    #         doc = Docs.findOne(doc_id)
    #         if doc.max_emotion_percent
    #             if doc.max_emotion_percent > current_max_emotion_percent
    #                 current_max_emotion_percent = doc.max_emotion_percent
    #                 if doc.max_emotion_name is 'anger'
    #                     emotion_color = 'green'
    #                 else if doc.max_emotion_name is 'disgust'
    #                     emotion_color = 'teal'
    #                 else if doc.max_emotion_name is 'sadness'
    #                     emotion_color = 'orange'
    #                 else if doc.max_emotion_name is 'fear'
    #                     emotion_color = 'grey'
    #                 else if doc.max_emotion_name is 'joy'
    #                     emotion_color = 'red'
    #
    #                 Docs.update omega._id,
    #                     $set:
    #                         current_most_emotion:doc.max_emotion_name
    #                         current_max_emotion_percent: current_max_emotion_percent
    #                         emotion_color:emotion_color
    #     # for emotion in emotion_list
    #     #     emotion_match = match
    #     #     emotion_match.max_emotion_name = emotion
    #     #     found_emotions =
    #     #         Docs.find(emotion_match)
    #     #
    #     #     # Docs.update omega._id,
    #     #     #     $set:
    #     #     #         "current_#{emotion}_count":found_emotions.count()
    #     #     if omega.current_most_emotion < found_emotions.count()
    #     #         current_most_emotion = emotion
    #     #         current_max_emotion_count = found_emotions.count()
    #     # # console.log 'current_most_emotion ', current_most_emotion
    #     emotion_match = match
    #     emotion_match.max_emotion_name = $exists:true
    #     # main_emotion = Docs.findOne(emotion_match)
    #
    #     # for doc_id in omega.doc_result_ids
    #     #     doc = Docs.findOne(doc_id)
    #     # if main_emotion
    #     #     console.log main_emotion
    #     #     Docs.update omega._id,
    #     #         $set:
    #     #             emotion_color:emotion_color
    #     #             max_emotion_name:main_emotion.max_emotion_name 
