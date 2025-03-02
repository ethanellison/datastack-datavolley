{% set evaluations_query %}
select distinct evaluation_desc from {{ ref('stg_cleaned_actions') }} where skill = 'Serve'
{% endset %}

{% set evaluations = run_query(evaluations_query) %}

{% if execute %}
{% set evaluations_list = evaluations.columns[0].values() %}
{% else %}
{% set evaluations_list = [] %}
{% endif %}

with 

source as (
	select * from {{ ref('stg_cleaned_actions' )}} where skill = 'Serve'
),

serves_by_type_result as (
	select 
		player_key,
		match_id,
		player_id,
		skill_type,
		{% for evaluation in evaluations_list %}
		sum(case when evaluation_desc = '{{ evaluation }}' then 1 else 0 end) as "{{ evaluation }}",
		{% endfor %}
		avg(case when action_team = point_won_by_team then 1 else 0 end) as breakpoint_pct,
		count(*) as N
	from
		source
	where skill = 'Serve'
	-- group by 1,2,3,4
	{{ dbt_utils.group_by(n=4)}}
)

select * from serves_by_type_result
