Meteor.subscribe 'assignments'
Meteor.subscribe 'homeworks'

Template['teacher-view'].helpers {
    assignment: ->
                assignment = {}
                obj = Assignments.find-one {_id: Router.current!.params['_id']}
                assignment.requirement = obj.requirement
                assignment.deadline =  obj.deadline.getFullYear!+'.'+(obj.deadline.getMonth!+1)+'.'+obj.deadline.getDate!+' '+obj.deadline.getHours!+':'+('0'+obj.deadline.getMinutes()).slice(-2)
                assignment
    homeworks: ->
                homeworks = Homeworks.find {assignment-id: Router.current!.params['_id']} .fetch!
                homeworks-array = []
                console.log homeworks
                if homeworks.length > 0
                    for homework in homeworks
                        homework.no-grade = (homework.grade==-1)? true : false
                        homeworks-array.push homework
                    homeworks-array
                else
                    false
    time-up:->
        Assignments.find-one {_id: Router.current!.params['_id']} .deadline <= new Date
    no-grade:->
        Homeworks.find-one {assignment-id: Router.current!.params['_id'],  student-id:this.student-id} .grade < 0
    teacher:-> (Session.get 'userType') is 'teacher'
}

Template['teacher-view'].events {
    'click button.modify-requirement': (ev, tpl)->
         ev.prevent-default!
         new-requirement = ($ 'input[name=requirement]')[0].value
         _id = Router.current!.params['_id']
         Meteor.call 'modify_requirement', new-requirement, _id, (err)!->console.log err if err
    'click button.modify-deadline': (ev, tpl) ->
        ev.prevent-default!
        new-deadline = new Date ($ 'input[name=deadline]')[0].value.replace 'T',' '
        _id = Router.current!.params['_id']
        console.log new-deadline.toString!
        if new-deadline.toString! != 'Invalid Date' and new-deadline.toString! != ''
            Meteor.call 'modify_deadline', new-deadline, _id, (err)!->console.log err if err
    'click .back': (ev, tpl)!->
        ev.prevent-default!
        Router.go '/'
    'click .modify-grade': (ev, tpl)!->
        ev.prevent-default!
        Meteor.call 'modify_grade', $(ev.target).parent!.parent!.find('input[name=grade]')[0].value, this._id , (err)!->console.log err if err
    'click #tab': (ev, tpl)!->
        ev.prevent-default!
        $(ev.target) .tab 'show'
}