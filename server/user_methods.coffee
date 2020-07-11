Meteor.methods
    calc_user_stats: (user_id)->
        user = Meteor.users.findOne user_id
        debit_count =
            Docs.find(
                model:'debit'
                _author_id: user_id
            ).count()

        credit_count =
            Docs.find(
                model:'debit'
                target_id: user_id
            ).count()

        Meteor.users.update user_id,
            $set:
                debit_count:debit_count
                credit_count:credit_count


        debit_count_ranking =
            Meteor.users.find(
                {},
                sort:
                    debit_count: -1
                fields:
                    username: 1
            ).fetch()
        debit_count_ranking_ids = _.pluck debit_count_ranking, '_id'

        console.log 'debit_count_ranking', debit_count_ranking
        console.log 'debit_count_ranking ids', debit_count_ranking_ids
        my_rank = _.indexOf(debit_count_ranking_ids, user_id)+1
        console.log 'my rank', my_rank
        Meteor.users.update user_id,
            $set:
                global_debit_count_rank:my_rank


        credit_count_ranking =
            Meteor.users.find(
                {},
                sort:
                    credit_count: -1
                fields:
                    username: 1
            ).fetch()
        credit_count_ranking_ids = _.pluck credit_count_ranking, '_id'

        console.log 'credit_count_ranking', credit_count_ranking
        console.log 'credit_count_ranking ids', credit_count_ranking_ids
        my_rank = _.indexOf(credit_count_ranking_ids, user_id)+1
        console.log 'my rank', my_rank
        Meteor.users.update user_id,
            $set:
                global_credit_count_rank:my_rank
