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
   let f = 0.001 / (abs(p.x) * abs(p.y));
   return vec4<f32>(vec3<f32>(f), 1.0);
}