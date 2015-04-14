/*
 * jQuery Widget Switchpanel @VERSION
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Depends:
 *	ui.core.js
 */
(function($) {
    var __widgetName = "switchpanel";

$.widget("ui.switchpanel", {

	_init: function() {
            var self = this, o = self.options, element = self.element,baseClass=self.widgetBaseClass;
		element.addClass("ui-"+__widgetName+" ui-widget");
this.list = this.element.children('ul:first');
		this.lis = $('li:has(a[href])', this.list);
		this.anchors = this.lis.map(function() { return $('a', this)[0]; });
		this.panels = $([]);
		this.icons = $([]);


		var fragmentId = /^#.+/; // Safari 2 reports '#' for an empty hash
		this.anchors.each(function(i, a) {
			var href = $(a).attr('href');

			// For dynamically created HTML that contains a hash as href IE < 8 expands
			// such href to the full page url with hash and then misinterprets tab as ajax.
			// Same consideration applies for an added tab with a fragment identifier
			// since a[href=#fragment-identifier] does unexpectedly not match.
			// Thus normalize href attribute...
			var hrefBase = href.split('#')[0], baseEl;
			if (hrefBase && (hrefBase === location.toString().split('#')[0] ||
					(baseEl = $('base')[0]) && hrefBase === baseEl.href)) {
				href = a.hash;
				a.href = href;
			}

			// inline tab
			if (fragmentId.test(href)) {
				self.panels = self.panels.add(self._sanitizeSelector(href));
			}

			// remote tab
			else if (href != '#') { // prevent loading the page itself if href is just "#"
				$.data(a, 'href.switchpanel', href); // required for restore on destroy

				// TODO until #3808 is fixed strip fragment identifier from url
				// (IE fails to load from such url)
				$.data(a, 'load.switchpanel', href.replace(/#.*$/, '')); // mutable data

				var id = self._tabId(a);
				a.href = '#' + id;
				var $panel = $('#' + id);
				if (!$panel.length) {
					$panel = $(o.panelTemplate).attr('id', id).addClass('ui-switchpanel-panel ui-widget-content ui-corner-bl')
						.insertAfter(self.panels[i - 1] || self.list);
					$panel.data('destroy.switchpanel', true);
				}
				self.panels = self.panels.add($panel);
                        }

			// invalid tab href
			else {
				o.disabled.push(i);
			}
                        var el = $(a);
                                var $icon = el.find('.ui-icon');
                                 if(!$icon.length)
                                    $icon = $('<em class="ui-icon ui-icon-carat-1-s"></em>').appendTo(el);
				self.icons = self.icons.add($icon);
			
		});

			// attach necessary classes for styling
			this.list.addClass('ui-switchpanel-nav ui-helper-reset ui-helper-clearfix');
			this.lis.addClass('ui-state-default ui-corner-bottom');
			this.panels.addClass('ui-switchpanel-panel ui-switchpanel-hide ui-widget-content ui-corner-bl');

			var addState = function(state, el) {
					el.addClass('ui-state-' + state);
			};
		if (o.event != 'mouseover') {
			var removeState = function(state, el) {
				el.removeClass('ui-state-' + state);
			};
			this.lis.bind('mouseover.switchpanel', function() {
				addState('hover', $(this));
			});
			this.lis.bind('mouseout.switchpanel', function() {
				removeState('hover', $(this));
			});
			this.anchors.bind('focus.switchpanel', function() {
				addState('focus', $(this).closest('li'));
			});
			this.anchors.bind('blur.switchpanel', function() {
				removeState('focus', $(this).closest('li'));
			});
		}
			this.anchors.bind('click.switchpanel', function() {
                              return false;
                        });
			this.lis.bind('mousedown.switchpanel', function() {
var elm=this,el = $(elm),index = self.lis.index(this),icon = self.icons.eq(index),rel = self.panels.eq(index);
        if(el.hasClass('ui-switchpanel-selected')){
          rel.slideUp('fast',function(){
//rel.removeClass('ui-corner-bottom').addClass('ui-corner-br');
            self.lis.not(elm).css('visibility','visible');
            icon.removeClass('ui-icon-carat-1-n').addClass('ui-icon-carat-1-s');
          });
          el.removeClass('ui-switchpanel-selected ui-state-active');

          }else{
          rel.slideDown('fast',function(){
            icon.removeClass('ui-icon-carat-1-s').addClass('ui-icon-carat-1-n');

          });
          el.addClass('ui-switchpanel-selected ui-state-active');
          self.lis.not(elm).css('visibility','hidden');

        }

        return false;
        });

	},
         url: function(index, url) {
		this.anchors.eq(index).removeData('cache.switchpanel').data('load.switchpanel', url);
	},
_sanitizeSelector: function(hash) {
		return hash.replace(/:/g, '\\:'); // we need this because an id may contain a ":"
	},


	length: function() {
		return this.anchors.length;
	}

});

$.extend($.ui.switchpanel, {
	version: '@VERSION',
	getter: 'length',
	defaults: {
		}
});
})(jQuery);
