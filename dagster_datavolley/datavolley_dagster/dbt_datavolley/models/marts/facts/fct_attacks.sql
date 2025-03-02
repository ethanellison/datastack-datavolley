{% set evaluations_query %}
select distinct evaluation_desc from {{ ref('int_attacks') }}
{% endset %}

{% set evaluations = run_query(evaluations_query) %}

{% if execute %}
{% set evaluations_list = evaluations.columns[0].values() %}
{% else %}
{% set evaluations_list = [] %}
{% endif %}

with source as (
select
	player_key,
	match_id,
	{% for evaluation in evaluations_list %}
		sum(case when evaluation_desc = '{{ evaluation }}' then 1 else 0 end) as "{{ evaluation }}",
	{% endfor %}
	count(*) as N
from
	{{ ref('int_attacks') }}
{{ dbt_utils.group_by(n=2) }}

)
select * from source