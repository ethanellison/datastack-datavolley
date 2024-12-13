
-- Use the `ref` function to select from other models

with source as (
    select * from {{ source('raw_data','raw_augmented_plays') }}
),

blocks as (
    select
        -- ids
        match_id,
        point_id,
        team_touch_id,
        file_line_number,

        -- teams
        home_team,
        visiting_team,
        team as action_team,
        serving_team,

        -- match
        cast(time as DATE) as match_date,
        concat(home_team," ",visiting_team, " ", date_trunc('day', time)) as match_name,

        -- action
        player_id,
        player_name, -- TODO: replace with players table lookup

        evaluation as evaluation_desc,
        case
            when evaluation_code in ('#') then 1
            when evaluation_code in ('/','=') then -1
            else 0
        end as evaluation_num,
        num_players as block_type,
        num_players_numeric as block_num,
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

    where skill = 'Block'
)

select * from blocks
