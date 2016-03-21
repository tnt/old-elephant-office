$("a.not_to_be_saved_link").live("click", function(e){
  $('#' + $(e.target).attr('data-toggle-element')).toggleClass('not_to_be_saved');
  return false;
});

$("a[data-mark-delete-nested]").live("click", function(e){
	var subform_cont = $($('#' + $(e.target).attr('data-mark-delete-nested')));
	// console.log(['subform_cont:', subform_cont]);
  	subform_cont.addClass('to_be_deleted');
  	subform_cont.find('input[id$=__destroy]').val('true');
	return false;
});

$('form[id^=edit_customer_]').live('submit', function(e){
  $(e.target).find('div.not_to_be_saved div.contactable_subform, div.not_to_be_saved div.alias_subform').remove();
});
