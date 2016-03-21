# coding: utf-8

module ActionView
  module CompiledTemplates
    class MyPaginationRenderer #< WillPaginate::ViewHelpers::LinkRenderer
      def page_number(page)
        unless page == current_page
          link(page, page, :rel => rel_value(page), 'data-remote' => 'true', 'data-room-service' => 'true',
            'data-loading-element' => 'customers_list_container')
        else
          tag(:em, page)
        end
      end
    end
  end
end
module CustomersHelper
  def cond_line content, label=''
    l = label.blank? ? '' : "#{label}: "
    #content.nil? || content.empty? ? '' : h( label + content ) + ( content.nil? || content.empty? ? '' : '<br />' )
    content.blank? ? '' : h( l + content ) + '<br>'.html_safe
  end
end
