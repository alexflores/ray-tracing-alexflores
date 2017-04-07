require_relative 'renderer.rb'
require_relative 'camera.rb'
require_relative 'vector.rb'
require_relative 'rgb.rb'
require_relative 'intersection.rb'
require_relative 'sphere.rb'
require_relative 'triangle.rb'
require_relative 'light.rb'
require_relative 'material.rb'

class RayTracer < Renderer

  attr_accessor :camera

  def initialize(width, height)
    super(width, height, 250.0, 250.0, 250.0)

    @nx = @width
    @ny = @height
    # Camera values
    e= Vector.new(278,273,-800)
    center= Vector.new(278,273,-700)
    up= Vector.new(0,1,0)
    fov= 39.31
    df=0.035
    @camera = Camera.new(e, center, up, fov, df)
    # Light values
    light_color = Rgb.new(1.0,1.0,1.0)
    light_position = Vector.new(500.0, 1000.0, 0.0)
    @light = Light.new(light_position,light_color)

    # Sphere1 values
    position1 = Vector.new(370,150,2570)
    radius1 = 800
    #sphere_color = Rgb.new(1.0,0.0,1.0)
    sphere_diffuse1 = Rgb.new(1.0, 0.0, 1.0)
    sphere_specular1 =Rgb.new(1.0,1.0,1.0)
    sphere_reflection1 = 0.5
    sphere_power1 = 200

    #Triangle1 values
    a1 = Vector.new(658,-10,0)
    b1 = Vector.new(-100,-10,0)
    c1 = Vector.new(-150,-80,658)
    #triangle_color = Rgb.new(1.0,1.0,0.0)
    triangle_diffuse1 = Rgb.new(1.0,0.0,0.0)
    triangle_specular1 = Rgb.new(1.0,1.0,1.0)
    triangle_reflection1 = 0.5
    triangle_power1 = 60

    triangle_material1 = Material.new(triangle_diffuse1, triangle_reflection1, triangle_specular1, triangle_power1)
    sphere_material1 = Material.new(sphere_diffuse1, sphere_reflection1, sphere_specular1, sphere_power1)
    
    #@sphere = Sphere.new(position, radius, sphere_color)
    @sphere1 = Sphere.new(position1, radius1, sphere_material1)
    @triangle2 = Triangle.new(a1, b1, c1, triangle_material1)
    @objects=[]
    @objects <<@sphere1 <<@triangle2
  end

  def calculate_pixel(i, j)
    e = @camera.e
    dir = @camera.ray_direction(i,j,@nx,@ny)
    ray = Ray.new(e, dir)
    t = Float::INFINITY

    @obj_int = nil
    @objects.each do |obj|
      intersection = obj.intersection?(ray, t)
      if intersection.successful?
        @obj_int = obj
        t = intersection.t
      end
    end
    if @obj_int==nil
      color = Rgb.new(0.0,0.0,0.0)
    else
      #color = @obj_int.color
      intersection_point = ray.position.plus(ray.direction.num_product(t))
      intersection_normal = @obj_int.normal(intersection_point)

      lambert = lambertian_shading(intersection_point, intersection_normal, ray, @light, @obj_int)
      phong = blinn_phong_shading(intersection_point, intersection_normal, ray, @light, @obj_int)
      @ambient_light = Rgb.new(0.1, 0.1, 0.1)
      ambient = @obj_int.material.diffuse.multiply_color(@ambient_light)   
      puts "(Lambert: r: #{lambert.r} , g: #{lambert.g} , b: #{lambert.b})"
      puts "(Phong: r: #{phong.r} , g: #{phong.g} , b: #{phong.b})"
      puts "(Ambient: r: #{ambient.r} , g: #{ambient.g} , b: #{ambient.b})"
      #color = @obj_int.material.diffuse #2D
      #color = lambert #Lambertian shading
      #color = phong #Blinn phong shading
      #color = ambient #Ambient shading
      color = ambient.add_color(lambert.add_color(phong))
      #color = phong.plus(lambert)
    end

    return {red: color.r, green: color.g, blue: color.b}
  end

  def max(n1, n2)
    if n1 > n2
      return n1
    else
      return n2
    end
  end

  def lambertian_shading(intersection_point, intersection_normal, ray, light, object)
    n = intersection_normal.normalized
    v = ray.position.minus(intersection_point).normalized
    l = light.position.minus(intersection_point).normalized

    nl = n.scalar_product(l)
    max = max(0, nl)
    kd = object.material.diffuse
    kdI = kd.multiply_color(light.color)

    return kdI.times_color(max)
  end

  def blinn_phong_shading(intersection_point, intersection_normal, ray, light, object)
    n = intersection_normal.normalized
    v = ray.position.minus(intersection_point).normalized
    l = light.position.minus(intersection_point).normalized
    h = v.plus(l).normalized

    nh = n.scalar_product(h)
    max = max(0, nh)
    ks = object.material.specular
    p = object.material.power
    ksI = ks.multiply_color(light.color)

    return ksI.times_color(max**p)
  end
end