with 

source as (
	select 
		player_name,
		action_team,
		match_date,
		match_name,
		{{ dbt_utils.pivot(
			'evaluation_desc',
			dbt_utils.get_column_values(ref('raw_attacks'), 'evaluation_desc'),
			agg='sum'
		) }},
		avg(evaluation_num) as eff,
		count(*) as N
	from {{ ref('raw_attacks') }}
	group by 1,2,3,4
),

attacking_metrics as (
	select
		*,
		("Winning attack" / "N") as Kill_pct,
		("Blocked" / "N") as Blocked_pct,
		("Error" / "N") as Error_pct
	from source
)

select * from attacking_metrics
