require! ['mongoose']

module.exports = mongoose.model 'Homework', {
    id: String,
    content: {type: String, default: ''},
    assignmentId: {type: String, default: 0},
    studentId: {type: String, default: ''},
    studentName: {type: String, default: ''}
    grade: {type: Number, default: -1}
}