
with source as (
    select * from {{ source('raw','raw_augmented_plays') }}
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
	{{ dbt_utils.generate_surrogate_key(['team_id','player_number']) }} as player_key,
        player_id,
        skill,
        skill_type,
        evaluation as evaluation_desc,
        case
            when evaluation_code in ('#') then 1
            when evaluation_code in ('/','=') then -1
            else 0
        end as evaluation_num,
        -- attack_code,
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
),

joined_on_matches as (

    select
        a.*,
        m.match_date as match_date,
        m.match_name as match_name
    from actions as a
    left join {{ ref('stg_cleaned_matches') }} as m
    on a.match_id = m.cleaned_match_id

),

joined_on_players as (
    select
        j.*,
        p.player_id,
        p.player_name
    from joined_on_matches as j
    left join {{ ref('int_players')}} as p
    on j.player_key = p.player_key
)

select * from joined_on_players
