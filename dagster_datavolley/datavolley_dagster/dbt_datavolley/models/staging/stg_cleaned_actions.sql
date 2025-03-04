
with source as (
    select * from {{ source('raw',"augmented_plays.gz.parquet") }}
),

actions as (
    select
        -- ids
        match_id,
        point_id,
        team_touch_id,
        file_line_number,
        team_id,

        -- teams
        home_team,
        visiting_team,
        team as action_team,
        serving_team,

        -- action
	-- {{ dbt_utils.generate_surrogate_key(['team_id','player_number']) }} as player_key,
        md5(concat(team_id,player_number)) as player_key,
        player_id,
        skill,
        skill_type,
        trim( case 
            when evaluation = 'Error' and skill = 'Serve' then concat(evaluation,' ',special_code)
            else evaluation
        end) as evaluation_desc, 
        evaluation_code,
--        case
--            when evaluation_code in ('#') then 1
--            when evaluation_code in ('/','=') then -1
--            else 0
--        end as evaluation_num,
        attack_code,
        attack_description,
        num_players as block_type,
        num_players_numeric as block_num,

        -- reception quality
        ts_pass_quality as pass_quality,
        case
            when ts_pass_evaluation_code in ('#', '+') then 'IN'
            else 'OUT'
        end as in_out_system,
        setter_position as rotation,
        setter_front_back,
        
        -- phase
        attack_phase,
        point_phase,
        phase as triangle_phase,
        home_team_score,
        visiting_team_score,

        -- result
        point_won_by as point_won_by_team

    from 
        source
)

select * from actions
