;(function($) {

$.fn.extend({
  select_autocomplete: function(options) {
    options = $.extend({}, $.Selectcompleter.defaults, options);

    return this.each(function() {
      new $.Selectcompleter(this, options);
    });
  },
  result: function(handler) {
    return this.bind("result", handler);
  }
});

$.Selectcompleter = function(select, options) {
  var $select = $(select);
  if (select.tagName.toLowerCase() != 'select') { return; }

  //stick each of it's options in to an items array of objects with name and value attributes
  var items = [];
  $(select).children('option').each(function(){
    var item = $(this);
    if (item.val() != '') //ignore empty value options
    {
      var name = item.html();
      var value = item.val();
      items.push( {'name':name, 'value':value} );
    }
  });


  //make a new input box next to the select list
  var $input = $("<input type='text' name='" + $select.attr("name") +"' />");
  $select.after($input);

  //make the input box into an autocomplete for the select items
  var default_options = {
    minChars: 1,
    width: 210,
    matchContains: true,
    autoFill: false,
    formatItem: function(row, i, max) {
      return row.name;
    },
    formatMatch: function(row, i, max) {
      return row.name;
    },
    formatResult: function(row) {
      return row.name;
    }
  }

  $input.autocomplete(options['url'] || items,
                        $.extend(default_options, options)
                       );

  //make the result handler set the selected item in the select list
  $input.result(function(event, selected_item, formatted) {
    if (selected_item) {
      if ($select.trigger("result", [selected_item, formatted])) {
        var to_be_selected = $select.find("option[value=" + selected_item.id + "]")[0];
        if (to_be_selected == null) {
          $select.find(":selected").removeAttr("selected");
          $select.append("<option value='"+ selected_item.id + "' selected='selected'>" + selected_item.name + "</option>");
        } else
          $(to_be_selected).attr('selected', 'selected');
      }
    } else
      $select.find(":selected").removeAttr("selected");
  });

  //set the initial text value of the autocomplete input box to the text node of the selected item in the select control
  if (options.useSelected)
    $input.val($select.find(':selected').text());

  //normally, you'd hide the select list but we won't for this demo
  $select.hide();

  return $input;
};


$.Selectcompleter.defaults = {
  url: null,
  useSelected: false
};

})(jQuery);