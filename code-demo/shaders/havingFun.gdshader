shader_type canvas_item;

uniform vec4 block_color : source_color; // Solid block color
uniform float block_width : hint_range(0.0, 1.0); // Block width (0 to 1, relative to the canvas)
uniform float triangle_size_pixels : hint_range(1.0, 100.0); // Frequency of the triangle pattern along the border
uniform float wave_offset : hint_range(0.0, 1.0); // Offset for the wave period (0 to 1, relative to the period)

void fragment() {
	float triangle_size_uv = triangle_size_pixels * SCREEN_PIXEL_SIZE.y;
	
    // Check if the pixel is inside the solid block area
    if (UV.x < block_width) {
        // Set the pixel to the block color
        COLOR = block_color;
    } else {
        // Calculate the triangle pattern along the right edge
        float distance_from_edge = UV.x - block_width;
        
        // Calculate the Y position within the triangle pattern cycle
        float vertical_cycle = mod(UV.y + wave_offset * triangle_size_uv, triangle_size_uv);
        
        // Map the vertical position to the triangle's shape
        float triangle_base = abs(triangle_size_uv / 2.0 - vertical_cycle); // Creates a triangular wave

        // Check if the fragment is within the triangle area
        if (distance_from_edge < triangle_base) {
            COLOR = block_color; // Color inside the triangle border
        } else {
            discard; // Transparent outside the triangle
        }
    }
}
