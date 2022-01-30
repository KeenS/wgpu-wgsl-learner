precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  vec2 p = (gl_FragCoord.xy * 2.0 - r) / min(r.x, r.y);
  vec3 destColor = vec3(1.0, 0.3, 0.7);
  float f = 0.0;
  for(float i = 0.0; i < 10.0; i++) {
    float s = sin(t + i * 0.628318) * 0.5;
    float c = cos(t + i * 0.628318) * 0.5;
    f += 0.0025 / abs(length(p + vec2(c, s)) - 0.5);
  }
  gl_FragColor = vec4(vec3(destColor * f), 1.0);
}
