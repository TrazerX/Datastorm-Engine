Texture2D Texture: register(t0);
sampler TextureSampler: register(s0);

Texture2D TextureSpecular: register(t1);
sampler TextureSpecularSampler: register(s1);

Texture2D Clouds: register(t2);
sampler CloudsSampler: register(s2);

struct PS_INPUT
{
	float4 position: SV_POSITION;
	float2 texcoord: TEXCOORD0;
	float3 normal: NORMAL0;
	float3 direction_to_camera: TEXCOORD1;
};

cbuffer constant: register(b0)
{
	row_major float4x4 m_world;
	row_major float4x4 m_view;
	row_major float4x4 m_proj;
	float4 m_light_direction;
	float4 m_camera_position;
	float m_time;
};

float4 psmain(PS_INPUT input) : SV_TARGET
{
	float4 texture_color = Texture.Sample(TextureSampler, 1.0 - input.texcoord + float2(m_time / 200,0));
	float4 texture_specular = TextureSpecular.Sample(TextureSpecularSampler, 1 - input.texcoord).r;
	float4 clouds = Clouds.Sample(CloudsSampler, 1 - input.texcoord + float2(m_time/100,0)).r;

	//AMBIENT LIGHT
	float ka = 1.5;
	float3 ia = float3(0.09, 0.082, 0.082);
	ia *= texture_color.rgb + clouds;

	float3 ambient_light = ka * ia;

	//DIFFUSE LIGHT
	float kd = 0.7;
	float3 id = float3(1.0, 1.0, 1.0);
	float amount_diffuse_light = max(0.0, dot(m_light_direction.xyz, input.normal));

	id *= texture_color.rgb + clouds;

	float3 diffuse_light = kd * amount_diffuse_light * id;

	//SPECULAR LIGHT
	float ks = texture_specular;
	float3 is = float3(1.0, 1.0, 1.0);
	float3 reflected_light = reflect(m_light_direction.xyz, input.normal);
	float shininess = 30.0;
	float amount_specular_light = pow(max(0.0, dot(reflected_light, input.direction_to_camera)), shininess);

	float3 specular_light = ks * amount_specular_light * is;

	float3 final_light = ambient_light + diffuse_light + specular_light;

	return float4(final_light,1.0);
}