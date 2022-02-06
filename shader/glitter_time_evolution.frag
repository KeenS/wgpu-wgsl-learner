precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  vec2 p = (gl_FragCoord.xy * 2.0 - r) / min(r.x, r.y);
  vec2 q = mod(p + 1, 0.2) - 0.1;
  float s = sin(t);
  float c = cos(t);
  q *= mat2(c, s, -s, c);
  float v = 0.1 / abs(q.x) * abs(q.y);
  float r = v * abs(sin(t * 0.6) + 1.5);
  float g = v * abs(sin(t * 4.5) + 1.5);
  float b = v * abs(sin(t * 3.0) + 1.5);
  gl_FragColor = vec4(r, g, b, 1.0);
}
