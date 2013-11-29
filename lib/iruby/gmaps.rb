require "iruby/gmaps/version"

module IRuby
  module Gmaps
    # Your data-points to Google Maps input
    # Expects an Array of elements that respond to `lat` and `lon`
    # 
    # also understands:
    # `E#icon_url`
    # `E#icon` (from http://www.google.com/intl/en_us/mapfiles/ms/micons/#{p.icon}-dot.png)
    # `E#weight` relative weight for heatmaps
    # `E#z_index` 
    # `E#label` 
    #
    def self.points2latlng(points)
          "[" + points.reject{|p| not p.lat or not p.lon}.map{|p| 
            icon_url = nil
            icon_url = p.icon_url if p.respond_to?(:icon_url)
            icon_url = "http://www.google.com/intl/en_us/mapfiles/ms/micons/#{p.icon}-dot.png"if p.respond_to?(:icon)
            "{" + [ 
              "location: new google.maps.LatLng(#{p.lat.to_f}, #{p.lon.to_f})",
              p.respond_to?(:weight) && p.weight && "weight: #{p.weight.to_i} ",
              p.respond_to?(:label)  && "label: #{p.label.to_s.to_json}",
              p.respond_to?(:z_index)  && "z_index: #{p.z_index.to_json}",
              icon_url  && "icon_url: #{icon_url.to_json}",
            ].reject{|x| ! x}
            .join(",") + "}"
          }.join(',') + "]"
    end

    # Creates a base map with
    # o[:zoom] 
    # o[:center] = Array(lat, lon)
    # o[:map_type] 
    # o[:width] = "500px"
    # o[:height] = "500px"
    def self.base_map(o)
      zoom = o.delete(:zoom)
      center = o.delete(:center)
      map_type = o.delete(:map_type)
      width = o.delete(:width) || "500px"
      height = o.delete(:height) || "500px"
      r = ""
      r += <<E
<div id='map-canvas' style='width: #{width}; height: #{height};'></div>
<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=visualization&callback=initialize"></script>

<script>
  function initialize() {
    var latlngbounds = new google.maps.LatLngBounds();
    var zoom = #{zoom.to_json};
    var center = #{center.to_json};
    var map_type = #{map_type.to_json} || google.maps.MapTypeId.SATELLITE;

    var mapOptions = { 
      mapTypeId: map_type
    };

    if (zoom){
      mapOptions.zoom = zoom
    }
    if (center){
      mapOptions.center = new google.maps.LatLng(center.lat, center.lon)
    }

    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

      #{yield}
  }
</script>
E
      r

    end

    # Instance a google heatmap 
    # 
    def self.heatmap(data, o={})
      raise "Missing :points parameter" if not data
      data = Array(data)

      points = points2latlng(data)
      radius = o.delete(:radius)
      Output.new(base_map(o){<<E
    var points = #{points};
    if (! zoom){
      for (var i = 0; i < points.length; i++) {
        latlngbounds.extend(points[i].location);
     }
     map.fitBounds(latlngbounds);
    }


    var pointArray = new google.maps.MVCArray(points);

    heatmap = new google.maps.visualization.HeatmapLayer({
      radius: #{radius.to_json} || 10,
      data: pointArray
    });

    heatmap.setMap(map);
E
      })

    end


    def self.markers(data, o)
      raise "Missing :points parameter" if not data
      data = Array(data)
      points = points2latlng(data)
      radius = o.delete(:radius)
      Output.new(base_map(o){<<E
    var points = #{points};
    if (! zoom){
      for (var i = 0; i < points.length; i++) {
        latlngbounds.extend(points[i].location);
     }
     map.fitBounds(latlngbounds);
    }

    for (var i=0; i<points.length; i++){
       var marker = new google.maps.Marker({
          position: points[i].location,
          map: map,
          icon: points[i].icon_url,
          zIndex: points[i].z_index,
          title: points[i].label
      });
    }

E
      })
    end

    class Output < String
      def to_iruby
        ['text/html', self.to_s]
      end
    end
  end
end
