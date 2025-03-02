
with

home_teams as (
	select distinct
		home_team_id as team_id,
		home_team_name as team_name
	from {{ ref('stg_cleaned_matches') }}
),

away_teams as (
	select distinct
		away_team_id as team_id,
		away_team_name as team_name
	from {{ ref('stg_cleaned_matches') }}

)

select * from home_teams
union
select * from away_teams
