Texture2D TextureColor: register(t0);
sampler TextureColorSampler: register(s0);


struct PS_INPUT
{
	float4 position: SV_POSITION;
	float2 texcoord: TEXCOORD0;
	float3 normal: NORMAL0;
	float3 world_pos: TEXCOORD1;
};

cbuffer constant: register(b0)
{
	row_major float4x4 m_world;
	row_major float4x4 m_view;
	row_major float4x4 m_proj;
	float4 m_light_direction;
	float4 m_camera_position;
	float4 m_light_position;
	float m_light_radius;
	float m_time;
};

float4 psmain(PS_INPUT input) : SV_TARGET
{
	float4 tex_color = TextureColor.Sample(TextureColorSampler, (1.0 - input.texcoord));


	//AMBIENT LIGHT
	float ka = 1.5;
	float3 ia = float3(0.09, 0.082, 0.082);
	ia *= (tex_color.rgb);

	float3 ambient_light = ka * ia;

	//DIFFUSE LIGHT
	float kd = 0.7;
	float3 light_dir = normalize(m_light_position.xyz - input.world_pos.xyz);
	float distance_light_object = length(m_light_position.xyz - input.world_pos.xyz);

	float fade_area = max(0,distance_light_object - m_light_radius);

	float constant_func = 1.0;
	float linear_func = 1.0;
	float quadratic_func = 1.0;


	float attenuation = constant_func + linear_func * fade_area + quadratic_func * fade_area * fade_area;



	float amount_diffuse_light = max(0,dot(light_dir.xyz, input.normal));
	float3 id = float3(1,1,1);
	id *= (tex_color.rgb);

	float3 diffuse_light = (kd * id * amount_diffuse_light) / attenuation;

	//SPECULAR LIGHT
	float ks = 1.0;
	float3 direction_to_camera = normalize(input.world_pos.xyz - m_camera_position.xyz);
	float3 is = float3(1.0, 1.0, 1.0);
	float3 reflected_light = reflect(light_dir.xyz, input.normal);
	float shininess = 30.0;
	float amount_specular_light = pow(max(0.0, dot(reflected_light, direction_to_camera)), shininess);




	float3 specular_light = (ks * amount_specular_light * is) / attenuation;

	float3 final_light = ambient_light + diffuse_light + specular_light;

	return float4(final_light,1.0);
}