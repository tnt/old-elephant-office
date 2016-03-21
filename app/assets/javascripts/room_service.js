$("a[data-remote],form[data-remote],div[data-room-service-url]").live("ajax:before", function(event, element) {
  if ($(event.target).attr('data-loading-element')){
    console.log(['wird ausgeführt',event.target, '#'+$(event.target).attr('data-loading-element')]);
    $('#'+$(event.target).attr('data-loading-element')).addClass('loading');
  }
});

// $("a[data-remote],form[data-remote]").live("ajax:complete", function(event, element) {
// });

// $("a[data-remote],form[data-remote],div[data-room-service-url]").live("ajax:success", function(data, textStatus, jqXHR) {
$(document).live("ajax:success", "a[data-remote],form[data-remote],div[data-room-service-url]", function(xhr_event, resp_data, status) {
  if ($(xhr_event.target).attr('data-loading-element')  && $($(xhr_event.target).attr('data-loading-element'))){ // if placed in ajax:complete handler doesn't work if 'element' is removed
    $('#'+$(xhr_event.target).attr('data-loading-element')).removeClass('loading');
  }
  //console.log(['dingsdaplupsta', resp_data]);
  if ($(xhr_event.target).attr('data-room-service') || $(xhr_event.target).attr('data-room-service-url')){
    //var rs_jobs = xhr_event.memo.responseText.evalJSON();
    if (typeof resp_data === 'string'){
      var rs_jobs = $.parseJSON(resp_data);
    } else {
      var rs_jobs = resp_data;
    }
    console.log([ 'xhr_event... ', xhr_event ]);
    console.log([ 'resp_data... ', resp_data ]);
    console.log([ 'status... ', status ]);
    console.log('soweit, so dings so [ ' + $.map(rs_jobs, function(i){return "'"+i['job']+"'";}).join(',') + ' ]');
    rs_jobs.forEach(function(rs_job){
      if (rs_job['elements']){
        var elements = $(rs_job['elements']);
      } else {
        var elements = $('#'+rs_job['element']);
      }
      switch (typeof rs_job['content']) {
        case "string":
          var content = rs_job['content'];
          break;
        case "object":
          var content = rs_job['content'];
          break;
        case "undefined":
          // may be omitted
          break;
        default:
          console.error('unknown type of job content "' + typeof rs_job['content'] + '"');
          break;
      }
      //console.log( elements);
      if (elements.length === 0 || (elements.length === 1 && elements[0] === null)){
        console.warn('no elements to process rs_job[\'elements\']: "%s", rs_job[\'element\']: "%s"', rs_job['elements'], rs_job['element']);
        return;
      }
      //console.log('elements [ ' + elements.map(function(i){return "'"+i.toString()+"'"}).join(',') + ' ]');
      elements.each(function(i,element){
        //  console.log(['element:', element, 'typeof element:', typeof element] );
        RoomService.do_job($(element),rs_job);
      });
    });
  }
    //console.log(xhr_event.memo.responseText);
    //console.log(element);
});

