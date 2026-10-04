#version 300 es
// Mode lecture : tout l'écran en niveaux de gris (Super + Ctrl + S).
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float g = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(vec3(g), c.a);
}
