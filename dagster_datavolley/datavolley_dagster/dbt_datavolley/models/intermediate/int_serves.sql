
with 

source as (
	select * from {{ ref('stg_cleaned_actions' )}} where skill = 'Serve'
),

serves_by_type_result as (
	select 
		player_key,
		match_id,
		player_id,
		skill_type,
		{{ dbt_utils.pivot(
			'evaluation_desc',
			dbt_utils.get_column_values(table=ref('stg_cleaned_actions'), column='evaluation_desc', where="skill = 'Serve'"),
			agg='sum'
		) }},
		avg(case when action_team = point_won_by_team then 1 else 0 end) as breakpoint_pct,
		count(*) as N,
	from
		source
	{{ dbt_utils.group_by(n=4)}}
)

select * from serves_by_type_result
