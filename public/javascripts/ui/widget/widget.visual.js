/*widget.visual.js*/
/*
 * jQuery Widget Visual @VERSION
 *
 * Copyright (c) 2009 zzdhidden@gmail.com
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 *
 * Depends:
 *	ui.core.js
 *	http://www.google.com/jsapi
 *	<script>google.load("visualization", "1", {packages:["linechart","barchart","areachart","piechart"]});</script>
 * Description:
 * http://code.google.com/apis/visualization/
 *
 */
(function($) {
    var __widgetName = 'visual';
    $.widget("ui."+__widgetName, $.extend({},{
        _init:function(){
            var self = this, options = self.options;
            var type = self.type = options.type;//get visualization type lineChart,pieChart,//DataTable
            options.type = null;
            if($.inArray(type,['Table','LineChart','ColumnChart','BarChart','AreaChart','PieChart'])==-1){
                self.destroy();
                return;//not support type
            };
            var defaults = $.ui[__widgetName][type+'_defaults'];
            if(!defaults)defaults = $.ui[__widgetName]['_defaults'];
            options = self.options = $.extend(defaults,options);

            if(!(window.google&&window.google.visualization&&window.google.visualization[type])){
                //not support
                self.destroy();
                return;
            }
            self.__init();
        },
        __init:function(){
            var self = this, options = self.options, element = self.element,baseClass=self.widgetBaseClass;
            var type = self.type;
            element.addClass(baseClass);
            //self.__data = options.data;//get visualization data {}
            options.data&&self.updateData(options.data)&&self.draw();

            options.data = null;
        },
        updateData:function(data){
            var self = this;
            if(!data||data == self.__data)return false;
            var column = data.column;
            data = data.data;
            var colLength = column.length,rowLength = data.length;
            if(!colLength||!rowLength)return;
            self.__data = data;
            var _data = self.data = new google.visualization.DataTable();
            $.each(column,function(n,v){
                _data.addColumn(typeof data[0][n],v);
            });
            _data.addRows(rowLength);
            for(var i=0;i<rowLength;i++){
                for(var j=0;j<colLength;j++){
                    _data.setValue(i,j,data[i][j]);
                }
            }
            return true;


        },
        getSelection:function(){
            var visual = this.visual;
            return visual.getSelection.apply(visual,arguments);// [Object row=2 column=1]
        },
        setSelection:function(){// [Object row=2 column=1]
            var visual = this.visual;
            visual.setSelection.apply(visual,arguments);
        },
        _initVisual:function(){
            var self = this;
            var visual = self.visual = new google.visualization[self.type](self.element.empty().get(0));
            //event
            var listen = google.visualization.events.addListener;
            listen(visual, 'select',
                function(event) {
                    var select = self.getSelection();
                    self._trigger('select',null,select);
                });

        },

        draw:function(data,options){
            var self = this,element = self.element;
            self._initVisual();//re draw

            data&&self.updateData(data);
            data = self.data;
            options&&self.option(options);
            options = self.options;
            self.element.css({
                width:options.width,
                height:options.height
            });
            self.visual.draw(data,options);

        },
        destroy: function() {
            this.element.removeData(this.widgetName)
            .removeClass(this.widgetBaseClass);
        }
    }));

    $.extend($.ui[__widgetName], {
        version: "@VERSION",
        _defaults: {
            data:null,// { 'Year':['2004','2005','2006','2007'],'Sales':[1000,1170,860,1030],'Expenses':[400,460,580,540]};
            width: '95%',
            height: 210,
            is3D:true,
            legend: 'bottom',
            title: 'visualization'
        },
        Table_defaults:{
            width:'100%'
        },
        PieChart_defaults:{
            width: '95%',
            height: 250,
            is3D:true,
            legend: 'right',
            title: 'visualization'
        },
        BarChart_defaults:{
            width: '95%',
            height: 250,
            is3D:true,
            legend: 'right',
            title: 'visualization'
        },
        getter: 'getSelection',

        getterSetter: ''
    });

})(jQuery);

