with

source as (
	select * from {{ ref('int_serves') }}
)

-- speeds_joined_with_players as (
-- 	select
-- 		match_id,
-- 		p.player_key,
-- 		avg(s.speed) as avg_speed,
-- 		sum(s.total) as sum_total
-- 	from {{ source('raw', 'oci_serve_speeds')}} s
-- 	inner join {{ ref('int_players')}} p
-- 	on s.code = p.player_id
-- 	group by 1,2
-- )

-- select
-- 	source.*,
-- 	--{{ dbt_utils.generate_surrogate_key(['source.player_id','source.match_id']) }} as player_match_sk,
-- 	s.avg_speed as avg_speed
-- 	--speeds.sum_total as total,
-- 	from source
-- 	left join speeds_joined_with_players s
-- 	on source.match_id = s.match_id and source.player_key = s.player_key

select* from source