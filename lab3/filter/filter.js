window.onload = function() {
	var tables = getAllTables();
	makeAllTablesFilterable(tables);
}

function getAllTables() {
	return document.getElementsByTagName("table");
}

function makeAllTablesFilterable(tables) {
	for (var i = 0; i < tables.length; i++) {
		makeFilterable(makeSortable(tables[i]));
	}
}

function makeFilterable(table) {
	var rows = table.rows;

	var label = document.createElement("label");
	label.appendChild(document.createTextNode("Search: "));
	var input = document.createElement("input");
	table.parentNode.insertBefore(label, table)
	table.parentNode.insertBefore(input, table);

	input.onchange = function() {
		var text = input.value;

		for (var i = 1; i < rows.length; i++) {
			var flag = 0;
			for (var j = 0; j < rows[i].cells.length; j++) {
				rows[i].cells[j].innerHTML = rows[i].cells[j].innerHTML.replace(/<strong>|<\/strong>/, ""); //clear the strong set before
				if (rows[i].cells[j].innerHTML.indexOf(text) != -1) {
					//set flag if innerHTML contains the text
					flag = 1;
					// set the text in the table as strong
					rows[i].cells[j].innerHTML = rows[i].cells[j].innerHTML.replace(text, "<strong>"+text+"</strong>");
					rows[i].style.display = "table-row";
				}
			}

			if (!flag) {
				rows[i].style.display = "none";
			}
		}
	}

	return table;
}

function makeSortable(table) {
	var ths = table.getElementsByTagName("th");

	for (var i = 0; i < ths.length; i++) {
		ths[i].onclick = sortByThead(i, table);
	}

	return table;
}

function sortByThead(i, table) {
	return function() {
		var tbody = table.getElementsByTagName("tbody")[0];
		var ths = table.getElementsByTagName("th");
		var trs = table.getElementsByTagName("tr");  //mark
		var sequenceMode = "";
		var trsArray = new Array();

		//do with the style
		for (var j = 0; j < ths.length; j++) {
			var thClassName = ths[j].className;

			if (j == i) {
				if (thClassName.indexOf("chosen") == -1) {
					thClassName = "chosen ascend";
					sequenceMode = "ascend";
				} else if (thClassName.indexOf("ascend") != -1) {
					thClassName = thClassName.replace("ascend", "descend");
					sequenceMode = "descend";
				} else if (thClassName.indexOf("descend") != -1) {
					thClassName = thClassName.replace("descend", "ascend");
					sequenceMode = "ascend";
				}
			}
			else thClassName = "";

			ths[j].className = thClassName;
		}

		// create a Array same as the trs
		for (var j = 1; j < trs.length; j++) {
			trsArray.push(trs[j]);
		}

		//sort the Array  
		trsArray.sort(compareTd(i, sequenceMode, trsArray));

		// remove all the trs in the table body
		while (trs[1]) {
			tbody.removeChild(trs[1]);
		}

		//insert content in the sorted Array into the table		
		for (var j = 0; j < trsArray.length; j++) {
			var tr = document.createElement("tr");
			tr = trsArray[j];
			tbody.appendChild(tr);
		}
	};
}

function compareTd(i, sequenceMode, test) {
	return function(a, b) {
		a_text = a.getElementsByTagName("td")[i].innerHTML;
		b_text = b.getElementsByTagName("td")[i].innerHTML;

		if (a_text > b_text) return sequenceMode=="ascend"?1:-1;
		else if (a_text < b_text) return sequenceMode=="ascend"?-1:1;
		else return 0;
	}
}