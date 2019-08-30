uniform mat4 camera;
uniform mat4 modelMatrix;
uniform mat4 modelMatrixInverse;
uniform float ambientLightLevel;
uniform vec3 ambientLightDirection;

varying mat4 modelView;
varying mat4 modelViewProjection;
varying vec3 normal;
varying vec3 vposition;

#ifdef VERTEX
  attribute vec4 VertexNormal;

  vec4 position(mat4 transform_projection, vec4 vertex_position) {
    modelView = camera * modelMatrix;
    modelViewProjection = camera * modelMatrix * transform_projection;
    normal = vec3(modelMatrixInverse * vec4(VertexNormal));
    vposition = vec3(modelMatrix * vertex_position);
    return camera * modelMatrix * vertex_position;
  }
#endif

#ifdef PIXEL
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texturecolor = Texel(texture, texture_coords);
    if (texturecolor.a == 0.0) {
        discard;
    }
    float light = max(dot(normalize(ambientLightDirection), normal), 0);
    texturecolor.rgb *= max(light, ambientLightLevel);
    return color*texturecolor;
  }
#endif
