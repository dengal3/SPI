function Base(name) {
	this.instanceVariable = name;
}


Base.prototype.instanceMethod = function() {
	console.log("This is from Base class instance-method, static-variable is: "+this.instanceVariable);
};

Base.staticVariable = "Base";
Base.staticMethod = function() {
	console.log("This is from Base class static-method, static-variable is: " + this.staticVariable);
}

function Derived(name) {
	this.instanceVariable = name;
}


Derived.prototype.instanceMethod = function() {
	console.log("This is from Derived class instance-method, instance-variable is: " + this.instanceVariable);
}

Derived.staticVariable = "Derived";
Derived.staticMethod = function() {
	console.log("This is from Derived class static-method, static-variable is: " + this.staticVariable);
}

function extend(base, derived) {

	for (var base_attr in base) {
	for (var derived_attr in derived) {
		
		if (typeof derived[derived_attr] === "function" && typeof base[base_attr] === "function") {
			var temp = derived[derived_attr];
			derived[derived_attr] = function(base, base_attr, temp) {
				return function() {
					base[base_attr].call(this);
					temp.call(this);
					return;
				};
			}(base, base_attr, temp);
		}
	}
	}

	for (var base_attr in base.prototype) {
	for (var derived_attr in derived.prototype) {
		//console.log(base_attr);
		if (typeof derived.prototype[derived_attr] === "function" && typeof base.prototype[base_attr] === "function") {
			var temp = derived.prototype[derived_attr];
			(derived.prototype)[derived_attr] = function(base, base_attr, temp) {
				return function() {
					base[base_attr].call(this);
					temp.call(this);
					return;
				};
			}(base.prototype, base_attr, temp);
		}
	}
	}
};

extend(Base, Derived);

// test 1
console.log("------------------test1-------------------------");
var example = new Derived("example");
Derived.staticMethod();
example.instanceMethod();

//test2
console.log("--------------------test2----------------------------");
example = new Derived('example');
otherExample = new Derived('other-example');
Derived.staticMethod();
example.instanceMethod();
otherExample.instanceMethod();

