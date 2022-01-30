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
   let r = abs(sin(time.t * 0.1));
   let g = abs(cos(time.t * 2.0));
   let b = (r + g) / 2.0;
   return vec4<f32>(r, g, b, 1.0);
}
