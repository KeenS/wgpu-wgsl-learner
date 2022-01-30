precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  vec2 p = (gl_FragCoord.xy * 2.0 - r) / min(r.x, r.y);
  p += vec2(cos(t * 5.0), sin(t)) * 0.5;
  float l = 0.1 / length(p);
  gl_FragColor = vec4(vec3(l), 1.0);
}
