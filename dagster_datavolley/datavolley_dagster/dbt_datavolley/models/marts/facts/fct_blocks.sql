{% set evaluations_query %}
select distinct evaluation_desc from {{ ref('stg_cleaned_actions') }} where skill = 'Block'
{% endset %}

{% set evaluations = run_query(evaluations_query) %}

{% if execute %}
{% set evaluations_list = evaluations.columns[0].values() %}
{% else %}
{% set evaluations_list = [] %}
{% endif %}

with source as (
	select * 
	from {{ ref('stg_cleaned_actions')}} 
	where skill = 'Block'
),

blocks_grouped_by_evaluation as (
	select 
		player_key,
		match_id,
		in_out_system,
		rotation,
		block_type,
		block_num as block_type_num,
		attack_phase,
		point_phase,
		{% for evaluation in evaluations_list %}
		sum(case when evaluation_desc = '{{ evaluation }}' then 1 else 0 end) as "{{ evaluation }}",
		{% endfor %}
		count(*) as N
	from
		source
	{{ dbt_utils.group_by(n=8)}}
)

select * from blocks_grouped_by_evaluation
