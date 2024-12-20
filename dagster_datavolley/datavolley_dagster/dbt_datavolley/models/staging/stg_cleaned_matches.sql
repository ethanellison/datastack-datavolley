with

source as (
    select
        meta->>'$.match_id[0]' as match_id,
        meta->>'$.match[0].date' as match_date, 
        file_meta->>'$[0].preferred_date_format' as date_format,
        meta->'$.teams[0]' as home_team,
        meta->'$.teams[1]' as away_team
    from '/app/out/output.json'
),

cleaned_matches as (
    select
	replace(match_id, '-', '') as cleaned_match_id,
	home_team,
	away_team,
	CAST((case
		when date_format is null then strptime(match_date,'%Y-%d-%m')
	else
		strptime(match_date,'%Y-%m-%d')
	end) as DATE) as match_date,
	concat(home_team->>'team', ' vs ', away_team->>'team') as match_name
    from source
)

select * from cleaned_matches
