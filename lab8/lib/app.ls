root = exports ? @

root.Users = new Mongo.Collection 'Users'
root.Assignments = new Mongo.Collection 'Assignments'
root.Homeworks = new Mongo.Collection 'Homeworks'

Router.configure {
    layoutTemplate: 'layout'
}

Router.route '/', {name:  'index'}

Router.route '/view/:_id', !->
    if (Session.get 'userType') is 'teacher'
        this.render 'teacher-view'
    else
        this.render 'student-view'

Meteor.startup ->