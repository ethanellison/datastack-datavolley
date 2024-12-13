with

source as (
	select distinct
		home_team.team_id,
		home_team.team
	from {{ ref('raw_matches') }}
)

select * from source
