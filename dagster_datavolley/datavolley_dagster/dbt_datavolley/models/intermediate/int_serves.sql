
with 
source as (
	select 
		player_id,
		action_team,
		match_id,
		match_date,
		{{ dbt_utils.pivot(
			'evaluation_desc',
			dbt_utils.get_column_values(table=ref('stg_cleaned_actions'), column='evaluation_desc', where="skill = 'Serve'"),
			agg='sum'
		) }},
		count(*) as N,
		avg(case when action_team = point_won_by_team then 1 else 0 end) as bp_pct
	from {{ ref('stg_cleaned_actions') }}
	where skill = 'Serve'
	group by 1,2,3,4
),

speeds as (
	select
		match_id,
		code,
		avg(speed) as avg_speed,
		sum(total) as sum_total
	from {{ source('raw', 'oci_serve_speeds')}}
	group by 1,2
)

select
	source.*,
	{{ dbt_utils.generate_surrogate_key(['source.player_id','source.match_id']) }} as player_match_sk,
	speeds.avg_speed as speed,
	speeds.sum_total as total,
	from source
	left join speeds
	on source.match_id = speeds.match_id and source.player_id = speeds.code
