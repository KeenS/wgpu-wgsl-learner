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

let white: vec3<f32> = vec3<f32>(1.0, 1.0, 1.0);
let red   = vec3<f32>(1.0, 0.0, 0.0);
let green = vec3<f32>(0.0, 1.0, 0.0);
let blue  = vec3<f32>(0.0, 0.0, 1.0);

fn circle(p: vec2<f32>, offset: vec2<f32>, size: f32, color: vec3<f32>, baseColor: vec3<f32>) -> vec3<f32> {
   let l = length(p - offset);
   if(l < size) {
      return color;
   } else {
      return baseColor;
   }
}

fn rect(p: vec2<f32>, offset: vec2<f32>, size: f32, color: vec3<f32>, baseColor: vec3<f32>) -> vec3<f32> {
   let q = (p - offset) / size;
   if(abs(q.x) < 1.0 && abs(q.y) < 1.0) {
      return color;
   } else {
      return baseColor;
   }
}


fn ellipse(p: vec2<f32>, offset: vec2<f32>, prop: vec2<f32>, size: f32, color: vec3<f32>, baseColor: vec3<f32>) -> vec3<f32> {
   let q = (p - offset) / prop;
   if(length(q) < size) {
      return color;
   } else {
      return baseColor;
   }
}

@stage(fragment)
fn main(@builtin(position) FragCoord : vec4<f32>) -> @location(0) vec4<f32> {
   let r = resolution.r;
   var destColor = white;
   let p = (FragCoord.xy * 2.0 - r) / min(r.x, r.y);

   destColor = circle (p, vec2<f32>( 0.0,  0.5), 0.25, red, destColor);
   destColor = rect   (p, vec2<f32>( 0.5, -0.5), 0.25, green, destColor);
   destColor = ellipse(p, vec2<f32>(-0.5, -0.5), vec2<f32>(0.5, 1.0), 0.25, blue, destColor);

   return vec4<f32>(destColor, 1.0);
}
