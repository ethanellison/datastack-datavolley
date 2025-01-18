with 

source as (
	select 
		match_id,
		player_key,
		-- TODO: dim table for attack codes
		attack_code,
		in_out_system,
		rotation,
		setter_front_back,
		attack_phase,
		point_phase,
		triangle_phase,
		point_won_by_team,
		evaluation_desc
	from {{ ref('stg_cleaned_actions') }}
	where skill = 'Attack'
)


select * from source
