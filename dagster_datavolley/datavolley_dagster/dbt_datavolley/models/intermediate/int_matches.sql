with source as
(
    select
	replace(match_id, '-', '') as cleaned_match_id,
	home_team->>'$.team_id' as home_team_id,	
	home_team->>'$.team' as home_team,
	away_team->>'$.team_id' as away_team_id,
	away_team->>'$.team' as away_team,
	CAST((case
		when date_format is null then strptime(match_date,'%Y-%d-%m')
	else
		strptime(match_date,'%Y-%m-%d')
	end) as DATE) as match_date,
	concat(home_team->>'team', ' vs ', away_team->>'team') as match_name
    from {{ ref('stg_cleaned_matches')}}
)

select * from source
