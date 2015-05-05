Template['student-view'].helpers {
    assignment:->
        assignment = {}
        obj = Assignments.find-one {_id: Router.current!.params['_id']}
        assignment.requirement = obj.requirement
        assignment.deadline =  obj.deadline.getFullYear!+'.'+(obj.deadline.getMonth!+1)+'.'+obj.deadline.getDate!+' '+obj.deadline.getHours!+':'+('0'+obj.deadline.getMinutes()).slice(-2)
        assignment
    homework:->
        homework = Homeworks.find-one {assignment-id: Router.current!.params['_id'], student-id: Meteor.userId!}
        if homework
            homework
        else
            'you havent submit the homework yet'
    time-up:->
        Assignments.find-one {_id: Router.current!.params['_id']} .deadline <= new Date
    no-grade:->
        Homeworks.find-one {assignment-id: Router.current!.params['_id'],  student-id:Meteor.userId!} .grade < 0

}

Template['student-view'].events {
    'click #submit-homework': (ev, tpl)->
        ev.prevent-default!
        obj = {}
        obj.homework-content = ($ 'textArea[name=homeworkContent]')[0].value
        obj.assignment-id = Router.current!.params['_id']
        obj.student-id = Meteor.userId!
        obj.student-name = Meteor.user!.username
        obj.grade = -1
        Meteor.call 'upload_homework', obj, (err)!->
            console.log err if err
    'click .back':(ev, tpl)!->
        ev.prevent-default!
        Router.go '/'
}