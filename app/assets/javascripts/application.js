"use strict";
if (typeof console  == 'undefined') { var ef = function(){}; console = { log: ef, info: ef, warn: ef, error: ef };}

var timers_intervals;

$(document).ready( function(){

  timers_intervals['room_service'] = window.setInterval(RoomService.clean_up, 1000);

  if ( $('#new_cash_book')[0] ){
    timers_intervals['set_cash_book_time'] = window.setInterval(IV_funcs.set_cash_book_time, 5000);
    $([1,2,3,4,5]).each(function(i){$('#cash_book_date_'+i+'i').live('change', IV_funcs.suspend_set_cash_book_time);});
  };

  $('.scale_slider').each(function(i,el){
    ELPH.init_scale_slider(el);
  });
  $('div[data-sortable-controller],tbody[data-sortable-controller]').each(function(i,el){
    ELPH.init_sortable($(el));
  });

  $.datepicker.setDefaults( { altFormat: 'yy-mm-dd', dateFormat: 'yy-mm-dd', firstDay: 1, dayNamesMin: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'], monthNames: ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember']  } );
  $("input.date_picker" ).datepicker();

  console.log(['iframe:', $('#document_iframe')]);
  $('#document_iframe').load(function(e){
          console.info(['iframe loaded', e]);
          // $('#body').addClass('show_document');
          $('#body').removeClass('loading');
   });

  $('.datetimepicker').datetimepicker({
    dateFormat: 'yy-mm-dd',
    timeFormat: 'hh:mm:ss',
    changeYear: true,
    yearRange: "1990:" + (new Date().getFullYear() + 1).toString()
  });

  $('.md_area').crevasse({previewer: $('.md_preview'), convertTabsToSpaces: false});
  $('.marked').each(function(i,e){ELPH.marked(e);});
  ELPH.adjust_boxes_sizes();
});

timers_intervals = { set_cash_book_time: null, restore_set_cash_book_time: null };

//D_Rules['.rblock_line_button_save'] = D_Rules['.rblock_line_button_save']

var ELPH = {
  init_scale_slider: function(el){
    $(el).slider({
      value: $(el).attr('data-value'),
      max: 1,
      step: 1/256,
      change: function(e,ui){
        console.log([e,ui]);
        var slider = $(e.target).closest('div');
        var mo = /^(\w+)_(\d+)_/.exec($(slider).attr('id'));
        var model = mo[1];
        var id = mo[2];
        $(slider).addClass('loading');
        $.ajax({
          type: 'POST',
          url: '/' + model + 's/change_scale/' + id,
          data: '&value=' + ui.value + '&authenticity_token=' + window._token,
          success: function(){
          	$(slider).removeClass('loading');
          	if ($(slider).attr('data-live') === ""){
		        $(slider).parent().find('a.refresh_document').trigger('click');
          	}
  		  }
        });
      }
    });
  },
  init_sortable: function(el, handle_selector){
    var s_opts = {
      update: function(e,ui){
        var sortable = $(e.target).closest('tbody[data-sortable-controller]');
        var new_items = $('.' + ui.item.attr('id').replace(/_\d+$/,'_new'));
        if (new_items.length > 0 && ! confirm('Fürs Sotieren müssen alle neu eingefügten entfernt werden.\n\nWirklich die Ungespeicherten entfernen?')){
          sortable.sortable( "cancel" );
          return;
        };
        new_items.remove();
        var item_list = sortable.sortable('serialize',{key: 'items[]'});
        sortable.addClass('loading');
        console.log([sortable,$(e.currentTarget)]);
        $.ajax({
          type: 'POST',
          url: '/' + sortable.attr('data-sortable-controller') + '/order_items',
          data: item_list + '&authenticity_token=' + window._token,
          success: function(){sortable.removeClass('loading');}
        });
      },
      start: function(event, ui){
        $('#paper_contents').attr('data-currently-sorted','true');
        $(ui.item).removeClass('current');
      },
      stop: function(event, ui) {$('#paper_contents').attr('data-currently-sorted',null);}
    };
    if (el.attr('data-sortable-handle')){ s_opts['handle'] = el.attr('data-sortable-handle');};
    el.sortable(s_opts);
    console.info(['inited sortable on', el]);
  },
  marked: function(e){
    var md = $(e).html();
    $(e).html(marked(md));
  },
  adjust_boxes_sizes: function(){
    $('#customers_preview, #customers_box, .scroller').height(
                                 $(window).height()
                                 - $(".navi_pusher").height()
                                 - $(".footer_pusher").height()
    );
    $('#nav_wrapper, #footer').width('100%');
    $('#nav_wrapper, #footer').width($(document).width());
  }
};

