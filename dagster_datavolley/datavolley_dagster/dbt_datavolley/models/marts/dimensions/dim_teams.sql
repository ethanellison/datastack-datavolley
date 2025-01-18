with source as (
	select * from {{ ref('int_teams')}}
)

select * from source