var RoomService = {

  do_job: function(element, rs_job){
    //console.info(['trying job: "' + rs_job['job'] + '"', element, rs_job]);
    var content = rs_job['content'];
    switch (rs_job['job']) {
      case "replace_element":
        element.replaceWith(content);
        break;
      case "replace_content":
        element.html(content);
        break;
      case "insert_top":
        element.prepend(content);
        break;
      case "insert_bottom":
        element.append(content);
        break;
      case "insert_before":
        element.before(content);
        break;
      case "insert_after":
        element.after(content);
        break;
      case "add_classname":
        element.addClass(content);
        break;
      case "remove_classname":
        element.removeClass(content);
        break;
      case "set_attributes": // expects a Hash
        element.attr(content);
        break;
      case "remove_attributes": // expects an Array
        content.each(function(item){
            element.removeAttribute(item);
        });
        break;
      case "highlight_elements":
        element.effect('highlight', content, 1000);
        break;
      case "hide_elements":
        element.hide();
        break;
      case "show_elements":
        element.show();
        break;
      case "set_focus":
        element.focus();
        break;
      case "effect":
        //new Effect[content](element,{duration:2.0});
        break;
      case "trigger_event":
        element.fire(content);
        break;
      case "call":
        console.info(['calling', content, 'on', element]);
        ELPH[content](element);
        console.info(['should have done it']);
        break;
      case "refresh_sortable":  // aeons easier in jQuery
        /*Sortable.create(element.id, {
          onUpdate: function(){
            new Ajax.Request(content['url'], {
              asynchronous: true,
              evalScripts: true,
              parameters: Sortable.serialize(element.id) + '&' + $('meta[name=csrf-param]')[0].readAttribute('content') + '=' + $('meta[name=csrf-token]')[0].readAttribute('content'),
              onLoading:  function(response) {
                 element.addClassName('loading');
              },
              onComplete: function(response) {
                 element.removeClassName('loading');
              },
              onFailure:  function(response) {
                 alert('sorting failed');
                 window.location = window.location;
              }
            })
          },
          //ghosting: true,
          tag: content['tag'],
          handle: content['handle']
        });*/
        break;
      case "alert":
        alert(content);
        break;
      case "set_location":
        window.location = content;
        break;
      case "reload_page":
        window.location = window.location;
        break;
      case "reset_form":
        element.reset(); // relies on http://plugins.jquery.com/files/jquery-reset.js.txt
        break;
      case "set_form_value":
        element.value = content;
        break;
      case "align_at_element":
          var offset = $(element).offset();
          console.info(['align_at_element', element, offset]);
        break;
      default:
        console.error('unknown job_name "' + rs_job['job'] + '"');
        break;
    }
    //console.info('job done: "' + rs_job['job'] + '"');
  },

  clean_up: function(){
    //console.log('cleanup service running');
    var now = new Date().getTime();
    $('*[data-cleanup-in]').each(function(i,item){
      //console.log([item, item.id]);
      //return;
      item = $(item);
      var len = parseFloat(item.attr('data-cleanup-in'));
      var at = now + len *1000;
      item.attr('data-cleanup-in',null);
      item.attr('data-cleanup-at', at.toString());
      console.log('Room service set "data-cleanup-at" to "' + at + '" for "' + item.attr('id') + '"');
    });
    $('*[data-cleanup-at]').each(function(i,item){
      item = $(item);
        if (item.attr('data-cleanup-at') < now){
          item.attr('data-cleanup-at',null); // it will probably dissapear delayed
          RoomServiceHelpers.wipe_out(item);
          console.log('Room service cleaned up "' + item.attr('id') + '"');
        };
    });
  }

};

var RoomServiceHelpers = {

  wipe_out: function( elem, seconds ){
    elem = $(elem);
    if (/\S/.exec(elem.innerHTML)){
      elem.slideUp();
      elem.fadeOut().remove();
    }
  }
};

$(document).on("ajax:error", "a[data-remote],form[data-remote]", function(xhr_event, resp_data, status) {
  if ($(xhr_event.target).attr('data-loading-element') && $('#'+$(xhr_event.target).attr('data-loading-element'))){ // if placed in ajax:complete handler doesn't work if 'element' is removed
    $('#'+$(xhr_event.target).attr('data-loading-element')).removeClass('loading');
  }
  var div_id = 'error-' + new Date().getTime().toString();
  $(document.body).append('<div id="' + div_id + '"  style="clear: both; width:90%; border: 1px solid #222;"></div>');
  var err_div = $('#'+div_id);
  //console.log(['Yes!!!!!!!!!!!!' , resp_data, status]);
  err_div.append(resp_data.responseText);
  err_div.prepend('<a href="#" data-remove-element="' + div_id + '">remove</a>');
});

$("a[data-remove-element]").live("click", function(e){
  RoomServiceHelpers.wipe_out($('#'+$(e.target).attr('data-remove-element')),0);
  return false;
});

$(document).on("click", "a[data-toggle-sometimes-hidden]", function(e){
  $('#'+$(e.target).attr('data-toggle-sometimes-hidden')).toggleClass('hide_sometimes_hidden');
  $(e.target).toggleClass('on');
  return false;
});

$(document).on("click", "div[data-room-service-url]", function(e) {
    var cont_div = $(e.currentTarget);
    var event = cont_div.trigger("ajax:before");
    if (event.stopped) return false;
    console.log(['data-dings-url',cont_div.attr('data-room-service-url'), cont_div]);
      $.ajax( {
        url: cont_div.attr('data-room-service-url'),
        type: 'POST',
        data: 'authenticity_token=' + window._token,
        success:     function(request) { cont_div.trigger("ajax:success", [ request ]); }
    });
});
