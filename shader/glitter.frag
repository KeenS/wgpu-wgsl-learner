precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  vec2 p = (gl_FragCoord.xy * 2.0 - r) / min(r.x, r.y);
  vec2 q = mod(p + 1, 0.2) - 0.1;
  float f = 0.2 / abs(q.x) * abs(q.y);
  gl_FragColor = vec4(vec3(f), 1.0);
}
