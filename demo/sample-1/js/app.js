var App =
{
	init: function()
	{
		$().jDeamon({
			url     : '/demo/_webservices/push.php',
			callback: App.callback,
			timeout : 2,
		});
		
		//Clear button.
		$('#btn-clear').click(function() {
			$('#notification-area').empty();
		});
	},
	
	callback: function()
	{
		$.post('/demo/_webservices/notifications.php', '', function(response) {
			$('#notification-area').append('<option>'+ response +'</option>');
		});
	}
}

$(document).ready(function() {
	App.init();
});