precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  vec2 p = (gl_FragCoord.xy * 2.0 - r) / min(r.x, r.y);
  vec3 destColor = vec3(0.0);
  for(float i = 0.0; i < 5.0; i++) {
    float j = i + 1.0;
    vec2 q = p + vec2(cos(t * j), sin(t * j)) * 0.5;
    destColor += 0.05 / length(q);
  }
  p += vec2(cos(t * 5.0), sin(t)) * 0.5;
  float l = 0.1 / length(p);
  gl_FragColor = vec4(destColor, 1.0);
}
