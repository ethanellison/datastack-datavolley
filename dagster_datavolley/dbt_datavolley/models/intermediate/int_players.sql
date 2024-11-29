
with source as (
    select * from {{ source('raw','players') }}
),

player_teams_joined as (
	select distinct
		team_id,
		player_id
	from
		{{ source('raw', 'plays')}}
)

select * from source
