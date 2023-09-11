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

            float SphereArcDist(float3 a, float3 b)
            {
#ifdef SECURE
                a = normalize(a);
                b = normalize(b);
#endif
                return acos(dot(a,b));
            }

            fixed4 uvVisualizer(float2 uv)
            {
                return frac(fixed4(uv.x, uv.y, .999,1));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(i.worldPos.xyz);
                float2 uv = acos(-dir.y)/(HALF_PI/_TexturePlacement.w);
                uv.x = atan2(dir.z , dir.x)/(HALF_PI/_TexturePlacement.w);
                uv+=0.5/_TexturePlacement.w;
                fixed4 col = tex2D(_Texture, uv);
                return col;
            }
            ENDCG
        }
    }
}
