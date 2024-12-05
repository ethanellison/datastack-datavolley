with

source as (
	select distinct
		team_id,
		team
	from {{ source('main','augmented_plays')}}
)

select * from source
