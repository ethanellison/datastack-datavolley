with

source as (
	select * from {{ ref('raw_matches') }}
)

select *
from source
order by match_date desc
