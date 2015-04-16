require! ['mongoose']

module.exports = mongoose.model 'Assignment', {
	id: String,
	requirement: {type: String, default: ''},
	deadline: {type: Date, default: Date.now}
}