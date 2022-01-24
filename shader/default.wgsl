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

fn mod(d: f32, m: f32) -> f32 {
    return d - floor(d/m);
}

fn hsv(h: f32, s: f32, v: f32) -> vec3<f32> {
    let t = vec4<f32>(1.0, 2.0/ 3.0, 1.0 / 3.0, 3.0);
    let p = abs(fract(vec3<f32>(h) + t.xyz) * 6.0 - vec3<f32>(t.w));
    return v * mix(vec3<f32>(t.x), clamp(p - vec3<f32>(t.x), vec3<f32>(0.0), vec3<f32>(1.0)), s);
}

[[stage(fragment)]]
fn main([[builtin(position)]] FragCoord : vec4<f32>) -> [[location(0)]] vec4<f32> {
    let r = resolution.r;
    let p = (FragCoord.xy * 2.0 - r) / min(r.x, r.y);
    var j = 0;
    let x = vec2<f32>(-0.345, 0.654);
    let y = vec2<f32>(time.t * 0.005, 0.0);
    var z = p;
    for(var i: i32 = 0; i < 360; i = i + 1) {
        j = j + 1;
        if(length(z) > 2.0){break;}
        z = vec2<f32>(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + x + y;
    }
    let h = abs(mod(time.t * 15.0 - f32(j), 360.0) / 360.0);
    return vec4<f32>(hsv(h, 1.0, 1.0), 1.0);
}