use std::{env, fs, mem, time::Instant};

use naga::{FastHashMap, ShaderStage};
use wgpu::{
    util::DeviceExt, Backends, DeviceDescriptor, Instance, SurfaceConfiguration, TextureUsages,
    VertexBufferLayout,
};
use winit::{
    dpi::PhysicalSize,
    event::*,
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

#[repr(C)]
#[derive(Debug, Copy, Clone, bytemuck::Pod, bytemuck::Zeroable, Default)]
struct TimeUniform {
    t: f32,
}

impl TimeUniform {
    fn layout_desc() -> wgpu::BindGroupLayoutDescriptor<'static> {
        static ENTRY: [wgpu::BindGroupLayoutEntry; 1] = [wgpu::BindGroupLayoutEntry {
            binding: 0,
            visibility: wgpu::ShaderStages::FRAGMENT,
            ty: wgpu::BindingType::Buffer {
                ty: wgpu::BufferBindingType::Uniform,
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        }];
        wgpu::BindGroupLayoutDescriptor {
            label: Some("time_bind_group_layout"),
            entries: &ENTRY,
        }
    }
}

#[repr(C)]
#[derive(Debug, Copy, Clone, bytemuck::Pod, bytemuck::Zeroable, Default)]
struct ResolutionUniform {
    r: [f32; 2],
}

impl ResolutionUniform {
    fn layout_desc() -> wgpu::BindGroupLayoutDescriptor<'static> {
        static ENTRY: [wgpu::BindGroupLayoutEntry; 1] = [wgpu::BindGroupLayoutEntry {
            binding: 0,
            visibility: wgpu::ShaderStages::FRAGMENT,
            ty: wgpu::BindingType::Buffer {
                ty: wgpu::BufferBindingType::Uniform,
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        }];
        wgpu::BindGroupLayoutDescriptor {
            label: Some("resolution_bind_group_layout"),
            entries: &ENTRY,
        }
    }
}

fn main() {
    env_logger::init();
    let shader_source = env::args().nth(1).unwrap();

    let shader = if shader_source.ends_with(".frag") {
        let source = fs::read_to_string(shader_source).unwrap();
        wgpu::ShaderSource::Glsl {
            shader: source.into(),
            stage: ShaderStage::Fragment,
            /// Defines to unlock configured shader features
            defines: FastHashMap::default(),
        }
    } else if shader_source.ends_with(".wgsl") {
        let source = fs::read_to_string(shader_source).unwrap();
        wgpu::ShaderSource::Wgsl(source.into())
    } else {
        panic!("unknown shader type {}", shader_source)
    };

    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_inner_size(PhysicalSize::new(512, 512))
        .build(&event_loop)
        .unwrap();
    let instance = Instance::new(Backends::all());
    let surface = unsafe { instance.create_surface(&window) };
    let adapter = instance
        .enumerate_adapters(wgpu::Backends::all())
        .filter(|adapter| surface.get_preferred_format(&adapter).is_some())
        .next()
        .unwrap();
    let (device, queue) = pollster::block_on(async {
        adapter
            .request_device(
                &DeviceDescriptor {
                    features: wgpu::Features::empty(),
                    limits: wgpu::Limits::default(),
                    label: None,
                },
                None,
            )
            .await
            .unwrap()
    });
    let config = SurfaceConfiguration {
        usage: TextureUsages::RENDER_ATTACHMENT,
        format: surface.get_preferred_format(&adapter).unwrap(),
        width: 512,
        height: 512,
        present_mode: wgpu::PresentMode::Mailbox,
    };
    surface.configure(&device, &config);

    let v_shader = device.create_shader_module(&wgpu::ShaderModuleDescriptor {
        label: Some("Vertex Shader"),
        source: wgpu::ShaderSource::Glsl {
            shader: "layout(location=0) in vec3 p;void main(){gl_Position=vec4(p,1.);}".into(),
            stage: ShaderStage::Vertex,
            /// Defines to unlock configured shader features
            defines: FastHashMap::default(),
        },
    });

    let f_shader = device.create_shader_module(&wgpu::ShaderModuleDescriptor {
        label: Some("Fragment Shader"),
        source: shader,
    });

    let t = TimeUniform { t: 0.0 };
    let time_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Time Buffer"),
        contents: bytemuck::cast_slice(&[t]),
        usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    });
    let time_bind_group_layout = device.create_bind_group_layout(&TimeUniform::layout_desc());
    let time_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
        label: Some("Time BindGroup"),
        layout: &&time_bind_group_layout,
        entries: &[wgpu::BindGroupEntry {
            binding: 0,
            resource: time_buffer.as_entire_binding(),
        }],
    });

    let r = ResolutionUniform { r: [512.0, 512.0] };
    let resolution_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Resolution Buffer"),
        contents: bytemuck::cast_slice(&[r]),
        usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    });
    let resolution_bind_group_layout =
        device.create_bind_group_layout(&ResolutionUniform::layout_desc());
    let resolution_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
        label: Some("Resolution BindGroup"),
        layout: &&resolution_bind_group_layout,
        entries: &[wgpu::BindGroupEntry {
            binding: 0,
            resource: resolution_buffer.as_entire_binding(),
        }],
    });

    let vertex: [f32; 12] = [
        -1.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, 1.0, 0.0, 1.0, -1.0, 0.0,
    ];

    let indices: &[u16] = &[0, 1, 2, 1, 3, 2];
    let vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Vertex Buffer"),
        contents: bytemuck::cast_slice(&vertex),
        usage: wgpu::BufferUsages::VERTEX,
    });
    let index_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Index Buffer"),
        contents: bytemuck::cast_slice(indices),
        usage: wgpu::BufferUsages::INDEX,
    });
    let layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: Some("Render Pipeline Layout"),
        bind_group_layouts: &[&time_bind_group_layout, &resolution_bind_group_layout],
        push_constant_ranges: &[],
    });
    let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("Render Pipeline"),
        layout: Some(&layout),
        vertex: wgpu::VertexState {
            module: &v_shader,
            entry_point: "main",
            buffers: &[VertexBufferLayout {
                array_stride: (mem::size_of::<f32>() * 3) as wgpu::BufferAddress,
                step_mode: wgpu::VertexStepMode::Vertex,
                attributes: &[wgpu::VertexAttribute {
                    offset: 0,
                    shader_location: 0,
                    format: wgpu::VertexFormat::Float32x3,
                }],
            }],
        },
        fragment: Some(wgpu::FragmentState {
            module: &f_shader,
            entry_point: "main",
            targets: &[wgpu::ColorTargetState {
                format: config.format,
                blend: Some(wgpu::BlendState {
                    alpha: wgpu::BlendComponent::REPLACE,
                    color: wgpu::BlendComponent::REPLACE,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            }],
        }),
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode: Some(wgpu::Face::Back),
            // Setting this to anything other than Fill requires Features::NON_FILL_POLYGON_MODE
            polygon_mode: wgpu::PolygonMode::Fill,
            // Requires Features::DEPTH_CLIP_CONTROL
            unclipped_depth: false,
            // Requires Features::CONSERVATIVE_RASTERIZATION
            conservative: false,
        },
        depth_stencil: None,
        multisample: wgpu::MultisampleState {
            count: 1,
            mask: !0,
            alpha_to_coverage_enabled: false,
        },
        multiview: None,
    });
    let start = Instant::now();
    event_loop.run(move |event, _, control_flow| match event {
        Event::WindowEvent {
            ref event,
            window_id,
        } if window_id == window.id() => match event {
            WindowEvent::CloseRequested
            | WindowEvent::KeyboardInput {
                input:
                    KeyboardInput {
                        state: ElementState::Pressed,
                        virtual_keycode: Some(VirtualKeyCode::Escape),
                        ..
                    },
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => {}
        },
        Event::RedrawRequested(window_id) if window_id == window.id() => {
            let now = Instant::now();
            let t = ((now - start).as_millis() as f32) / 1000.0;
            queue.write_buffer(&time_buffer, 0, bytemuck::cast_slice(&[TimeUniform { t }]));
            let output = surface.get_current_texture().unwrap();
            let view = output
                .texture
                .create_view(&wgpu::TextureViewDescriptor::default());
            let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
                label: Some("Render Encoder"),
            });
            {
                let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("Render Pass"),
                    color_attachments: &[wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color {
                                r: 0.0,
                                g: 0.0,
                                b: 0.0,
                                a: 1.0,
                            }),
                            store: true,
                        },
                    }],
                    depth_stencil_attachment: None,
                });

                render_pass.set_pipeline(&render_pipeline);
                render_pass.set_bind_group(0, &time_bind_group, &[]);
                render_pass.set_bind_group(1, &resolution_bind_group, &[]);
                render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
                render_pass.set_index_buffer(index_buffer.slice(..), wgpu::IndexFormat::Uint16);
                render_pass.draw_indexed(0..(indices.len() as u32), 0, 0..1);
            }

            // submit will accept anything that implements IntoIter
            queue.submit(std::iter::once(encoder.finish()));
            output.present();
        }

        Event::MainEventsCleared => {
            // RedrawRequested will only trigger once, unless we manually
            // request it.
            window.request_redraw()
        }
        _ => {}
    });
}