var IV_funcs = { // IV = InVoice

  // insert_attachment_paper: function(e){ // for Email form
  //   var form_part = form_templates['paper'];
  //   var new_id = new Date().getTime();
  //   form_part.replace(/NEW_RECORD/g, new_id);
  //   form_part.replace('PAPER_ID', e.element().getAttribute('paper_id'));
  //   form_part.replace('CAPTION', e.element().innerHTML);
  //   $('#attachments').insert(form_part);
  // },

  double_submission_warning: function(e){ // for papers/new.html.erb
    console.info('funzieniert');
    var do_it = true;
    if ( $('#new_paper_form').attr('data-has_already_been_submitted') === 'true' ){
      do_it = confirm('Mit jedem (erfolgreichen) Absenden dieses Formulars, wird ein neues Dokument angelegt. Zweimal absenden erzeugt z.B. 2 neue Rechnungen.\n\nDies scheint das zweite mal zu sein. Wirklich absenden?');
    }
    if (! do_it){ e.stop(); }
    $('#new_paper_form').attr('data-has_already_been_submitted', 'true');
    return true;
  },


  set_cash_book_time: function(){
    console.log('set cash book time');

    var now = new Date();
    var minutes = '0' + now.getMinutes().toString();
    minutes = minutes.substr(minutes.length-2,2);
    $.each({ 1: now.getYear()+1900,2: now.getMonth()+1, 3: now.getDate(), 4: now.getHours(), 5: minutes }).each(function(k,v){

      $('#cash_book_date_' + k + 'i').val(v);
      //console.log(p.key + ': ' + p.value);
    });
  },

  suspend_set_cash_book_time: function(e){
    console.log('%s was changed', e.element().id);
    IV_helpers.clear_by_name('set_cash_book_time', window.clearInterval);
    IV_helpers.clear_by_name('restore_set_cash_book_time', window.clearTimeout);
    timers_intervals['restore_set_cash_book_time'] = window.setTimeout(function(){
        timers_intervals['set_cash_book_time'] = window.setInterval(IV_funcs.set_cash_book_time, 5000);
    }, 25000);
  },

  // save_text_content: function(content, el_id, instance){
  //   var mo = /_(\d+)$/.exec($(el_id).up('TR').id);
  //   if (typeof mo == "object"){var id = mo[1];}
  //   else {alert('Konnte id nicht ermitteln. Text wurde nicht gespeichert!'); return;}
  //   console.log('save button clicked for element "'+id+'"');
  //   instance.remove();
  //   //return;
  //   new Ajax.Request('/contents/update_ajax_text/'+id,
  //     {asynchronous:true, evalScripts:true,
  //     onLoading:function(request){$('content_'+id).down('div.content_main_column').addClassName('loading');},
  //     parameters:"content[text]=" + encodeURIComponent(content) + '&content[kind]=text&authenticity_token=' + window._token}
  //   );
  // },

  document_line_preview: function(e, element){
    if (e.target.nodeName == 'A'){
      console.info('Link clicked, exiting handler.');
      return;
    } /* else if (e.target.nodeName != 'LI'){
      //var li_elem = e.target.up('LI');
    } else {
      var li_elem = e.target;
    };*/
    var li_elem = $(e.target).closest('LI');
    var body_elem = li_elem.find('.document_line_body');
    var preview_elem = li_elem.find('.document_preview');
    var doc_id = /_(\d+)$/.exec(li_elem.attr('id'))[1];
    //console.info('doc_id: "%s"', doc_id);
    if (!(li_elem.attr('data-loaded') === 'true')){
      $.ajax( {
        url: '/documents/preview/' + doc_id,
        type: 'POST',
        data: 'authenticity_token=' + window._token,
        beforeSend: function(transport){
          li_elem.find('.document_line_title').addClass('loading');
          console.info('loading message content');
        },
        success: function(data,textStatus,jqXHR) {
          li_elem.attr('data-loaded', 'true');
          preview_elem.html(jqXHR.responseText);
          console.log(e);
          IV_funcs.document_line_preview(e);
          li_elem.find('div.document_line_title').removeClass('loading');
          li_elem.find('.marked').each(function(i, e){ELPH.marked(e);});
        },
        error: function(jqXHR, textStatus, errorThrown) {
                  console.log(['document laden', jqXHR, textStatus, errorThrown]);
                  //alert('Hat irgendwie nicht geklappt. Vielleicht einfach nochmal probieren?');
        }
      });

      return;
    }
    if (body_elem.css('display') != 'none'){
      body_elem.slideUp('fast');
    } else {
      if (li_elem.hasClass('unseen')){
        $.ajax({
          url: '/emails/seen/' + doc_id,
          data: 'authenticity_token=' + window._token,
          type: 'POST',
          beforeSend: function(){
            li_elem.find('.document_line_title').addClass('loading');
            console.info('marking email as seen');
          },
          success: function() {
            li_elem.removeClass('unseen');
            console.info('email successfully marked as seeen');
            li_elem.find('div.document_line_title').removeClass('loading');
          },
          error: function() {
            alert('Email konnte nicht als gelesen markiert werden');
          }
        });
      }
      body_elem.slideDown('slow');
    }
    //console.log('%s : %s', body_elem.tagName, body_elem.attr('id'));
  }
};

