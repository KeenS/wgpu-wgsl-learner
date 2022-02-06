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
let faceColor : vec3<f32> = vec3<f32>(0.95, 0.75, 0.5);
let noseColor : vec3<f32> = vec3<f32>(0.95, 0.25, 0.25);
let cheekColor: vec3<f32> = vec3<f32>(1.0 , 0.55, 0.25);
let eyesColor : vec3<f32> = vec3<f32>(0.15, 0.05, 0.05);
let highlight : vec3<f32> = vec3<f32>(0.95, 0.95, 0.95);
let lineColor : vec3<f32> = vec3<f32>(0.3 , 0.2 , 0.2);


fn circle(p: vec2<f32>, offset: vec2<f32>, size: f32, color: vec3<f32>, i: ptr<function, vec3<f32>>)  {
   let l = length(p - offset);
   if(l < size) {
      *i = color;
   }
}

fn ellipse(p: vec2<f32>, offset: vec2<f32>, prop: vec2<f32>, size: f32, color: vec3<f32>, i: ptr<function, vec3<f32>>) {
   let q = (p - offset) / prop;
   if(length(q) < size) {
      *i = color;
   }
}

fn circleLine(p: vec2<f32>, offset: vec2<f32>, iSize: f32, oSize: f32, color: vec3<f32>, i: ptr<function, vec3<f32>>) {
   let l = length(p - offset);
   if(iSize < l && l < oSize) {
      *i = color;
   }
}

fn arcLine(p: vec2<f32>, offset: vec2<f32>, iSize: f32, oSize: f32,  rad: f32, height: f32, color: vec3<f32>, i: ptr<function, vec3<f32>>) {
   let s = sin(rad);
   let c = cos(rad);
   let q = (p - offset) * mat2x2<f32>(c, -s, s, c);
   let l = length(q);
   if(iSize < l && l < oSize && q.y > height) {
      *i = color;
   }
}

fn rect(p: vec2<f32>, offset: vec2<f32>, size: f32, color: vec3<f32>, i: ptr<function, vec3<f32>>){
   let q = (p - offset) / size;
   if(abs(q.x) < 1.0 && abs(q.y) < 1.0) {
      *i = color;
   }
}




fn sunrise(p: vec2<f32>, i: ptr<function, vec3<f32>>) {
   let t = time.t;
   let f  = atan2(p.y, p.x) + t;
   let fs = sin(f * 10.0);
   *i = mix(lightColor, backColor, fs);
}

@stage(fragment)
fn main(@builtin(position) FragCoord : vec4<f32>) -> @location(0) vec4<f32> {
   let r = resolution.r;
   let t = time.t;
   let p = (FragCoord.xy * 2.0 - r) / min(r.x, r.y);
   let p = vec2<f32>(p.x, -p.y);

   var destColor = vec3<f32>(1.0);

   sunrise(p, &destColor);

   let s = sin(sin(t * 2.0) * 0.75);
   let c = cos(sin(t * 2.0));
   let q = p * mat2x2<f32>(c, -s, s, c);

   circle(q, vec2<f32>(0.0), 0.5, faceColor, &destColor);
   circle(q, vec2<f32>(0.0, -0.05), 0.15, noseColor, &destColor);
   circle(q, vec2<f32>(0.325, -0.05), 0.15, cheekColor, &destColor);
   circle(q, vec2<f32>(-0.325, -0.05), 0.15, cheekColor, &destColor);
   ellipse(q, vec2<f32>(0.15, 0.135), vec2<f32>(0.75, 1.0), 0.075, eyesColor, &destColor);
   ellipse(q, vec2<f32>(-0.15, 0.135), vec2<f32>(0.75, 1.0), 0.075, eyesColor, &destColor);
   circleLine(q, vec2<f32>(0.0), 0.5, 0.525, lineColor, &destColor);
   circleLine(q, vec2<f32>(0.0, -0.05), 0.15, 0.17, lineColor, &destColor);
   arcLine(q, vec2<f32>(0.325, -0.05), 0.15, 0.17, PI * 1.5, 0.0, lineColor, &destColor);
   arcLine(q, vec2<f32>(-0.325, -0.05), 0.15, 0.17, PI * 0.5, 0.0, lineColor, &destColor);
   arcLine(q * vec2<f32>(1.2, 1.0), vec2<f32>(0.19, 0.2), 0.125, 0.145, 0.0, 0.02, lineColor, &destColor);
   arcLine(q * vec2<f32>(1.2, 1.0), vec2<f32>(-0.19, 0.2), 0.125, 0.145, 0.0, 0.02, lineColor, &destColor);
   arcLine(q * vec2<f32>(0.9, 1.0), vec2<f32>(0.0, -0.15), 0.2, 0.22, PI, 0.055, lineColor, &destColor);
   rect(q, vec2<f32>(-0.025, 0.0), 0.035, highlight, &destColor);
   rect(q, vec2<f32>(-0.35, 0.0), 0.035, highlight, &destColor);
   rect(q, vec2<f32>(0.3, 0.0), 0.035, highlight, &destColor);


   return vec4<f32>(destColor, 1.0);
}
