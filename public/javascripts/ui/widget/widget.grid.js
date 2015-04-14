/*
 * jQuery Widget Grid @VERSION
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Depends:
 *	ui.core.js
 */
(function($) {
    var __widgetName = "grid";

    $.widget("ui."+__widgetName, {
        _init: function() {
            var self = this, options = self.options, element = self.element,baseClass=self.widgetBaseClass;
            element.addClass("ui-"+__widgetName+" ui-widget ui-widget-content ui-corner-all ui-helper-reset");
            var scrollable = self._scrollable = element.hasClass('ui-grid-scrollable');

            var headers = self.headers = element.find('thead tr,tfoot tr').addClass('ui-widget-header');
            var headerCheckbox = headers.find('input:checkbox');
            var rows = self.rows = element.find('tbody tr').click(function(e){                
                var el = e.target;
                while(el.parentNode){
                    if(el.nodeName == "A")return;
                    el = el.parentNode;
                }
                el = $(this);
                var checkbox = el.find('input:checkbox');
                if(checkbox.length){
                    var box = checkbox[0];
                    if(e.target != box)
                        box.checked = !box.checked;
                    if(!box.checked){
                        headerCheckbox.each(function(){ //消除header中的全选
                            this.checked = false
                        });
                    }
                    $(this).toggleClass('ui-state-highlight',box.checked);
                }else{
                    if(!options.singleSelection){
                        $(this).toggleClass('ui-state-highlight');
                    }else{
                        var selectedRow = rows.filter(".ui-state-highlight").get(0);
                        if(selectedRow == this)
                            return;
                        if(selectedRow){
                            self._trigger("row", e, [selectedRow, false]);
                            $(selectedRow).removeClass('ui-state-highlight');
                        }
                        $(this).toggleClass('ui-state-highlight');
                        self._trigger("row", e, [this, true]);
                    }
                }
                return;
            });
            rows.filter(":odd").addClass('ui-state-light ui-grid-odd');
            rows.filter(":even").addClass("ui-grid-even");
            rows.filter(":last").addClass("ui-grid-last");
            rows.filter(":first").addClass("ui-grid-first");
            //ARIA
            element.attr('role','grid');
            //bind checkbox selected
            headerCheckbox.click(function(e){
                var c = this.checked;
                rows.find('input:checkbox').each(function(){
                    this.checked = c;
                    $(this).parents('tr:first').toggleClass('ui-state-highlight',c);
                });
                headerCheckbox.each(function(){
                    this.checked = c;
                });
            });
            //sort render ui-grid-sort-desc ui-grid-sort-asc
            if(scrollable){
                var scrollHead = element.find('.ui-grid-scroll-head'),sh = scrollHead.find("th");
                var scrollBody = element.find('.ui-grid-scroll-body'),sb =  scrollBody.find("tr:first td");
                scrollBody.bind('scroll',function(){
                    scrollHead.scrollLeft(scrollBody.scrollLeft());
                });
                if ($.browser.msie) {
                    //IE 无法通过css去掉table cellSpacing
                    scrollHead.children('table').add(scrollBody.children('table')).attr('cellSpacing','0px');
                }
            }else{
                if ($.browser.msie) {
                    element.attr('cellSpacing','0px');
                }
            }
        },
        scrollable:function(){
            return this._scrollable;
        },
        setSingleSelection : function(single){
            this.options.singleSelection = single;
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
            .removeClass("ui-"+__widgetName+"-header ui-helper-reset ui-state-default ui-corner-all ui-state-active ui-corner-top")
            .removeAttr("role").removeAttr("aria-expanded");

        }

    });


    $.extend($.ui[__widgetName], {
        version: "@VERSION",
        defaults: {
            singleSelection : false
        }
    });

})(jQuery);
