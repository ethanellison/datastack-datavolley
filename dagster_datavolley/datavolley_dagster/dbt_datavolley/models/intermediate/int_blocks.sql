{% set evaluations_query %}
select distinct evaluation_desc from {{ ref('stg_cleaned_actions') }} where skill = 'Block'
{% endset %}

{% set evaluations = run_query(evaluations_query) %}

{% if execute %}
{% set evaluations_list = evaluations.columns[0].values() %}
{% else %}
{% set evaluations_list = [] %}
{% endif %}

with 

source as (
	select 
		match_id,
		player_key,
		--action_team,
		--match_name,
		--match_date,
		{{ dbt_utils.pivot(
			'evaluation_desc',
			dbt_utils.get_column_values(table=ref('stg_cleaned_actions'), column='evaluation_desc', where="skill = 'Block'"),
			agg='sum'
		) }},
		--avg(evaluation_num) as eff,
		count(*) as N
	from {{ ref('stg_cleaned_actions') }}
	where skill = 'Block'
	group by 1,2
),

attacking_metrics as (
	select
		*,
		("Winning attack" / "N") as Kill_pct,
		("Blocked" / "N") as Blocked_pct,
		("Error" / "N") as Error_pct
	from source
)

select * from source
