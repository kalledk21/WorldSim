Shader "Tectonics/SDFSphere"
{
    Properties
    {
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

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            static const float golden = 0.618033988749895;

            float3 HUEtoRGB(in float H)
            {
                float R = abs(H * 6 - 3) - 1;
                float G = 2 - abs(H * 6 - 2);
                float B = 2 - abs(H * 6 - 4);
                return saturate(float3(R,G,B));
            }
            float3 HSVtoRGB(in float3 HSV)
            {
                float3 RGB = HUEtoRGB(HSV.x);
                return ((RGB - 1) * HSV.y + 1) * HSV.z;
            }

            fixed4 randomCol(int index, float minChange)
            {
                if(minChange < 0.01)
                     return fixed4(0,0,0,1);
                float accumulation = frac(index*golden);
                float3 HSV = float3(accumulation, 0.75, 1-accumulation*0.4);
                return fixed4(HSVtoRGB(HSV),1);
            }

            static const int STEPS = 32;
            static const float MIN_DISTANCE = 0.001;
            static const float SPHERERADIUS = 0.45f;
            
            static const float3 dirs[8] = {float3(3,6,2), float3(-3,-6,2), float3(-7,5,-2), float3(6,-3,-2), float3(-3,2,19), float3(0,1,0), float3(7,2,0), float3(0,0,-4)};

            float SphereArcDist(float3 a, float3 b)
            {
#ifdef SECURE
                a = normalize(a);
                b = normalize(b);
#endif
                return acos(dot(a,b));
            }

            fixed4 shadeSphere(float3 position)
            {
                float minDist = 99;
                int index = 0;
                for (int i = 0; i < 8; i++)
                {
                    float dist = SphereArcDist(position, dirs[i]);
                    if(dist < minDist)
                    {
                        index = i;
                        minDist = dist;
                    }

                }
                
                float minChange = 99;
                for (int k = 0; k < 8; k++)
                {
                    if(k != index)
                    {
                        float otherDist = SphereArcDist(position, dirs[k]);
                        float change = abs(minDist - otherDist);
                        if(change < minChange)
                        {
                            minChange = change;
                        }
                    }

                }
                return randomCol(index, minChange);
                //return fixed4(position / SPHERERADIUS * 0.5 + 0.5, 1);
            }

            float sphereDistance (float3 p)
            {
                return distance(p,0) - SPHERERADIUS;
            }

            fixed4 raymarch (float3 position, float3 direction)
            {
                for (int i = 0; i < STEPS; i++)
                {
                    float distance = sphereDistance(position);
                    if (distance < MIN_DISTANCE)
                    {
                        return shadeSphere(position);
                    }
                    position += distance * direction;
                }
                discard;
                return 0;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPosition = i.worldPos;
                float3 viewDirection = normalize(i.worldPos - mul(unity_WorldToObject, _WorldSpaceCameraPos));
                return raymarch (worldPosition, viewDirection);
            }
            ENDCG
        }
    }
}
