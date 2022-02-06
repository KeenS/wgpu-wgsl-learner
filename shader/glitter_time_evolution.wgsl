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
   let t = time.t;
   let p = (FragCoord.xy * 2.0 - r) / min(r.x, r.y);
   var q = mod(p, 0.2) - 0.1;
   let s = sin(t);
   let c = cos(t);
   q *= mat2x2<f32>(c, s, -s, c);
   let v = 0.1 / abs(q.x) * abs(q.y);
   let r = v * abs(sin(t * 0.6) + 1.5);
   let g = v * abs(sin(t * 4.5) + 1.5);
   let b = v * abs(sin(t * 3.0) + 1.5);
   return vec4<f32>(r, g, b, 1.0);
}
