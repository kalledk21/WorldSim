Shader "Tectonics/RegularSphere"
{
    Properties
    {
        _LineWidth ("Line Width", Float) = 0.01
        _PointWidth ("Point Width", Float) = 0.03
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

            struct arrayData
            {
                float data[8];
            };

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
            float _LineWidth;
            float _PointWidth;

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

            // fixed4 randomCol(int index, float minChange)
            // {
            //     if(minChange < 0.01)
            //          return fixed4(0,0,0,1);
            //     float accumulation = frac(index*golden);
            //     float3 HSV = float3(accumulation, 0.75, 0.6-accumulation*0.2);
            //     return fixed4(HSVtoRGB(HSV),1);
            // }
            
            fixed4 randomColArray(int index, float minChange[8])
            {
                if(minChange[0] < _PointWidth && minChange[1] < _PointWidth)
                     return 1;
                if(minChange[0] < _LineWidth)
                     return fixed4(0,0,0,1);
                float accumulation = frac(index*golden);
                float3 HSV = float3(accumulation, 0.85, 0.5-accumulation*0.2);
                return fixed4(HSVtoRGB(HSV),1);
            }

            static const int POINT_AMOUNT = 8;
            static const float MIN_DISTANCE = 0.001;
            static const float SPHERERADIUS = 0.49f;
            
            static const float3 dirs[8] = {float3(3,6,2), float3(-3,-6,2), float3(-7,5,-2), float3(6,-3,-2), float3(-3,2,19), float3(0,1,0), float3(7,2,0), float3(0,0,-4)};

            float SphereArcDist(float3 a, float3 b)
            {
#ifdef SECURE
                a = normalize(a);
                b = normalize(b);
#endif
                return acos(dot(a,b));
            }
            
            arrayData SortArray(float NumArray[POINT_AMOUNT])
            {
                for (int i = 0; i < POINT_AMOUNT - 1; i++)
                {
                    float smallestVal = i;
                    for (int j = i + 1; j < POINT_AMOUNT; j++)
                    {
                        if (NumArray[j] < NumArray[smallestVal])
                        {
                            smallestVal = j;
                        }
                    }
                    float tempVar = NumArray[smallestVal];
                    NumArray[smallestVal] = NumArray[i];
                    NumArray[i] = tempVar;
                }
                arrayData data;
                data.data = NumArray;
                return data;
            }


            fixed4 shadeSphere(float3 position)
            {
                float minDist = 99;
                int index = 0;
                for (int i = 0; i < POINT_AMOUNT; i++)
                {
                    float dist = SphereArcDist(position, dirs[i]);
                    if(dist < minDist)
                    {
                        index = i;
                        minDist = dist;
                    }

                }
                float changes[POINT_AMOUNT];
                float minChange = 99;
                for (int k = 0; k < 8; k++)
                {
                    changes[k] = 99;
                    if(k != index)
                    {
                        float otherDist = SphereArcDist(position, dirs[k]);
                        float change = abs(minDist - otherDist);
                        changes[k] = change;
                        if(change < minChange)
                        {
                            minChange = change;
                        }
                    }

                }
                arrayData data = SortArray(changes);
                return randomColArray(index+19, data.data);
                //return fixed4(position / SPHERERADIUS * 0.5 + 0.5, 1);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                return shadeSphere(i.worldPos);
            }
            ENDCG
        }
    }
}
