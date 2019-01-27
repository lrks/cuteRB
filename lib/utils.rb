module CuteRB
  class Utils
    # rqrcode: /lib/rqrcode/qrcode/qr_util.rb L16 -- L58
    #--
    # Copyright 2004 by Duncan Robertson (duncan@whomwah.com).
    # All rights reserved.

    # Permission is granted for use, copying, modification, distribution,
    # and distribution of modified versions of this work as long as the
    # above copyright notice is included.
    #++
    PATTERN_POSITION_TABLE = [
      [],
      [6, 18],
      [6, 22],
      [6, 26],
      [6, 30],
      [6, 34],
      [6, 22, 38],
      [6, 24, 42],
      [6, 26, 46],
      [6, 28, 50],
      [6, 30, 54],
      [6, 32, 58],
      [6, 34, 62],
      [6, 26, 46, 66],
      [6, 26, 48, 70],
      [6, 26, 50, 74],
      [6, 30, 54, 78],
      [6, 30, 56, 82],
      [6, 30, 58, 86],
      [6, 34, 62, 90],
      [6, 28, 50, 72, 94],
      [6, 26, 50, 74, 98],
      [6, 30, 54, 78, 102],
      [6, 28, 54, 80, 106],
      [6, 32, 58, 84, 110],
      [6, 30, 58, 86, 114],
      [6, 34, 62, 90, 118],
      [6, 26, 50, 74, 98, 122],
      [6, 30, 54, 78, 102, 126],
      [6, 26, 52, 78, 104, 130],
      [6, 30, 56, 82, 108, 134],
      [6, 34, 60, 86, 112, 138],
      [6, 30, 58, 86, 114, 142],
      [6, 34, 62, 90, 118, 146],
      [6, 30, 54, 78, 102, 126, 150],
      [6, 24, 50, 76, 102, 128, 154],
      [6, 28, 54, 80, 106, 132, 158],
      [6, 32, 58, 84, 110, 136, 162],
      [6, 26, 54, 82, 110, 138, 166],
      [6, 30, 58, 86, 114, 142, 170]
    ]

    # rqrcode: lib/rqrcode/qrcode/qr_code.rb L346 -- L361
    #--
    # Copyright 2008 by Duncan Robertson (duncan@whomwah.com).
    # All rights reserved.

    # Permission is granted for use, copying, modification, distribution,
    # and distribution of modified versions of this work as long as the
    # above copyright notice is included.
    #++
    def self.place_position_probe_pattern(dst, row, col)
      length = Math.sqrt(dst.length).to_i
      (-1..7).each do |r|
        next if !(row + r).between?(0, length - 1)

        (-1..7).each do |c|
          next if !(col + c).between?(0, length - 1)

          is_vert_line = (r.between?(0, 6) && (c == 0 || c == 6))
          is_horiz_line = (c.between?(0, 6) && (r == 0 || r == 6))
          is_square = r.between?(2,4) && c.between?(2, 4)
          y = row + r
          x = col + c
          dst[y * length + x] = (is_vert_line || is_horiz_line || is_square) ? 'B' : 'W'
        end
      end
    end

    # rqrcode: lib/rqrcode/qrcode/qr_code.rb L388 -- L403
    #--
    # Copyright 2008 by Duncan Robertson (duncan@whomwah.com).
    # All rights reserved.

    # Permission is granted for use, copying, modification, distribution,
    # and distribution of modified versions of this work as long as the
    # above copyright notice is included.
    #++
    def self.place_position_adjust_pattern(dst, version)
      length = Math.sqrt(dst.length).to_i
      positions = PATTERN_POSITION_TABLE[version - 1]

      positions.each do |row|
        positions.each do |col|
          next if dst[row * length + col] == dst[row * length + col].upcase

          ( -2..2 ).each do |r|
            ( -2..2 ).each do |c|
              y = row + r
              x = col + c
              dst[y * length + x] = (r.abs == 2 || c.abs == 2 || (r == 0 && c == 0)) ? 'B' : 'W'
            end
          end
        end
      end
    end

    def self.dump(data)
      length = Math.sqrt(data.length).to_i
      for row in 0...length
        for col in 0...length
          case data[row * length + col]
          when 'b'
            print "\e[47m  \e[m"
          when 'w'
            print "\e[40m  \e[m"
          when 'B'
            print "\e[30m\e[47m--\e[m\e[m"
          when 'W'
            print "\e[37m\e[40m--\e[m\e[m"
          else
            p data[row * length + col]
          end
        end
        puts ""
      end
    end
  end
end
