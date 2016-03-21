#!/usr/bin/ruby
# -*- coding: utf-8 -*-

module ElphConfig
  Elph = ActiveSupport::HashWithIndifferentAccess.new(YAML.load(File.read(Rails.root.to_s + '/config/elph_conf.yml')))[Rails.env]
end

class ActiveRecord::Base
  include ElphConfig
end
class ActionController::Base 
  include ElphConfig
end
class ActionMailer::Base 
  include ElphConfig
end
class ActionView::Base
  include ElphConfig
end
module ActionView::CompiledTemplates
  include ElphConfig
end
