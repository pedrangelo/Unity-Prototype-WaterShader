Shader "Custom/Water" {
    Properties {
        _LowColor ("Low Color", Color) = (0,0,1,1)
        _MidColor ("Mid Color", Color) = (0,0.5,1,1)
        _HighColor ("High Color", Color) = (1,1,1,1)
        _WaveAmplitude1 ("Wave Amplitude 1", float) = 0.5
        _WaveFrequency1 ("Wave Frequency 1", float) = 1.0
        _WavePhase1 ("Wave Phase 1", float) = 0.0
        _WaveAmplitude2 ("Wave Amplitude 2", float) = 0.3
        _WaveFrequency2 ("Wave Frequency 2", float) = 2.0
        _WavePhase2 ("Wave Phase 2", float) = 0.5
        _WaveSpeed ("Wave Speed", float) = 1.0
        _Transparency ("Transparency", float) = 0.5
        _Reflectivity ("Reflectivity", float) = 0.5
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", float) = 0.1
        _AmplitudeVariation ("Amplitude Variation", float) = 0.2
        _WaveDirection1 ("Wave Direction 1 (Degrees)", float) = 0.0
        _WaveDirection2 ("Wave Direction 2 (Degrees)", float) = 90.0
    }
    SubShader {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha // Enable transparency

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float waveHeight : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            float _WaveAmplitude1, _WaveFrequency1, _WavePhase1;
            float _WaveAmplitude2, _WaveFrequency2, _WavePhase2;
            float _WaveSpeed;
            float4 _LowColor, _MidColor, _HighColor;
            float _Transparency, _Reflectivity;
            sampler2D _NoiseTex;
            float _NoiseScale, _AmplitudeVariation;
            float _WaveDirection1, _WaveDirection2;
            

            v2f vert (appdata v) {
                v2f o;
                float3 worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                float wavePhase = _WaveSpeed * _Time.y;
                float waveHeight = 0.0;
            
                // Direction angles for each wave component (in radians)
                float angle1 = _WaveDirection1 * UNITY_PI / 180.0; // Convert degrees to radians
                float angle2 = _WaveDirection2 * UNITY_PI / 180.0;
            
                // Calculate directional vectors for each wave component
                float2 dir1 = float2(cos(angle1), sin(angle1));
                float2 dir2 = float2(cos(angle2), sin(angle2));
            
                // Adjust wave calculations to include direction
                waveHeight += _WaveAmplitude1 * sin(dot(worldPosition.xz, dir1) * _WaveFrequency1 + wavePhase + _WavePhase1);
                waveHeight += _WaveAmplitude2 * sin(dot(worldPosition.xz, dir2) * _WaveFrequency2 + wavePhase + _WavePhase2);
            
                // Adding noise for variation
                float4 noiseSample = tex2Dlod(_NoiseTex, float4(worldPosition.xz * _NoiseScale, 0, 0));
                float noiseValue = noiseSample.r;
                waveHeight *= (1.0 + noiseValue * _AmplitudeVariation);
            
                v.vertex.y += waveHeight;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.waveHeight = waveHeight;
                o.worldPos = worldPosition;
                o.worldNormal = normalize(mul(float4(0,1,0,0), unity_ObjectToWorld).xyz);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float normalizedHeight = clamp(i.waveHeight / (max(_WaveAmplitude1, _WaveAmplitude2) + 1.0) * 0.5, 0, 1);
                fixed4 color = lerp(lerp(_LowColor, _MidColor, normalizedHeight), _HighColor, normalizedHeight);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float reflectionFactor = dot(viewDir, i.worldNormal) * _Reflectivity;
                color.rgb += reflectionFactor * reflectionFactor; // Enhance reflection based on angle
                color.a *= _Transparency;
                return color;
            }
            ENDCG
        }
    }
}
