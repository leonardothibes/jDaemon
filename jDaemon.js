/******************************************
 * Copyright (c) Leonardo Thibes 2012-2013
 *
 * http://leonardothibes.com
 *
 * @author leonardothibes
 * @copyright Copyright (c) 2013 Leonardo Thibes <eu@leonardothibes.com>.
 * @license This jDaemon jQuery plug-in is licensed under MIT license.
 * @link http://documentup.com/leonardothibes/jDaemon
 * @github http://github.com/leonardothibes/jDaemon
 * @version Version 1.0.0
 *
 ******************************************/
(function( $ ) {
	$.fn.jDeamon = function(options) {
		
		var defaults = {
			timeout : '5',
			url     : '',
			callback: function() {},
		};
		var settings = $.extend( {}, defaults, options );
		var serial   = '';
		
		/**
		 * Init the plugin.
		 */
		this.init = function()
		{
			if (serial == '') {
				serial = this.getRemoteSerial();
			}
			
			$.ajax({
				type   : 'post',
				url    : settings.url,
				success: function(remoteSerial) {
					if(remoteSerial > serial) {
						serial = remoteSerial;
						settings.callback();
					}
				}
			});
			
			plugin = this;
			setTimeout('plugin.init()', this.getTimeOut());
		}
		
		/**
		 * Get the remote serial on the server side.
		 */
		this.getRemoteSerial = function()
		{
			$.ajax({
				type    : 'POST',
				url     : settings.url,
				async   : false,
				success : function(serial) {
					res = serial;
				}
			});
			return res;
		}
		
		/**
		 * Get the timeout in milliseconds.
		 */
		this.getTimeOut = function()
		{
			return parseInt(settings.timeout) * 1000;
		}
		
		//Starting de plugin execution.
		this.init();
	};
})( jQuery );