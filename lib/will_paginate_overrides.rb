# coding: UTF-8

class WillPaginateOverrides
  fh = File.open Rails.root.to_s + '/log/test.log', 'w'
  fh. write '################################################## Fuck You!!!!!!!' + Time.now.to_s
  fh.close
end
