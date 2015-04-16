require! {User:'../models/user', Homework:'../models/homework', Assignment:'../models/assignment', 'bcrypt-nodejs', 'passport-local'}
LocalStrategy = passport-local.Strategy

hash = (password)-> bcrypt-nodejs.hash-sync password, (bcrypt-nodejs.gen-salt-sync 10), null

module.exports = (passport)!-> passport.use 'signup',  new LocalStrategy pass-req-to-callback: true, (req, username, password, done)!->
  (error, user) <- User.find-one {username: username} 
  return (console.log "Error in signup: ", error ; done error) if error

  if user
    console.log msg = "User: #{username} already exists"
    done null, false, req.flash 'message', msg
  else
    new-user = new User {
      username  : username
      password  : hash password
      email     : req.param 'email'
      firstName : req.param 'firstName'
      lastName  : req.param 'lastName'
      user-type : req.param 'user-type'
    }
    new-user.save (error)->
      if error
        console.log "Error in saving user: ", error
        throw error
      else
        console.log "User registration success"
        done null, new-user 
