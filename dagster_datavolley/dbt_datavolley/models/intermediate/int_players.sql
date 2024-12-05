
with 

players as (
    select * from {{ source('main', 'players') }}
),

teams as (
	select distinct
		team_id,
		team,
		player_id,
		player_name
	from 
		{{ source('main', 'augmented_plays')}}
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
)

select team_id, player_id, number, firstname, lastname, player_name, role from player_teams_joined where team_id is not null order by 1,3
-- select * from {{ source('main','players')}}
