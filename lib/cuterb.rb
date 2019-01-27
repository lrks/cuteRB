require 'cuterb/version'
require 'rqrcode'
require_relative './utils.rb'
require 'rmagick'

module CuteRB
  class Error < StandardError; end

  class CLI
		def initialize(text, image, output)
	    @qr = RQRCode::QRCode.new(text, :level => :h)

      @image = Magick::ImageList.new(image).first
			@image = @image.crop(0, 0, [@image.columns, @image.rows].min, [@image.columns, @image.rows].min)
			raise "#{image} too small." if @image.columns < @qr.module_count
			@image = @image.quantize(256, Magick::GRAYColorspace)
			bg = Magick::Image.new(@image.columns, @image.columns) { self.background_color = "white" }
			@image = bg.composite(@image, 0, 0, Magick::OverCompositeOp).normalize.contrast(true).contrast(true)

      @output = output
    end

    def run()
			pixel = qrpixel()
			overlay(pixel)
			@image.write(@output)
      return 0
    end


    private
		def qrpixel()
      data = @qr.to_s(:dark => 'b', :light => 'w').delete("\n").chars
			Utils.place_position_probe_pattern(data, 0, 0)
			Utils.place_position_probe_pattern(data, @qr.module_count - 7, 0)
			Utils.place_position_probe_pattern(data, 0, @qr.module_count - 7)
			Utils.place_position_adjust_pattern(data, @qr.version)
			return data
		end

		def overlay(pixel, size=0.2, black_threshold=75, white_threshold=185)
			scale = @image.columns / @qr.module_count.to_f
			offset = (1 - size) * 0.5 * scale
			size = size * scale

			for row in 0...@qr.module_count
				for col in 0...@qr.module_count
					cell = pixel[row * @qr.module_count + col]

					x = col * scale
					y = row * scale
					if cell.downcase == cell
						x1 = (x + offset).round
						y1 = (y + offset).round
						xy = size.ceil

						mean = @image.export_pixels(x1, y1, xy, xy, 'R').map{ |px| px/257.0 }.sum(0.0) / (xy * xy)
						next if ((cell == 'b' && mean < black_threshold) || (cell == 'w' && mean > white_threshold))
					else
						x1 = x.round
						y1 = y.round
						xy = scale.ceil
					end

					draw = Magick::Draw.new
					draw.fill((cell.downcase == 'w') ? '#ffffff' : '#000000')
					draw.rectangle(x1, y1, x1+xy, y1+xy)
					draw.draw(@image)
				end
			end

			quiet = 4 * scale
			width = (@image.columns + quiet * 2).ceil
			bg = Magick::Image.new(width, width) { self.background_color = "white" }
			@image = bg.composite(@image, quiet.round, quiet.round, Magick::OverCompositeOp)
		end
  end
end
