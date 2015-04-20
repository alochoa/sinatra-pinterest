$(function() {
	$("#btn").on('click', function() {
		$.getJSON('/user/random', function(data) {
			var content = $("#content");
			$("<p>").text(data.username).appendTo(content);
			$("<p>").text("Their password is :").append(data.password).appendTo(content);
		});
	});
});
