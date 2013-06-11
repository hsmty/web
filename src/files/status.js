$(function() {

changeStatus();
setInterval(changeStatus, 300000);

function changeStatus() {
	$.get('/status.json', function(space) {
		var status = $('<div/>');
		var img = $('<img>');
		img.attr('style', 'float: right; height: 70px; margin-right: 54px;');
		img.attr('id', 'status-icon');
		if (space.open) {
			img.attr('src', space.icon.open);
		} else {
			img.attr('src', space.icon.closed);
		}

		status.html(img);
		if ($('#status-icon').attr('src')) {
			$('#status-icon').replaceWith(img);
		} else {
			$('.page-header').prepend(status);
		}
	});
}
});
