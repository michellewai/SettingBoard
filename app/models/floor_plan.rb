# Geometry of the gym's wall map, in SVG viewBox units. Walls are keyed by WallSection id.
module FloorPlan
  VIEW_BOX = "0 0 1070 455"

  # Gap kept between a wall's end and its outermost markers, so markers on walls
  # that meet at a corner don't overlap.
  MARKER_END_GAP = 16

  Wall = Data.define(:colour, :points, :label_at) do
    def svg_points = points.map { |x, y| "#{x},#{y}" }.join(" ")

    # Evenly spaced [x, y] positions along the wall, one per marker.
    def marker_positions(count)
      segments = points.each_cons(2).to_a
      lengths = segments.map { |(x1, y1), (x2, y2)| Math.hypot(x2 - x1, y2 - y1) }
      total = lengths.sum
      usable = total - 2 * MARKER_END_GAP

      Array.new(count) do |i|
        distance = MARKER_END_GAP + (count == 1 ? usable / 2.0 : usable * i / (count - 1))
        index = 0
        while index < segments.size - 1 && distance > lengths[index]
          distance -= lengths[index]
          index += 1
        end
        (x1, y1), (x2, y2) = segments[index]
        t = distance / lengths[index]
        [ (x1 + (x2 - x1) * t).round(1), (y1 + (y2 - y1) * t).round(1) ]
      end
    end
  end

  # 1 => "Back", 2 => "Slab", 3 => "Cave", 4 => "Front"
  WALLS = {
    1 => Wall.new(colour: "#778899", points: [ [ 250, 131 ], [ 95, 131 ], [ 95, 355 ], [ 255, 355 ] ], label_at: [ 170, 255 ]),
    2 => Wall.new(colour: "#c4aead", points: [ [ 250, 131 ], [ 518, 131 ] ],                         label_at: [ 372, 193 ]),
    3 => Wall.new(colour: "#343434", points: [ [ 518, 131 ], [ 673, 131 ], [ 673, 250 ] ],           label_at: [ 596, 193 ]),
    4 => Wall.new(colour: "#666699", points: [ [ 673, 250 ], [ 970, 250 ] ],                         label_at: [ 824, 308 ])
  }.freeze

  def self.wall_for(wall_section) = WALLS.fetch(wall_section.id)
end
