window.onload = initPage;

//initial the page 
function initPage() {
	buttonsSetting();
	atplusSetting(null);
	iconSetting();
}

//create a request
function createRequest() {
  try {
    request = new XMLHttpRequest();
  } catch (tryMS) {
    try {
      request = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (otherMS) {
      try {
        request = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (failed) {
        request = null;
      }
    }
  }	
  return request;
}

// eventUtil
var EventUtil = {
	addHandler: function(element, type, handler) {
		if (element.addEventListener) {
			element.addEventListener(type, handler, false);
		} else if (element.attachEvent) {
			element.attachEvent("on"+type, handler);
		} else {
			element["on"+type] = handler;
		}
	},
	removeHandler: function(element, type, handler) {
		if (element.removeEventListener) {
			element.removeEventListener(type, handler, false);
		} else if (element.detachEvent) {
			element.detachEvent("on"+type, handler);
		} else {
			element["on"+type] = null;
		}
	}
}

//setting the icon onclick function
function iconSetting() {
	var icon = document.getElementsByClassName("icon")[0];
	EventUtil.addHandler(icon, "click", randomOrder);
}

function oneByOne(button_id) {
	return function() {
		var button = document.getElementsByClassName("button")[button_id];
		if (button_id <= 4) {
			buttonFunc(button_id, "oneByOne").call(button);
		} else {
			clickToSum();
		}
	}
}

function together() {
	var buttons = document.getElementsByClassName("button");

	for (var i = 0; i < buttons.length; i++) {
		buttonFunc(i, "together").call(buttons[i]);
	}
}

function randomOrder(num) {
	if (isNaN(num)) {
		num = 0;
	}
	randomOrder.order = randomOrder.order || [0, 1, 2, 3, 4];
	var buttons = document.getElementsByClassName("button");

	if (num === 0) {
		randomOrder.order.sort(function(a, b) {
			return Math.random() >= 0.5 ? 1 : -1;
		});
		showOrder(randomOrder.order);
	}
	buttonFunc(num, "random").call(buttons[randomOrder.order[num]]);
}

function showOrder(order) {
	var bigButton = document.getElementsByClassName("info")[0];
	var h3Node = document.createElement("h4");
	var text = "";

	for (var i = 0; i < order.length; i++) {
		text += order[i]+" ";
	}

	h3Node.appendChild(document.createTextNode(text));
	bigButton.appendChild(h3Node);
}

//setting the at plus onmouseover function
function atplusSetting(request) {
	var container = document.getElementById("at-plus-container");
	if (!container[onmouseleave]) {
		EventUtil.addHandler(container, "mouseleave", reset(request));
	}
}

function reset(request) {
	var resetfunc = function () {
		if (request != undefined) {
			request.abort();
		}

		buttonsReset();
		infoReset();
		iconReset();
		initPage();
	};
	return resetfunc;
	
}

function iconReset() {
	var icon = document.getElementsByClassName("icon")[0];
	EventUtil.removeHandler(icon, "click", randomOrder);
}

function buttonsReset() {
	//reset the buttons
	var buttons = document.getElementsByTagName("li");
	for (var i = 0; i < buttons.length; i++) {
		EventUtil.removeHandler(buttons[i], "click", buttonFunc);
		buttons[i].getElementsByTagName("span")[0].style.display = "none";
		buttons[i].className = buttons[i].className.replace("disabled", "").replace("clicked", "");
	}
}

function infoReset() {
	// reset the big button
	var sumNode = document.getElementsByTagName("h2");
	var orderNode = document.getElementsByTagName("h4");
	var info = document.getElementsByClassName("info")[0];

	if (sumNode.length) {
		sumNode[0].innerHTML = sumNode[0].innerHTML.replace(/\d/, "");
	}

	if(orderNode.length) {
		orderNode[0].parentNode.removeChild(orderNode[0]);
	}

	if (info["onclick"] != null) {
		EventUtil.removeHandler(info, "click", clickToSum);
	}
}
	

	

//initialize all the button click function
function buttonsSetting() {
	var buttons = document.getElementsByTagName("li");

	for (var i = 0; i < buttons.length; i++) {
		buttons[i].bubbles = true;
		EventUtil.addHandler(buttons[i], "click", buttonFunc(i, "custom"));
	}
}


//binding function with each button
function buttonFunc(num, mode) {
	return function() {
		if (this.className.indexOf("clicked") == -1) {
			var request = createRequest();
			var url = "/";

			if (request == null) {
    			alert("Unable to create request");
    			return;
  			}

  			var button = this;
  			request.onreadystatechange = function(button, num, mode) {
  				return function() {
  					if(request.readyState == 4) {
  						if ((request.status >= 200 && request.status < 300) || request.status == 304) {

  							custom(button, request.responseText);

  							if (mode === "oneByOne") {
  								oneByOne(num+1)();
  							}

  							if (num == 4 && mode === "together") {
  								clickToSum();
  							}

  							if (mode === "random") {
  								if (num === 4 && checkAllClicked()) {
  									clickToSum();
  									return;
  								} else {
  									randomOrder(num+1);
  								}
  							}
  						} else {
  							console.log("request failed");
  						}
  					}
  				};
  			}(button, num, mode);
  			//open the url
  			request.open("GET", url, true);
  			request.send(null);

  			//change the text in the red dot
			var redCircle = this.getElementsByTagName("span")[0];
			redCircle.style.display = "block";
			redCircle.innerHTML = redCircle.innerHTML.replace(/\d/, "...");

			if (mode != "together") {
				//disable other buttons' click function
				disableOtherButtons(this);
			}
			//pass the request to the atplusSetting function
			atplusSetting(request);
		}
	}
}

function custom(button, text) {
	showNumber(button, text);
  	button.className += " clicked";  //set the button to clicked class
  	EventUtil.removeHandler(button, "click", buttonFunc);  //remove the handle function from the button
  	enableButtons();   //enable other buttons
  	MotivateInfoBar();       // check and motivate the info bar					
}

//check whether all the five buttons have been clicked
function checkAllClicked() {
	var buttons = document.getElementsByTagName("li"),
		flag = 1;

	for (var i = 0; i < buttons.length; i++) {
		if (buttons[i].className.indexOf("clicked") == -1) {
			flag = 0;
		}
	}

	return flag;
}

//check and motivate the info Bar(the big big bubble) +_+
function MotivateInfoBar() {
	if (checkAllClicked()) {
		EventUtil.addHandler(document.getElementsByClassName("info")[0], "click", clickToSum);
	}
}

//enable the big button click function
function clickToSum() {
	var sum = 0;
	var nums = document.getElementsByClassName("number");
	var bigButton = document.getElementsByClassName("info")[0];

	for (var i = 0; i < nums.length; i++) {
		sum += parseInt(nums[i].innerHTML);
	}

	bigButton.getElementsByTagName("h2")[0].appendChild(document.createTextNode(sum));
}

//enable the unclicked buttons
function enableButtons() {
	var buttons = document.getElementsByTagName("li");

	for (var i = 0; i < buttons.length; i++) {
		if (buttons[i].className.indexOf("clicked") == -1) {
			EventUtil.addHandler(buttons[i], "click", buttonFunc);
			buttons[i].className = buttons[i].className.replace("disabled", "");
		}
	}
}

//disable all buttons
function disableOtherButtons(button) {
	var buttons = document.getElementsByTagName("li");

	for (var i = 0; i < buttons.length; i++) {
		if (buttons[i] != button) {
			if (buttons[i].className.indexOf("disabled") == -1) {
				EventUtil.removeHandler(buttons[i], "click", buttonFunc);
				if (buttons[i].className.indexOf("clicked") == -1) {
					buttons[i].className += " disabled";
				}
			}
		}
	}
}

//showNumber
function showNumber(button, num) {
	var number = button.getElementsByTagName("span")[0];
	number.innerHTML = number.innerHTML.replace("...", num);
}
