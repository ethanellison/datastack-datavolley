with 

source as (
	select * from {{ source('raw', 'raw_output') }}
),

attack_codes as (
	select distinct
		unnest(meta.attacks)->>'code' as attack_code,
		unnest(meta.attacks)->>'attacker_position' as attack_position,
		unnest(meta.attacks)->>'side' as attack_side,
		unnest(meta.attacks)->>'type' as attack_type,
		unnest(meta.attacks)->>'description' as attack_code_desc,
		unnest(meta.attacks)->>'set_type' as attack_set_type
	from source
)

select * from attack_codes
