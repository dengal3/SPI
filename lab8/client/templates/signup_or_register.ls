Template['signup_or_register'].helpers {
    /*  return login to show the login view or the register view */
}

Template['signup_or_register'].events {
    'click button.register': (ev, tpl) !->
        ev.prevent-default!
        console.log 'signup_or_register debug'
        username = ($ '#add-user input[name=username]')[0].value
        user-type = ($ '#add-user select[name=user-type]')[0].value
        password= ($ '#add-user input[name=password]')[0].value
        console.log username+password+user-type
        console.log 'click .button.register begug'
        user = {
            username: username,
            password: password,
            profile: {
                user-type: user-type
            }
        }
        /*Users.insert user*/
        console.log 'register debug'
        Meteor.call 'register_handler', user,  (err) !~>
            if err then console.log err else
                Session.set 'userType', user-type
                Meteor.loginWithPassword user.username, user.password

    'click button.login': (ev, tpl)!->
        ev.prevent-default!
        console.log 'login debug'
        username = ($ '#login-user input[name=username]')[0].value
        password= ($ '#login-user input[name=password]')[0].value
        /*
        Meteor.call 'login_validate', username, password, (err)!->
            console.log err if err
        */
        Meteor.loginWithPassword username,password,(err)!->
            if err then alert err else Session.set 'userType', Meteor. user!. profile['userType']

    'click a.to-login': (ev, tpl)!->
        ev.prevent-default!
        $('#login-user').css 'display' 'block'
        $('#add-user').css 'display' 'none'

    'click a.to-register': (ev, tpl)!->
        ev.prevent-default!
        $('#login-user').css 'display' 'none'
        $('#add-user').css 'display' 'block'

}