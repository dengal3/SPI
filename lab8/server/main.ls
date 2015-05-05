Meteor.publish 'assignments', ->  
    Assignments.find!
Meteor.publish 'homeworks', ->
    Homeworks.find!

Meteor.methods {
    register_handler: (user) !->
        console.log 'register_handler debug'
        if Meteor.users.findOne {username:user['username']}
            throw new Meteor.Error 'There is a username exsiting before.Try another one pls'
        return Accounts.createUser user
    add_assignment: (new-assignment) ->
        console.log new-assignment
        console.log new-assignment.deadline.toString!
        Assignments.insert new-assignment
    upload_homework: (homework)->
        console.log homework
        if Homeworks.find-one {assignment-id: homework.assignment-id, student-id: homework.student-id}
            Homeworks.update {assignment-id: homework.assignment-id, student-id: homework.student-id}, {$set: {homework-content: homework.homework-content}}
        else Homeworks.insert homework
    modify_requirement: (new-requirement, _id)->
        Assignments.update {_id: _id}, {$set: {requirement: new-requirement}}
    modify_deadline: (new-deadline, _id)->
        Assignments.update {_id: _id}, {$set: {deadline: new-deadline}}
    modify_grade: (new-grade, _id)->
        Homeworks.update {_id:_id}, {$set: {grade: new-grade}}
}

