shader_type canvas_item;

uniform float scroll_speed = 0.5;
uniform float glowing = 5.0;

void fragment() {
	vec4 in_tex = texture(TEXTURE, vec2(UV.x-TIME * scroll_speed, UV.y));
	COLOR = vec4(in_tex.r * glowing, in_tex.g * glowing, 0, in_tex.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
