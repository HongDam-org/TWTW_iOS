uniform sampler2D u_diffuse_texture;
varying vec2 v_texcoord;

void main()
{
//    gl_FragColor = texture2D( u_diffuse_texture, v_texcoord );
    gl_FragColor = texture2D( u_diffuse_texture, v_texcoord );
}

