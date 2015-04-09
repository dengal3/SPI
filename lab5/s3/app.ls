
class Button
	(@dom) ->
		@state = 'enabled'
		@name = @dom.find '.name' .text!
		@dom.add-class 'enabled'
		@dom.click !~> if @state is 'enabled'
			@@@disable-other-buttons @ if robot.state is 'enabled'
			@wait!
			@fetch-and-show-number!
#		@@@add-clicking-to-one-button @
		@xhr = null
		@fetch-and-show-number = !-> 
			@xhr = $.get '/'+robot.pointer , (number) !~>
				@done!
				@show-number number
				@@@check-to-active-the-bubble!
				robot.next-then-check-and-click-the-bubble! if robot.state is 'waiting'
				@@@enable-other-buttons @ if robot.state is 'enabled'
			robot.next-then-check-and-click-the-bubble! if robot.state is 'waiting'
		@@@buttons.push @
		

	@buttons = []

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
		for button in @buttons
			if button.xhr and button.xhr.readyState != 4
				button.xhr.abort!
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

	

	show-number: (number)!->
		@dom. find '.number' .text number

add-clicking-to-fetch-numbers-to-buttons = (next)!->
	for let dom in $ '#control-ring .button'
		button = new Button ($ dom)

bubble = 
	initial: !->
		@obj = $ '.info'
		@obj.add-class 'disabled'
		@obj.click !~> if @obj.has-class 'enabled'
			@click-to-sum-and-show!	

	click-to-sum-and-show: !->
		sum = 0
		for dom in $ '.button'
			sum += parse-int ($(dom).find '.number' .text!)
		@obj.find '.sum' .text sum
	reset: !->
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
			set-timeout !~>
				@bubble.click!
				@state = "done" if Button.check-to-active-the-bubble!
			, 0
		else @get-the-next-button!.click!
	get-the-next-button: ->
		@buttons[@order[@pointer++]]
	reset: !->
		@state = "enabled"
		@pointer = 0
		@bubble.find '.order' .text ''
	show-order: !->
		@bubble.find '.order' .text [String.from-char-code number+'A'.char-code-at! for number in @order].join ' '

s2-robot = !->
	robot.initial!

s4-robot = !->
	robot.initial!
	robot.order.sort -> Math.random! > 0.5

s3-robot = !->
	robot.initial!

$ !->
	add-clicking-to-fetch-numbers-to-buttons!
	bubble.initial!
	s3-robot!
	add-resetting-when-leave-app!