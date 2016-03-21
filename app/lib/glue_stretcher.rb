# coding: utf-8

class GlueStretcher
  attr_reader :scale_factor
  def initialize scale_factor=0.5, values_hash={}
    @scale_factor = scale_factor
    @values_hash = values_hash
    set_alias
  end
  def scale_factor= scale_factor
    @scale_factor = scale_factor
    set_alias
  end
  def set_alias
    if @scale_factor == 0.5
      self.class.class_eval 'alias [] dont_scale'
    elsif @scale_factor < 0.5
      self.class.class_eval 'alias [] scale_down'
    else
      self.class.class_eval 'alias [] scale_up'
    end
  end
  def dont_scale key
    @values_hash[key][1]
  end
  def scale_down key
    @values_hash[key][0] + ( @values_hash[key][1] - @values_hash[key][0] ) * @scale_factor * 2
  end
  def scale_up key
    @values_hash[key][1] + ( @values_hash[key][2] - @values_hash[key][1] ) * (@scale_factor - 0.5) * 2
  end
  # def bracket key
    # @values_hash[key][0] + ( @values_hash[key][1] - @values_hash[key][0] ) * @scale_factor
  # end
  def []= key, values
    @values_hash[key] = values
  end
  def update values_hash
    @values_hash.update values_hash
  end
end

