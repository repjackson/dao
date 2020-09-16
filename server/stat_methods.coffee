Meteor.methods
    calc_post_votes: (post_id)->
        post = Docs.findOne post_id
        # console.log 'post', doc
        votes = 
            Docs.find 
                model:'vote'
                parent_id:post_id
        total_doc_points = 0
        for vote in votes.fetch()
            # console.log 'found vote', vote
            total_doc_points += vote.points
            # console.log 'found total_doc_points', total_doc_points
        # console.log 'found total_doc_points final', total_doc_points
        Docs.update post._id, 
            $set:points:total_doc_points
        
        
        imported_point_total = 0
        imported_points_cur = 
            Docs.find(
                model:'vote'
                parent_id:post_id
                _author_id:$ne:post._author_id
            )
        for imported in imported_points_cur.fetch()
            console.log 'imported', imported
            imported_point_total += imported.points
        console.log 'imported', imported_point_total
        Docs.update post._id, 
            $set:
                imported_points: imported_point_total
        console.log 'end find doc', Docs.findOne doc_id

    # calc_user_stats: (user_id)->
    #     user = Meteor.users.findOne user_id
    #     gift_count =
    #         Docs.find(
    #             model:'gift'
    #             _author_id: user_id
    #         ).count()

    #     credit_count =
    #         Docs.find(
    #             model:'gift'
    #             target_id: user_id
    #         ).count()

    #     Meteor.users.update user_id,
    #         $set:
    #             gift_count:gift_count
    #             credit_count:credit_count


    #     gift_count_ranking =
    #         Meteor.users.find(
    #             {},
    #             sort:
    #                 gift_count: -1
    #             fields:
    #                 username: 1
    #         ).fetch()
    #     gift_count_ranking_ids = _.pluck gift_count_ranking, '_id'

    #     console.log 'gift_count_ranking', gift_count_ranking
    #     console.log 'gift_count_ranking ids', gift_count_ranking_ids
    #     my_rank = _.indexOf(gift_count_ranking_ids, user_id)+1
    #     console.log 'my rank', my_rank
    #     Meteor.users.update user_id,
    #         $set:
    #             global_gift_count_rank:my_rank


    #     credit_count_ranking =
    #         Meteor.users.find(
    #             {},
    #             sort:
    #                 credit_count: -1
    #             fields:
    #                 username: 1
    #         ).fetch()
    #     credit_count_ranking_ids = _.pluck credit_count_ranking, '_id'

    #     console.log 'credit_count_ranking', credit_count_ranking
    #     console.log 'credit_count_ranking ids', credit_count_ranking_ids
    #     my_rank = _.indexOf(credit_count_ranking_ids, user_id)+1
    #     console.log 'my rank', my_rank
    #     Meteor.users.update user_id,
    #         $set:
    #             global_credit_count_rank:my_rank


    log_term: (term_title)->
        # console.log 'logging term', term
        found_term =
            Terms.findOne
                title:term_title
                app:'dao'
        unless found_term
            Terms.insert
                title:term_title
                app:'dao'
            # if Meteor.user()
            #     Meteor.users.update({_id:Meteor.userId()},{$inc: points: 1}, -> )
            # console.log 'added term', term
        else
            Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
            # console.log 'found term', term
            # Meteor.call 'call_wiki', @term_title, =>
            #     Meteor.call 'calc_term', @term_title, ->


    # calc_finance_stats: ()->
    #     fs = Docs.findOne model:'finance_stat'
    #     unless fs 
    #         Docs.insert 
    #             model:'finance_stat'
    #     fs = Docs.findOne model:'finance_stat'
        
    #     total_expense_sum = 0
        
    #     expenses = 
    #         Docs.find 
    #             model:'expense'
    #     for expense in expenses.fetch()
    #         total_expense_sum += expense.dollar_amount
    
    #     total_membership_sum = 0
    #     memberships = 
    #         Docs.find 
    #             model:'expense'
    #             membership:true
    #     for membership in memberships.fetch()
    #         total_membership_sum += membership.dollar_amount
    
    #     console.log 'total expenses', total_expense_sum
    #     Docs.update fs._id,
    #         $set:
    #             total_expense_sum:total_expense_sum
    #             total_expense_count:expenses.count()
    #             membership_count:memberships.count()
    #             total_membership_sum:total_membership_sum


    # calc_user_points: (user_id)->
    #     user = Meteor.users.findOne user_id
    #     debits = Docs.find({
    #         model:'debit'
    #         amount:$exists:true
    #         _author_id:user_id})
    #     debit_count = debits.count()
    #     total_debit_amount = 0
    #     for debit in debits.fetch()
    #         total_debit_amount += debit.amount

    #     console.log 'total debit amount', total_debit_amount

    #     credits = Docs.find({
    #         model:'debit'
    #         amount:$exists:true
    #         recipient_id:user_id})
    #     credit_count = credits.count()
    #     total_credit_amount = 0
    #     for credit in credits.fetch()
    #         total_credit_amount += credit.amount

    #     console.log 'total credit amount', total_credit_amount
    #     calculated_user_balance = total_credit_amount-total_debit_amount

    #     Meteor.users.update user_id,
    #         $set:
    #             points:calculated_user_balance
    #             total_credit_amount: total_credit_amount
    #             total_debit_amount: total_debit_amount







    calc_global_stats: ()->
        gs = Docs.findOne model:'global_stats'
        unless gs 
            Docs.insert 
                model:'global_stats'
        gs = Docs.findOne model:'global_stats'
        
        total_points = 0
        
        point_users = 
            Meteor.users.find 
                points: $exists:true
        for point_user in point_users.fetch()
            total_points += point_user.points
    
        console.log 'total points', total_points
        Docs.update gs._id,
            $set:total_points:total_points