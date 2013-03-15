jQuery(document).ready(function() {
	jQuery.ajax({
		'url': '/status.json',
		success: function(data, textStatus, XHR) {
			if(data.open) {
				jQuery('#api_status').text('abierto').parent('span').addClass('btn-success icon-ok').removeClass('btn-danger icon-lock icon-question-sign');
			} else {
				jQuery('#api_status').text('cerrado').parent('span').addClass('btn-danger icon-lock').removeClass('btn-success icon-ok icon-question-sign');
			}
		}
	});
});





