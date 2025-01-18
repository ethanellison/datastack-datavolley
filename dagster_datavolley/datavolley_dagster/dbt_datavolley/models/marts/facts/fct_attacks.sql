with source as (
	select * from {{ ref('stg_cleaned_actions')}} where skill = 'Attack'
),

attacks_grouped_by_evaluation as (
	select 
		player_key,
		match_id,
		in_out_system,
		rotation,
		attack_code,
		attack_phase,
		point_phase,
		{{ dbt_utils.pivot('evaluation_desc',dbt_utils.get_column_values(table=ref('stg_cleaned_actions'), column='evaluation_desc', where="skill = 'Attack'"),agg='sum') }},
		count(*) as N
	from
		source
	{{ dbt_utils.group_by(n=7)}}
)

select * from attacks_grouped_by_evaluation
