with source as (
	select * from {{ ref('raw_attacks')}}
)

select
	player_id,
	{{ dbt_utils.pivot(
		'evaluation_desc',
		dbt_utils.get_column_values(ref('raw_attacks'), 'evaluation_desc')
	) }},
	avg(evaluation_num) as eff
from
	source
group by
	player_id
