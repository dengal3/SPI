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
	EventUtil.addHandler(icon, "click", oneByOne(0));
}

function oneByOne(button_id) {
	return function() {
		var button = document.getElementsByClassName("button")[button_id];
		if (button_id <= 4) {
			buttonFunc.call(button, button_id);
		} else {
			return;
		}
	}
}

//setting the at plus onmouseover function
function atplusSetting(request) {
	var container = document.getElementById("at-plus-container");
	if (!container.onmouseleave) {
		EventUtil.addHandler(container, "mouseleave", reset(request));
	}
}

function reset(request) {
	return function () {
		if (request != undefined) {
			request.abort();
		}

		buttonsReset();
		infoReset();
		initPage();
	};
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

	if (sumNode.length) {
		sumNode[0].innerHTML = sumNode[0].innerHTML.replace(/\d/, "");
	}

	EventUtil.removeHandler(document.getElementsByClassName("info")[0], "click", clickToSum);
}
	

	

//initialize all the button click function
function buttonsSetting() {
	var buttons = document.getElementsByTagName("li");

	for (var i = 0; i < buttons.length; i++) {
		buttons[i].bubbles = true;
		EventUtil.addHandler(buttons[i], "click", buttonFunc(i));
	}
}


//binding function with each button
function buttonFunc(num) {
	
		if (this.bubbles == true) {
			var request = createRequest();
			var url = "/";

			if (request == null) {
    			alert("Unable to create request");
    			return;
  			}

  			var button = this;
  			var e = event;
  			request.onreadystatechange = function(button, e, num) {
  				return function(event) {
  					if(request.readyState == 4) {
  						if ((request.status >= 200 && request.status < 300) || request.status == 304) {
  							showNumber(button, request.responseText);
  							button.className += " clicked";  //set the button to clicked class
  							EventUtil.removeHandler(button, "click", buttonFunc);  //remove the handle function from the button
  							enableButtons(button);   //enable other buttons
  							MotivateInfoBar();       // check and motivate the info bar

  							oneByOne(num+1)();
  						} else {
  							console.log("request failed");
  						}
  					}
  				};
  			}(button, e, num);
  			//open the url
  			request.open("GET", url, true);
  			request.send(null);

  			//change the text in the red dot
			var redCircle = this.getElementsByTagName("span")[0];
			redCircle.style.display = "block";
			redCircle.innerHTML = redCircle.innerHTML.replace(/\d/, "...");

			//disable other buttons' click function
			disableOtherButtons(this);
			//pass the request to the atplusSetting function
			atplusSetting(request);
		}

			
}

//check and motivate the info Bar(the big big bubble) +_+
function MotivateInfoBar() {
	var buttons = document.getElementsByTagName("li"),
		flag = 1;

	for (var i = 0; i < buttons.length; i++) {
		if (buttons[i].className.indexOf("clicked") == -1) {
			flag = 0;
		}
	}

	if (flag) {
		EventUtil.addHandler(document.getElementsByClassName("info")[0], "click", clickToSum);
	}
}

//enable the big button click function
function clickToSum() {
	var sum = 0;
	var nums = document.getElementsByClassName("number");

	for (var i = 0; i < nums.length; i++) {
		sum += parseInt(nums[i].innerHTML);
	}

	this.getElementsByTagName("h2")[0].appendChild(document.createTextNode(sum));
}

//enable the unclicked buttons
function enableButtons(button) {
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
