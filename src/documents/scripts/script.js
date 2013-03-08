jQuery(document).ready(function() {
	jQuery.ajax({
		'url': '/status.json',
		success: function(data, textStatus, XHR) {
		if(data.open) {
			jQuery('#api_status').text('abierto').addClass('space_open').removeClass('space_closed');
		} else {
			jQuery('#api_status').text('cerrado').addClass('space_closed').removeClass('space_open');
		}
	}
	});
	
});





