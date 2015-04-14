/*
 * jQuery Widget Placeholder 0.1
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Depends:
 *	ui.core.js
 */
(function($) {
 var __widgetName = 'placeholder';

 $.widget("ui."+__widgetName, {

_init: function() {

var self = this, options = self.options, element = self.element,baseClass=self.widgetBaseClass;
element.addClass("ui-"+__widgetName);
var value = element.attr('title') ||element.attr('value');
element.attr('title','');
element.bind('focus.placeholder', function(){

  if (this.value == value) {
  this.value = '';
  }
  element.addClass('ui-placeholder-off');
  }).bind('blur.placeholder', function(){
    if (this.value == '' || this.value == value) {
    this.value = value;
    element.removeClass('ui-placeholder-off');
    }
    }).parents("form:first").bind('submit', function(){
      if (element.val() == value) 
      element.val('');
      });
       }
 });
})(jQuery);

