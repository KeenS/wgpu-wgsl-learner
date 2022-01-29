// fragment shader

struct Time {
    t: f32;
};
struct Resolution {
    r: vec2<f32>;
};


[[group(0), binding(0)]]
var<uniform> time: Time;

[[group(1), binding(0)]]
var<uniform> resolution: Resolution;


[[stage(fragment)]]
fn main([[builtin(position)]] FragCoord : vec4<f32>) -> [[location(0)]] vec4<f32> {
   return vec4<f32>(0.0, 1.0, 0.0, 1.0);
}