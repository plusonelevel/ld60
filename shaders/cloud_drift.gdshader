shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;

// Cloud texture (PNG with alpha works best)
uniform sampler2D cloud_tex : source_color, filter_linear_mipmap, repeat_enable;

// Slow constant drift direction and speed (UV units per second)
uniform vec2 drift_dir = vec2(1.0, 0.2);
uniform float drift_speed = 0.01;

// Gentle "breathing" wobble so the cloud subtly shifts shape
uniform float wobble_amount = 0.004;
uniform float wobble_speed = 0.4;

uniform vec4 tint : source_color = vec4(1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = UV;

	// Slow drift
	uv += normalize(drift_dir) * drift_speed * TIME;

	// Small wavy distortion that varies across the cloud
	uv.x += sin(UV.y * 6.0 + TIME * wobble_speed) * wobble_amount;
	uv.y += cos(UV.x * 5.0 + TIME * wobble_speed * 0.8) * wobble_amount;

	vec4 c = texture(cloud_tex, uv) * tint;

	ALBEDO = c.rgb;
	ALPHA = c.a * opacity;
}
