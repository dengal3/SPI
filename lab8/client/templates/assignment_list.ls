Meteor.subscribe 'assignments'

Tracker.autorun !->
    console.log  Session.get 'userType'


Template['assignment_list'].helpers {
    assignment:->
        assignment_list = []
        for assignment in Assignments.find!fetch!
            item = {}
            item.assignmentId = assignment._id
            item.requirement = assignment.requirement
            item.deadline = assignment.deadline.getFullYear!+'.'+(assignment.deadline.getMonth!+1)+'.'+assignment.deadline.getDate!+' '+assignment.deadline.getHours!+':'+('0'+assignment.deadline.getMinutes()).slice(-2)
            assignment_list.push item
        console.log assignment_list
        assignment_list
    teacher:->
        console.log (Session.get 'userType')
        (Session.get 'userType') is 'teacher'
}

Template['assignment_list'].events {
    'click .logout': (ev, tpl)!->
        ev.prevent-default!
        console.log 'assignment_list debug'
        Meteor.logout!
    'click button.add_assignment': (ev, tpl)!->
            ev.prevent-default!
            new-assignment = {
                requirement: ($ 'input[name=requirement]')[0].value
                deadline:   new Date ($ 'input[name=deadline]')[0].value.replace 'T',' '
            }
            console.log new-assignment
            console.log new-assignment.deadline.toString!
            if new-assignment.requirement isnt '' and new-assignment.deadline.toString! != 'Invalid Date' 
                Meteor.call 'add_assignment', new-assignment, (err)!-> if err then console.log err else console.log 'add assignment successfully'
    'click #tab': (ev, tpl)!->
        ev.prevent-default!
        $(ev.target) .tab 'show'
}