$(window).on('resize', function(){ELPH.adjust_boxes_sizes();});

marked.setOptions({
  gfm: true,
  pedantic: false,
  sanitize: true
});

$('input[id^=paper_realization_from],input[id^=lock_realization_dates_]').live("change", function(e){
  //console.log(['sync date blubbb:', e.target]);
  $('#lock_realization_dates_yes')[0].checked ? $('#paper_realization_to').fadeOut() : $('#paper_realization_to').fadeIn() ;
  if ($('#lock_realization_dates_yes')[0].checked){ $('#paper_realization_to').val( $('#paper_realization_from').val()); };
});

$('select#paper_kind').live('change', function(e){
  ["rechnung","barrechnung"].indexOf(this.value) != -1 ? $('#inv_specific').slideDown() : $('#inv_specific').slideUp();console.info(this.value);
});

$('#new_paper_form').live("submit", IV_funcs.double_submission_warning);

$('div.rblock_line_actions a').live('click', function(e){
  $(e.target).hide();
});


var IV_helpers = {

  clear_by_name: function(name,clear_func_ref){

    if (timers_intervals[name]){
      clear_func_ref(timers_intervals[name]);
      timers_intervals[name] = null;
    }
  }
};

$(document).on('click', '#iframe_wrapper #iframe_header a', function(e){
        $('#body').removeClass('show_document');
});

$(document).on('click', 'a[target=_pdf_]', function(e){
  $('#document_iframe').attr('src', 'about:blank');
  // console.log('et sollte, et sollte');
  e.preventDefault();           //
  $('#body').addClass('show_document');
  // $('#iframe_wrapper').append('<iframe id="document_iframe">');
  // $('#document_iframe').load(function(e){
  //         console.info(['iframe loaded', e]);
  //         $('#body').addClass('show_document');
  //         $('#body').removeClass('loading');
  //  });
  $('#body').addClass('loading');
  $('#document_iframe').attr('src', $(e.currentTarget).attr('href'));
  $('#iframe_header a.refresh_document').attr('href',  $(e.currentTarget).attr('href'));
});

// $(document).on('click mouseenter mouseleave', '#document_screen', function(e){
//         console.log('bye');
//         e.stopImmediatePropagation();
// });

$(document).on("ajax:before", "#customers_list_container li a[data-remote]", function(event) {
    $(event.target).attr('href', '/customers/' + $(event.target).attr('data-customer-id') + '.jsonrs');
    $('#customers_search').addClass('hide_sometimes_hidden');
});

$(document).on("change", "select#cpp", function(event) {
  var query = "?" + $(event.target).attr("data-model") + "_per_page=" + $(event.target).val();
  window.location=window.location.pathname + query
});

