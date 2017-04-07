class Rgb
  attr_accessor :r, :g, :b

  def initialize(r,g,b)
    @r = fix_color(r.to_f)
    @g = fix_color(g.to_f)
    @b = fix_color(b.to_f)
  end

  def fix_color(num)
    if num > 1
      num = 1
    end
    if num < 0
      num = 0
    end
    return num
  end

  def fix_color1(rgb)
    if rgb[i] > 1.0
      rgb[i] = 1.0
    end
    if rgb[i] < 0.0
      rgb[i] = 0.0
    end
    #return num.to_f
  end

  def add_color (a_color)
    Rgb.new(@r+a_color.r, @g+a_color.g, @b+a_color.b)
  end

  def substract_color (a_color)
    Rgb.new(@r-a_color.r, @g-a_color.g, @b-a_color.b)
  end

  def multiply_color (a_color)
    red = @r*a_color.r
    green = @g*a_color.g
    blue = @b*a_color.b

    Rgb.new(red,green,blue)
  end

  def times_color (a_number)
    number_as_float = a_number.to_f
    Rgb.new(@r*number_as_float, @g*number_as_float, @b*number_as_float)
  end

end
