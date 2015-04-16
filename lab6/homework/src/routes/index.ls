require! {User:'../models/user', Homework:'../models/homework', Assignment:'../models/assignment', express}
router = express.Router! 

is-authenticated = (req, res, next)-> if req.is-authenticated! then next! else res.redirect '/'

is-out-date = (deadline)-> new Date > deadline


module.exports = (passport)->
  router.get '/', (req, res)!-> res.render 'index', message: req.flash 'message'

  router.post '/login', passport.authenticate 'login', {
    success-redirect: '/home', failure-redirect: '/', failure-flash: true
  }

  router.get '/signup', (req, res)!-> res.render 'register', message: req.flash 'message'

  router.post '/signup', passport.authenticate 'signup', {
    success-redirect: '/home', failure-redirect: '/signup', failure-flash: true
  }

  router.get '/home', is-authenticated, (req, res)!-> res.render 'home', user: req.user

  router.get '/signout', (req, res)!-> 
    req.logout!
    res.redirect '/'

  #/assignment-->redirect to student and teacher page
  router.get '/assignment', is-authenticated, (req, res)!->
    username = req.user.username
    console.log username
    User.findOne {username:username}, (err, doc) !->
        console.log doc
        if err
          console.log "error occurs while getting assignment list!"
        else 
          if doc.userType is 'student'
            console.log "fine"
            res.redirect '/assignment/student/'+doc.id
          else res.redirect '/assignment/teacher/'+doc.id 

  #/assignment/teacher/ ---> operations available and show assignments list
  router.get '/assignment/teacher/:id', is-authenticated, (req, res)!->
    Assignment.find (err, docs)!->
      if err
        console.log 'error occurs while querying assignments!'
      else 
        res.render 'assignment', assignments:docs, userType:'teacher', userId: req.user._id

  #/assignment/teacher/ ---> operations inavailable and show assignments list
  router.get '/assignment/student/:id', is-authenticated, (req, res)!->
    Assignment.find (err, docs)!->
      if err
        console.log 'error occurs while querying assignments!'
      else 
        console.log docs
        res.render 'assignment', assignments:docs, userType:'student', userId: req.user._id

  #/assignment-student-view/-->show an assignment under student's view
  router.get '/assignment-student-view/:userId/:assignmentId', is-authenticated, (req, res)!->
    userId = req.params.userId
    assignmentId = req.params.assignmentId
    #find the assignment
    Assignment.find-by-id assignmentId, (err, the-assignment)!->
      if err
        console.log '在找作业任务的时候出错QAQ'
      else
        console.log '成功找到作业任务^-^'
        requirement = the-assignment.requirement
        deadline = the-assignment.deadline
        time-up = is-out-date deadline
        #check whether there is a piece of homework related to the assignment
        Homework.find-one {studentId: userId, assignmentId: assignmentId}, (err, homework-set)!->
          if err
            console.log  '在作业库中找这个学生对应这个任务的作业的时候出错QAQ'
          else
            homework-content = '还不交作业，取消你学士学位咯'
            grade = -1
            #if there exist former version homework
            console.log '成功地在作业库中找到这个学生对应这个任务的作业,不过这时候可能为空哦'
            if homework-set isnt null  #如果不是空的话就返回这个作业的内容
              console.log homework-content
              homework-content = homework-set.content #返回这个作业的内容^-^
              grade = homework-set.grade
            res.render 'student-view', homeworkContent: homework-content, requirement:requirement, deadline:deadline, userId:userId, assignmentId:assignmentId, time-up: time-up, grade:grade
  
  #/homework-submit/-->sumbit the homework and insert/update it into database
  router.post '/homework-submit/:userId/:assignmentId', is-authenticated, (req, res)!-> 
    userId = req.params.userId
    assignmentId = req.params.assignmentId
    content = req.body.homeworkContent
    console.log content
    Homework.find-one {studentId: userId, assignmentId: assignmentId}, (err, homework-set)!->
      console.log '搜索该学生在该任务下的作业'
      if err
        console.log  '在搜索该学生在该任务下的作业时发生错误QAQ'
      else
        #if exists,update and remove the former veision homework from the db
        if homework-set isnt null
          Homework.update {_id: homework-set._id}, {$set: {content: content}}, (err, result) !-> #在db中移除原先的作业
            console.log '更新作业的版本'
            if err
              console.log err
            else
              console.log result
              res.redirect '/assignment-student-view/'+userId+'/'+assignmentId
        else
          User.find-by-id userId, (err, the-user)!->
            Homework.create {studentId: userId, assignmentId: assignmentId, content: content, studentName: the-user.username}, (err)!->
              if err
                console.log '在创建新作业时出错QAQ 你为什么要出错'
              else
                console.log '成功创建了新作业^-^'
                res.redirect '/assignment-student-view/'+userId+'/'+assignmentId

  router.post '/assignment-add/teacher/:userId', is-authenticated, (req, res)!->
    requirement = req.body.requirement
    deadline = req.body.deadline.replace 'T',' ' || '' if req.body.deadline
    console.log deadline
    userId = req.params.userId
    User.find-by-id userId, (err, the-user)!->
      Assignment.create {requirement:requirement, deadline:new Date deadline}, (err)!->
        if err
          console.log '增加新任务失败，是不是布置太多作业了=='
        else
          console.log '增加新任务成功'
          res.redirect '/assignment/teacher/'+userId

  #/assignment-teacher-view/-->show an assignment under teacher's view
  router.get '/assignment-teacher-view/:userId/:assignmentId', is-authenticated, (req, res)!->
    userId = req.params.userId
    assignmentId = req.params.assignmentId
    Homework.find {assignment-id: assignmentId}, (err, the-homework-list)!->
      if err
        console.log '在获取这个任务的作业列表时出错QAQ'
      else
        console.log '成功获取这个任务的作业列表，当然也有可能为空'
        Assignment.find-by-id assignmentId, (err, the-assignment)!->
          time-up = false
          console.log the-assignment.deadline
          time-up = true if is-out-date the-assignment.deadline
          console.log time-up
          res.render 'teacher-view', requirement:the-assignment.requirement, deadline: the-assignment.deadline, homeworks: the-homework-list, userType: 'teacher',userId: userId, assignmentId: the-assignment._id, time-up: time-up
  
  router.post '/modify/teacher/:userId/:assignmentId', (req, res)!->
    new-requirement = req.body.requirement || ''
    new-deadline = req.body.deadline.replace 'T',' ' || '' if req.body.deadline
    userId = req.params.userId
    assignmentId = req.params.assignmentId
    console.log new-deadline
    if new-requirement isnt ''
      Assignment.update {_id: assignmentId}, {$set: {requirement: new-requirement}}, (err, result)!->
        if err
          console.log '在更新任务的要求时出错QAQ'
        else
          console.log '成功更新任务的要求^-^'
          res.redirect '/assignment-teacher-view/'+userId+'/'+assignmentId
    else if new-deadline isnt ''
      Assignment.update {_id: assignmentId}, {$set: {deadline: new-deadline}}, (err, result)!->
        if err
          console.log '在更新任务的截止时间时出错QAQ'
        else
          console.log '成功更新任务的截止时间^-^'
          res.redirect '/assignment-teacher-view/'+userId+'/'+assignmentId
    else
      console.log '没什么都没有更新=='
      res.redirect '/assignment-teacher-view/'+userId+'/'+assignmentId

router.post '/grade/:userId/:assignmentId/:homeworkId', is-authenticated, (req, res)!->
  homework-id = req.params.homeworkId
  grade = req.body.grade
  user-id = req.params.userId
  assignment-id = req.params.assignmentId
  Homework.update {_id:homework-id}, {$set: {grade: grade}}, (err)!->
    if err
      console.log '在评分时出错QAQ'
    else
      console.log '成功完成评分~'
      res.redirect '/assignment-teacher-view/'+user-id+'/'+assignment-id

