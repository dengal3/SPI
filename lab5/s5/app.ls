
class Button
	(@dom, @good-message, @bad-message, @feedback) ->
		@state = 'enabled'
		@name = @dom.find '.name' .text!
		@dom.add-class 'enabled'
		@dom.click !~> if @state is 'enabled'
			@@@disable-other-buttons @
			@wait!
			@fetch-and-show-number!
#		@@@add-clicking-to-one-button @
		@@@buttons.push @

	@buttons = []
	@xhr = null

#	@add-clicking-to-one-button = (button, next)!->
#		let next-operation = next
#			button.dom.click !~> if button.state is 'enabled'
#				@disable-other-buttons button
#				button.wait!
#				button.fetch-and-show-number next-operation

	@disable-other-buttons = (the-clicked-button) !->
		for button in @buttons when button.state isnt 'done' and button isnt the-clicked-button
			button.disable!

	@enable-other-buttons = (the-clicked-button)!->
		for button in @buttons when button.state isnt 'done' and button isnt the-clicked-button
			button.enable! 

	@check-to-active-the-bubble = ->
		for button in @buttons when button.state isnt 'done'
			return false
		bubble.enable-the-bubble!
		true

	@reset = !->
		if @xhr and @xhr.readyState != 4
			@xhr.abort!
		for button in @buttons
			button.state = 'enabled'
			button.dom.find '.number' .text ''
			button.dom.find '.number' .css 'display','none'
			button.dom.remove-class 'disabled done waiting enabled' .add-class 'enabled'

	wait: !->
		@state = "waiting"; @dom .remove-class 'enabled' .add-class 'waiting'
		@dom.find '.number' .text '...'
		@dom .find '.number' .css 'display','block'

	done: !->
		@state = "done"; @dom .remove-class 'waiting' .add-class 'done'
	disable: !->
		@state = "disabled"; @dom .remove-class 'enabled' .add-class 'disabled'
	enable: !->
		@state = "enabled"; @dom .remove-class 'disabled' .add-class 'enabled'

	fetch-and-show-number: !-> 
		@@@xhr = $.get '/' , (number) !~>
				@done!
				@show-number number
				@@@check-to-active-the-bubble!
				@@@enable-other-buttons @
				@success-or-fail number
				robot.next-then-check-and-click-the-bubble! if robot.state is 'waiting'
				

	show-number: (number)!->
		@dom. find '.number' .text number
	success-or-fail: (number)!->
		if Math.random! > 0.5
			bubble.show-message @name,@good-message
			@feedback null,number
		else
			@feedback message:@bad-message,0


add-clicking-to-fetch-numbers-to-buttons = (next)!->
	good-message = ['这是个天大的秘密', '我不知道', '你不知道', '他不知道', '才怪']
	bad-message = ['这不是个天大的秘密', '我知道', '你知道', '他知道', '才怪']
	for let dom, i in $ '#control-ring .button'
		button = new Button ($ dom), good-message[i], bad-message[i], (error, number) !->
			if error
				console.log("#{button.name}: #{error.message}")
			bubble.sum += parse-int number


bubble = 
	initial: !->
		@obj = $ '.info'
		@sum = 0;
		@msg = $ '#msg';
		@obj.add-class 'disabled'
		@obj.click !~> if @obj.has-class 'enabled'
			@click-to-sum-and-show!

	show-message: (name,message)!->
		@obj .find '.word' .text name+": "+message

	click-to-sum-and-show: !->
#		for dom in $ '.button'
#			@sum += parse-int ($(dom).find '.number' .text!)
		@obj.find '.sum' .text @sum
	reset: !->
		@sum = 0
		@msg.text ''
		@obj.find '.sum' .text ''
		@obj.remove-class 'enabled' .add-class 'disabled'
	enable-the-bubble: !->
		@obj.remove-class 'disabled' .add-class 'enabled'


add-resetting-when-leave-app = !->
	app = $ '#at-plus-container'
	app .on 'mouseleave' !->
		Button.reset!
		bubble.reset!
		robot.reset!

robot = 
	initial: !->
		@app = $ '.icon'
		@buttons = $ '.button'
		@bubble = bubble.obj
		@order = [0,1,2,3,4]
		@pointer = 0
		@state = "enabled"
		@app.click !~> 
			@state = "waiting"
			@show-order! if @state is 'waiting'
			@next-then-check-and-click-the-bubble!

	next-then-check-and-click-the-bubble: !->
		if @pointer is @order.length 
			@bubble.click!
			@state = "done"
		else @get-the-next-button!.click!
	get-the-next-button: ->
		@buttons[@order[@pointer++]]
	reset: !->
		@pointer = 0
		@bubble.find '.order' .text ''
	show-order: !->
		@bubble.find '.order' .text [String.from-char-code number+'A'.char-code-at! for number in @order].join ' '

s2-robot = !->
	robot.initial!

s4-robot = !->
	robot.initial!
	robot.order.sort -> Math.random! > 0.5


$ !->
	add-clicking-to-fetch-numbers-to-buttons!
	bubble.initial!
	s4-robot!
	add-resetting-when-leave-app!