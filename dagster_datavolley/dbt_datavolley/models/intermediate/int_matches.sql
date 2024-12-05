with

source as (
	select distinct
		match_id,
		home_team_id,
		visiting_team_id
	from {{ source('main','augmented_plays')}}
)

select * from source
