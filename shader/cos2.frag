precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  float r = abs(sin(t * 0.1));
  float g = abs(cos(t * 2.0));
  float b = (r + g) / 2.0;
  gl_FragColor = vec4(r, g, b, 1.0);
}
