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

let PI: f32 = 3.1415926;
let lightColor: vec3<f32> = vec3<f32>(0.95, 0.95, 0.5);
let backColor : vec3<f32> = vec3<f32>(0.95, 0.25, 0.25);

fn sunrise(p: vec2<f32>, i: vec3<f32>) -> vec3<f32> {
   let t = time.t;
   let f  = atan2(p.y, p.x) + t;
   let fs = sin(f * 10.0);
   return mix(lightColor, backColor, fs);
}

@stage(fragment)
fn main(@builtin(position) FragCoord : vec4<f32>) -> @location(0) vec4<f32> {
   let r = resolution.r;
   let p = (FragCoord.xy * 2.0 - r) / min(r.x, r.y);

   var destColor = vec3<f32>(1.0);

   destColor = sunrise(p, destColor);
   return vec4<f32>(destColor, 1.0);
}
