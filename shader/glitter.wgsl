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

fn mod(d: vec2<f32>, m: f32) -> vec2<f32> {
    return d - floor(d/m) * m;
}

@stage(fragment)
fn main(@builtin(position) FragCoord : vec4<f32>) -> @location(0) vec4<f32> {
   let r = resolution.r;
   let p = (FragCoord.xy * 2.0 - r) / min(r.x, r.y);
   let q = mod(p, 0.2) - 0.1;
   let f = 0.2 / abs(q.x) * abs(q.y);
   return vec4<f32>(vec3<f32>(f), 1.0);
}
