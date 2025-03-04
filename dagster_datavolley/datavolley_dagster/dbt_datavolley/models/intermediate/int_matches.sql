with source as
(
    select
	match_id,
	-- replace(match_id, '-', '') as cleaned_match_id,
	home_team_id,	
	home_team_name,
	away_team_id,
	away_team_name,
	match_date,
	-- CAST((case
	-- 	when date_format is null then strptime(match_date,'%Y-%d-%m')
	-- else
	-- 	strptime(match_date,'%Y-%m-%d')
	-- end) as DATE) as match_date,
	concat(home_team_name, ' vs ', away_team_name) as match_name
    from {{ ref('stg_cleaned_matches')}}
)

select * from source
