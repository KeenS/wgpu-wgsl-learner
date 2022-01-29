precision mediump float;
layout(set=0, binding=0) uniform Time { float t; } time; // time
layout(set=1, binding=0) uniform Resolution{ vec2  r; } resolution; // resolution

layout(location=0) out vec4 gl_FragColor;

void main(void) {
  float a = gl_FragCoord.y / 512.0;
  gl_FragColor = vec4(vec3(a), 1.0);
}
