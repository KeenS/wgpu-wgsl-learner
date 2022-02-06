precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

const float PI = 3.1415926;
const vec3 lightColor = vec3(0.95, 0.95, 0.5);
const vec3 backColor  = vec3(0.95, 0.25, 0.25);

void sunrise(vec2 p, inout vec3 i) {
  float f  = atan(p.y, p.x) + t;
  float fs = sin(f * 10.0);
  i = mix(lightColor, backColor, fs);
}

void main(void) {
  vec2 p = (gl_FragCoord.xy * 2.0 - r) / min(r.x, r.y);

  vec3 destColor = vec3(1.0);

  sunrise(p, destColor);

  gl_FragColor = vec4(destColor, 1.0);
}