$(document).on('mouseenter', '#last_customers', function(e){
        var lc_div = $(e.currentTarget);
        if ( ! lc_div.data('sliding') ){
            lc_div.data('sliding', true);
            $('#last_customers ul:nth-child(2)').slideDown(function(){
                    //console.log('I slided!');
                    lc_div.data('sliding', false);
            });
        };
});
$(document).on('mouseleave', '#last_customers', function(event){
  console.log(['mouseout',event.target,event.currentTarget]);
  $('#last_customers ul:nth-child(2)').slideUp();
});
$("#customers_assign_existing_contactable li a[data-remote]").live("ajax:before", function(event, element) {
    if (!confirm('Wirklich diesem Kunden zuweisen?')){ event.stop(); };
    console.info('sollte jetz einklisch eschma funzen...');
    element.setAttribute('href', '/customers/assign_existing_contactable_to_existing_customer/'
        + element.readAttribute('data-customer-id') + '.jsonrs?existing_contactable_id='
        + $('customers_assign_existing_contactable').readAttribute('data-existing-contactable-id'));
    console.info('sollte jetz einklisch funzen...');
});

$("#customers_assign_existing_contactable_wrapper a.close").live("click", function(event,element){
  $('customers_assign_existing_contactable_wrapper').remove();
  $('safety_screen').removeClassName('on');
  event.stop();
});

$(document).on("mouseup", "input.clear_button", function(e){
  $(e.currentTarget).closest('div').find("input[id^=search]").val('');
});

$(document).on("change", "input.search_pns_cb", function(e){
    $("input.search_model").prop('disabled', $(e.currentTarget).prop('checked'));
    $("span.search_pns_full").toggle();
});


//$('li[id^=document_],li[id^=email_],li[id^=paper_],li[id^=talk_]').live("click", IV_funcs.document_line_preview);
$(document).on("click", '#documents_list li,.documents_list li', IV_funcs.document_line_preview);

$('input[class^=rblock_line_button_]').live("click", function(e){
  return;
    var inputs = Event.findElement(e).form.getInputs();
    inputs = inputs.reject(function(el){return el.type != 'submit' && el.type != 'button';});
    inputs.invoke('disable');
});

$('tr[id^=content_], tr[id^=rblock_line_]').live('mouseover', function(ev){
    if ( $('#paper_contents').attr('data-currently-sorted') == 'true') {return;}
    var tr = $(ev.currentTarget);
    var td = $(tr.children('TD.action_column')[0]);
    if (!td[0]){ return;};
    tr.addClass('current');
    var act_div = td.children('div');
    var offset = td.offset();
    //if (/^rblock_line_/.exec(tr.attr('id'))){
    //  offset.left += 5;
    //}
    //console.log([tr, td,act_div,offset]);
    if (tr.find('table').length != 0){ // case content line with rblock inside
      var table_height = $(tr.find('table')[0]).innerHeight();
      var foot_height = $(tr.find('table tfoot')[0]).innerHeight();
      //console.log([table_height,foot_height,{ left: offset.left, top: offset.top + table_height   }]);
      act_div.offset({ left: offset.left, top: offset.top + table_height - foot_height / 2 -  act_div.innerHeight() / 2 });
    } else {
      //console.log([td.innerHeight(), act_div.innerHeight()]);
      act_div.offset({ left: offset.left, top: offset.top + td.innerHeight() / 2 - act_div.innerHeight() / 2 });
    }
    if (tr.find('div.cl_handle').length != 0){
      var line_height = tr.innerHeight();
      var line_offset = tr.offset();
      var handle = $(tr.find('div.cl_handle')[0]);
      //console.log([line_height,line_offset]);
      handle.offset(line_offset);
      handle.height(line_height);
    }
});

$('tbody tr[id^=content_], tbody tr[id^=rblock_line_]').live('mouseout', function(ev){
    $(ev.currentTarget).removeClass('current');
});

$('#cash_book_background span.workshop').live('click',function(e){
		if ($('#cash_book_workshop').val() == 'f' || $('#cash_book_workshop').val() == 'false'){
			$('#cash_book_workshop').val('t');
			$('#cash_book_background').addClass('workshop');
		} else {
			$('#cash_book_workshop').val('f');
			$('#cash_book_background').removeClass('workshop');
		}
});

$(document).on('click', '*[data-clear-elements]', function(e){
  $($(e.currentTarget).attr('data-clear-elements')).html('');
});

$(document).on('click', '*[data-rm-class]', function(e){
  var ct = $(e.currentTarget);
  $(ct.attr('data-rm-class-on')).removeClass(ct.attr('data-rm-class'));
});
