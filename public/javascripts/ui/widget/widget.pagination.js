/*
 * jQuery Widget Pagination 0.1
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Depends:
 *	ui.core.js
 */
(function($) {
    var __widgetName = "pagination";

$.widget("ui."+__widgetName, {

	_init: function() {

            var self = this, options = self.options, element = self.element,baseClass=self.widgetBaseClass;
		element.addClass("ui-"+__widgetName+" ui-widget ui-helper-reset");
		
		var list = this.list = element.children(':not(.gap)').addClass('ui-state-default ui-corner-all');
                list.filter('.disabled').hide();
                list.filter('.current,.selected').addClass('ui-state-active');
                list.not('.current,.selected').hover(function(){$(this).addClass('ui-state-hover')},function(){$(this).removeClass('ui-state-hover')});
			},
       destroy: function() {
		var o = this.options;

		this.element
			.removeClass("ui-"+__widgetName+" ui-widget ui-helper-reset");
		}

});


$.extend($.ui[__widgetName], {
	version: "@VERSION",
	defaults: {
	}
});

})(jQuery);
