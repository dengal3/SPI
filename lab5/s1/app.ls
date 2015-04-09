
class Button
	(@dom) ->
		@state = 'enabled'
		@name = @dom.find '.name' .text!
		@dom.add-class 'enabled'
		@dom.click !~> if @state is 'enabled'
			@@@disable-other-buttons @
			@wait!
			@fetch-and-show-number!
		@@@buttons.push @

	@buttons = []
	@xhr = null

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

	show-number: (number)!->
		@dom. find '.number' .text number

	

add-clicking-to-fetch-numbers-to-buttons = !->
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


$ !->
	add-clicking-to-fetch-numbers-to-buttons!
	bubble.initial!
	add-resetting-when-leave-app!