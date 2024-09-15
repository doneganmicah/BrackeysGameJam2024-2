shader_type canvas_item;
uniform vec4 color : source_color;
uniform float health;

void fragment() {
	// Get the rgb vec 3 from the input color
	vec3 rgb = color.rgb;
	
	// If UV.x is less than health then do color else black
	COLOR.rgb = UV.x < health ? rgb : rgb * vec3(0.0, 0.0, 0.0);
}