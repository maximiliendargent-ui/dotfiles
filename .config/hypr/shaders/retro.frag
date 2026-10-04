#version 300 es
// Mode rétro : lignes de balayage, léger décalage des couleurs et coins assombris (Super + Ctrl + S).
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec2 uv = v_texcoord;
    vec2 d = uv - 0.5;

    // Décalage rouge / bleu, plus marqué vers les bords
    vec2 off = d * 0.0025;
    vec3 c = vec3(texture(tex, uv + off).r, texture(tex, uv).g, texture(tex, uv - off).b);

    // Une ligne sombre tous les 3 pixels
    c *= 0.86 + 0.14 * step(1.0, mod(gl_FragCoord.y, 3.0));

    // Vignette
    c *= 1.0 - 0.55 * dot(d, d);

    fragColor = vec4(c, texture(tex, uv).a);
}
