shader_type canvas_item;

void fragment() {

float threshold = 0.4;

vec4 col = texture(TEXTURE, UV);
COLOR.a  = smoothstep( threshold, threshold + 0.2, col.a );
//COLOR.rgb = vec3( 1.0, 0.9, 0.9 );// * ( SCREEN_UV.y*2.0 + 0.5 );

}
