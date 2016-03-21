
$(document).on('mouseover','li[data-contactable-id]', function(e){
  //console.log([e,e.targeot,e.currentTarget]);
  $('#contactable_' + $(e.currentTarget).attr('data-contactable-id')).addClass('highlight');
  $(e.currentTarget).find('a[data-customer-id], li[data-customer-id]').each(function(i,el){
          $('#doc_aliased_customers li a[data-customer-id=' + $(el).attr('data-customer-id') + '].lightbulb').closest('li').addClass('highlight');
  });
});

$(document).on('mouseout','li[data-contactable-id]', function(e){
  $('#contactable_' + $(e.currentTarget).attr('data-contactable-id')).removeClass('highlight');
  $(e.currentTarget).find('a[data-customer-id], li[data-customer-id]').each(function(i,el){
          $('#doc_aliased_customers li a[data-customer-id=' + $(el).attr('data-customer-id') + '].lightbulb').closest('li').removeClass('highlight');
  });
});

$(document).on('mouseover','div.contactable', function(e){
  //console.log([e,e.targeot,e.currentTarget]);
  var id = /_(\d+)/.exec($(e.currentTarget).attr('id'))[1];
  $('li[data-contactable-id=' + id + ']').addClass('highlight');
});

$(document).on('mouseout','div.contactable', function(e){
  //console.log([e,e.targeot,e.currentTarget]);
  var id = /_(\d+)/.exec($(e.currentTarget).attr('id'))[1];
  $('li[data-contactable-id=' + id + ']').removeClass('highlight');
});

ELPH['add_to_data_att'] = function(el,name,amount){
  var count = parseInt($(el).attr(name));
  count = isNaN(count) ? 0 : count;
  $(el).attr(name, count + amount);
};

$(document).on('click', '#customers_preview a.lightbulb, #customers_preview a.lightbulb_16', function(e){
  var model = $(e.currentTarget).attr('data-contactable-id') ? 'contactable' : 'customer';
  var id =  $(e.currentTarget).attr('data-' + model + '-id');
  //var id_str = $('ul#documents_list').attr('data-selected-contactables');
  //var selected = id_str == '' ? [] : id_str.split(' ');
  if ($(e.currentTarget).hasClass('on')){
    ELPH.add_to_data_att('ul#documents_list','data-lightbulb-filters-count',-1);
    //selected = selected.filter(function(el){return el != id;});
    if (model == 'contactable'){
      $('li[data-contactable-id=' + id + ']').each(function(i,el){
        el = $(el);
        ELPH.add_to_data_att(el, 'data-shown-by-lightbulbs-count', -1);
        if (el.attr('data-shown-by-lightbulbs-count') == '0'){ el.hide(); };
      });
    } else {
      $('li[data-customer-id=' + id + '],a[data-customer-id=' + id + ']').each(function(i,el){
        el = $($(el).closest('li[data-contactable-id]'));
        ELPH.add_to_data_att(el, 'data-shown-by-lightbulbs-count', -1);
        if (el.attr('data-shown-by-lightbulbs-count') == '0'){ el.hide(); };
      });
    }
  } else {
    ELPH.add_to_data_att('ul#documents_list','data-lightbulb-filters-count',1);
    $('li[data-shown-by-lightbulbs-count=0]').hide();
    if (model == 'contactable'){
      $('li[data-contactable-id=' + id + ']').show();
      $('li[data-contactable-id=' + id + ']').each(function(i,el){
        //el = $(el);
        ELPH.add_to_data_att(el, 'data-shown-by-lightbulbs-count', 1);
      });
    } else {
      $('li[data-customer-id=' + id + '],a[data-customer-id=' + id + ']').each(function(i,el){
        el = $(el).closest('li[data-contactable-id]');
        el.show();
        ELPH.add_to_data_att(el, 'data-shown-by-lightbulbs-count', 1);
      });
    }
   // selected.push(id);
  }
  if ($('ul#documents_list').attr('data-lightbulb-filters-count')== 0){ 
    $('li[data-shown-by-lightbulbs-count=0]').show();
    $('a#lightbulbs_off').hide();
  } else { $('a#lightbulbs_off').show(); };
  //$('ul#documents_list').attr('data-selected-contactables', selected.join(' '));
  $(e.currentTarget).toggleClass('on');
});

$(document).on('click','a#lightbulbs_off', function(e){
  
  $('ul#documents_list').attr('data-lightbulb-filters-count','0');
  $('ul#documents_list > li').attr('data-shown-by-lightbulbs-count', 0).show();
  $('#customers_preview  a.lightbulb, #customers_preview  a.lightbulb_16').removeClass('on');
  $('a#lightbulbs_off').hide();
});


$(document).on('mouseover','ul#doc_aliased_customers a', function(e){
        //console.log([e,e.target,e.currentTarget]);
  $('ul#documents_list *[data-customer-id=' + $(e.currentTarget).attr('data-customer-id') + ']').parents('li').addClass('highlight');
});

$(document).on('mouseout','ul#doc_aliased_customers a', function(e){
  $('ul#documents_list *[data-customer-id=' + $(e.currentTarget).attr('data-customer-id') + ']').parents('li').removeClass('highlight');
});
