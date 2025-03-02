
with source as (
	select 
		cleaned_match_id as match_id,
		home_team_id,
		home_team_name,
		away_team_id,
		away_team_name,
		match_name,
		match_date

		from {{ ref('int_matches')}}
)

select * from source
