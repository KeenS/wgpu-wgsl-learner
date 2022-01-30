// fragment shader

struct Time {
    t: f32;
};
struct Resolution {
    r: vec2<f32>;
};

@group(0) @binding(0)
var<uniform> time: Time;

@group(1) @binding(0)
var<uniform> resolution: Resolution;

@stage(fragment)
fn main(@builtin(position) FragCoord : vec4<f32>) -> @location(0) vec4<f32> {
   var p = (FragCoord.xy * 2.0 - resolution.r) / min(resolution.r.x, resolution.r.y);
   var destColor = vec3<f32>(0.0);
   for(var i = 0.0; i < 5.0; i+=1.0) {
      let j = i + 1.0;
      let q = p + vec2<f32>(cos(time.t * j), sin(time.t * j)) * 0.5;
      destColor += vec3<f32>(0.05 / length(q));
   }
   return vec4<f32>(destColor, 1.0);
}
