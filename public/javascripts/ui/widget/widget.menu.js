/*
 * jQuery Widget Menu 0.1
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Depends:
 *	ui.core.js
 */
(function($) {
    var __widgetName = 'menu';

$.widget("ui."+__widgetName, {

	_init: function() {

            var self = this, options = self.options, element = self.element,baseClass=self.widgetBaseClass;
		element.addClass("ui-"+__widgetName+" ui-widget ui-helper-reset");
                var $li = this.$li = element.children('li:not(.ui-'+__widgetName+'-separator)');
		element.children('li.ui-'+__widgetName+'-separator').children('hr').addClass('ui-state-light');
		var headers = this.headers = $li.children('h3').addClass("ui-"+__widgetName+"-header ui-helper-reset")
			.bind("mouseenter."+__widgetName, function(){ $(this).addClass('ui-state-hover'); })
			.bind("mouseleave."+__widgetName, function(){ $(this).removeClass('ui-state-hover'); })
			.bind("focus."+__widgetName, function(){ $(this).addClass('ui-state-focus'); })
			.bind("blur."+__widgetName, function(){ $(this).removeClass('ui-state-focus'); });

		headers
			.next()
				.addClass("ui-"+__widgetName+"-content ui-helper-reset ui-widget-content ui-corner-bottom");

		//this.active.next().addClass('ui-accordion-content-active');


		// IE7-/Win - Extra vertical space in lists fixed
		if ($.browser.msie) {
			element.find('a').css('zoom', '1');
		}


		//ARIA
		element.attr('role','menubar');
                $li.attr('role','menuitem');

		headers
			.bind("keydown."+__widgetName, function(event) { event.header = this;return self._keydown(event); });
                        //.attr('role','menubar');

		if (options.event) {
		//Append icon elements
                headers.each(function(){
                      var header = $(this);
                      header.find('a').focus(function(){header.focus()}).blur(function(){header.blur()});
                      if(header.next().size()){
                        if(!header.find('.ui-icon').size())
		$("<em/>").addClass("ui-icon ui-icon-carat-1-s").prependTo(header);
			header.find('a').andSelf().bind((options.event) + "."+__widgetName, function(event) { return self._clickHandler.call(self, event, header); });
                      header.find('a').click(function(){return false;});
                      
                      }
                      
                      });
		}

		$li.each(function(){
                   self._setlist($(this));
                   });

	},
       destroy: function() {
		var o = this.options;

		this.element
			.removeClass("ui-"+__widgetName+" ui-widget ui-helper-reset")
			.removeAttr("role")
			.unbind("."+__widgetName)
			.removeData(__widgetName);

		this.headers
			.unbind("."+__widgetName)
			.removeClass("ui-"+__widgetName+"-header ui-helper-reset ui-state-default ui-corner-all ui-widget-header ui-corner-top")
			.removeAttr("role").removeAttr("aria-expanded");

	},
	_toggle:function(list){
                  if(list.hasClass("ui-"+__widgetName+"-open")){
                     this._close(list);
                  }else
                     this._open(list);
       },
      _setlist:function(list){
                  if(list.hasClass("ui-"+__widgetName+"-open")){
                     this._open(list);
                  }else
                     this._close(list);
       },
        _close:function(list){
             var header = list.children('h3');
             list.removeClass("ui-"+__widgetName+"-open");
             header.addClass("ui-state-default").removeClass("ui-widget-header").addClass("ui-corner-all").removeClass("ui-corner-top").find('.ui-icon').removeClass("ui-icon-carat-1-n").addClass("ui-icon-carat-1-s").attr('aria-expanded','false');
               },

        _open:function(list){
               
             var header = list.children('h3');
             list.addClass("ui-"+__widgetName+"-open");
             header.removeClass("ui-state-default").addClass("ui-widget-header").removeClass("ui-corner-all").addClass("ui-corner-top").find('.ui-icon').removeClass("ui-icon-carat-1-s").addClass("ui-icon-carat-1-n").attr('aria-expanded','true');

               },
	
	_setData: function(key, value) {
		if(key == 'alwaysOpen') { key = 'collapsible'; value = !value; }
		$.widget.prototype._setData.apply(this, arguments);	
	},

	_keydown: function(event) {

		var self = this,headers = self.headers,options = self.options, keyCode = $.ui.keyCode;

		if (options.disabled || event.altKey || event.ctrlKey)
			return;

		var length = headers.length;
		var currentIndex = headers.index(event.header);
		var toFocus = false;

		switch(event.keyCode) {
			case keyCode.RIGHT:
			case keyCode.DOWN:
				toFocus = headers[(currentIndex + 1) % length];
				break;
			case keyCode.LEFT:
			case keyCode.UP:
				toFocus = headers[(currentIndex - 1 + length) % length];
				break;
			case keyCode.SPACE:
			case keyCode.ENTER:
				return self._clickHandler({ target: event.target }, event.header);
		}

		if (toFocus) {
                        $(event.header).find('a').blur();
			$(toFocus).find('a').focus();
			return false;
		}

		return true;

	},
	_clickHandler: function(event, target) {

		var o = this.options;
		if (o.disabled) return false;
                this._toggle($(target).parent());
		return false;

	}


});


$.extend($.ui[__widgetName], {
	version: "@VERSION",
	defaults: {
		active: null,
		fx: 'slide',
		event: "click"
	}
});

})(jQuery);
