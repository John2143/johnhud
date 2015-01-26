var tohide;
var index;
const MAXHIST = 5000;
var hideAll = function(){
	$("#siteTable > div.thing")
		.each(function(_ind){
			var $this = $(this);
			if ($.inArray($this.attr("data-fullname"), tohide) != -1){
				$this.hide();
			}
		});
};
var save = function(){
	localStorage.setItem("owred", JSON.stringify(tohide));
	localStorage.setItem("owredi", index);
}
var add = function(data){
	tohide[index++] = data;
	if (index > MAXHIST) index = 0;
}
$(".rank").click(function(){
	var par = $(this).parent();
	add(par.attr("data-fullname"));
	par.hide();
	save();
});


$(document).ready(function(){
	tohide = JSON.parse(localStorage.getItem("owred") || JSON.stringify([]));
	index = localStorage.getItem("owredi") || 0
	hideAll();
});

GETDATA = function(){return [index,tohide,hideAll];};
CLEAR = function(){
	index = 0;
	tohide = [];
	save();
};
