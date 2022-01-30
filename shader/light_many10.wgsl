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
   var destColor = vec3<f32>(1.0, 0.3, 0.7);
   var f = 0.0;
   for(var i = 0.0; i < 10.0; i+=1.0) {
      let s = sin(time.t + i * 0.628318) * 0.5;
      let c = cos(time.t + i * 0.628318) * 0.5;
      f += 0.0025 / abs(length(p + vec2<f32>(c, s)) - 0.5);
   }
   return vec4<f32>(destColor * f, 1.0);
}
