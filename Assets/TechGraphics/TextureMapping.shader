Shader "Tectonics/TextureMapping"
{
    Properties
    {
        _TexturePlacement ("Texture sphere location(x,y), rotation(z) and scale(w)", Vector) = (0,0,0,0)
        _Texture ("Plate", 2D) = "" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Cull back
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #define SECURE 1

            #include "UnityCG.cginc"

            sampler2D _Texture;
            float4 _TexturePlacement;

            const static float PI = 3.14159265359;
            const static float HALF_PI = PI/2;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float3x3 rotation(float3 rot)
            {
                float a = rot.x;
                float b = rot.y;
                float c = rot.z;

                return float3x3
                (
                    cos(a)*cos(b), cos(a)*sin(b)*sin(c)-sin(a)*cos(c), cos(a)*sin(b)*cos(c)+sin(a)*sin(c),
                    sin(a)*cos(b), sin(a)*sin(b)*sin(c)+cos(a)*cos(c), sin(a)*sin(b)*cos(c)-cos(a)*sin(c),
                    -sin(b), cos(b)*sin(c), cos(b)*cos(c)
                );
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(i.worldPos.xyz);
                dir = mul(dir, rotation(_TexturePlacement.xyz));
                float2 uv = 0;
                uv.x = atan2(dir.z, dir.x)/(HALF_PI*_TexturePlacement.w);
                uv.y = atan2(dir.y, dir.x)/(HALF_PI*_TexturePlacement.w);
                uv += 0.5;
                fixed4 col = tex2D(_Texture, uv);
                return col;
            }
            ENDCG
        }
    }
}
