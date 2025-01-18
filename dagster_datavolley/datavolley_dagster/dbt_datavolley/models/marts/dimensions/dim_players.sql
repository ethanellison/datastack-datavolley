with source as (
	select
		team_id,
		player_key,
		-- player_id,
		number as player_number,
		player_name,
		firstname as player_firstname,
		lastname as player_lastername,
		role as player_role

		from {{ ref('int_players')}}
		where player_row_n = 1
)

select * from source
