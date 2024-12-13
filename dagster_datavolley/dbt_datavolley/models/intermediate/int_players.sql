
with 

players as (
    select 
		{{ dbt_utils.star(from=source('raw_data', 'raw_players'), except=['number'])}},
		number::double as number
    from 
	{{ source('raw_data', 'raw_players') }}
),

teams as (
	select distinct
		team_id,
		team,
		player_id,
		player_name
	from 
		{{ source('raw_data', 'raw_augmented_plays')}}
),

player_teams_joined as (
	select distinct
		p.*,
		t.team_id,
		t.player_name
	from
		players p
	left join teams t 
	on p.player_id = t.player_id
),

players_with_key as (

select 
	{{ dbt_utils.generate_surrogate_key(['team_id','number']) }} as player_key,
	team_id, 
	player_id, 
	number, 
	firstname,
	lastname,
	player_name,
	role 
from player_teams_joined 
where team_id is not null
order by 1,3

),

players_removed_duplicates as (
	select
		*,
		row_number() over (partition by player_key order by player_id desc) as player_row_n
	from
		players_with_key
)

select * from players_removed_duplicates where player_row_n = 1
