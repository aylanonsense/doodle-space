uniform mat4 camera_transform;
uniform mat4 model_transform;
uniform mat4 model_transform_inverse;
uniform float ambient_light_level;
uniform float world_light_level;
uniform vec3 world_light_direction;

varying vec3 normal;

#ifdef VERTEX
  attribute vec4 vertex_normal;

  vec4 position(mat4 transform_projection, vec4 vertex_position) {
    normal = vec3(model_transform_inverse * vertex_normal);
    return camera_transform * model_transform * vertex_position;
  }
#endif

#ifdef PIXEL
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texture_color = Texel(texture, texture_coords);
    if (texture_color.a == 0.0) {
        discard;
    }
    float world_light = world_light_level * max(dot(normalize(world_light_direction), normal), 0);
    texture_color.rgb *= ambient_light_level + world_light * (1 - ambient_light_level);
    return color * texture_color;
  }
#endif
