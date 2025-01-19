with source as (
	select * from {{ ref('stg_cleaned_actions')}} where skill = 'Block'
),

blocks_grouped_by_evaluation as (
	select 
		player_key,
		match_id,
		in_out_system,
		rotation,
		block_type,
		block_num as block_type_num,
		attack_phase,
		point_phase,
		{{ dbt_utils.pivot('evaluation_desc',dbt_utils.get_column_values(table=ref('stg_cleaned_actions'), column='evaluation_desc', where="skill = 'Block'"),agg='sum') }},
		count(*) as N
	from
		source
	{{ dbt_utils.group_by(n=8)}}
)

select * from blocks_grouped_by_evaluation
