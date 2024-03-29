CREATE TABLE #Codesets (
  ancestor_concept_id int NOT NULL,
  concept_id int NOT NULL
)
;

INSERT INTO #Codesets (ancestor_concept_id, concept_id)
 SELECT ancestor_concept_id, descendant_concept_id
 FROM @cdm_database_schema.CONCEPT_ANCESTOR
 WHERE ancestor_concept_id IN (@outcome_ids)
;

{DEFAULT @cohort_id_field_name = 'cohort_definition_id'}

INSERT INTO @target_database_schema.@target_cohort_table (
	subject_id,
	@cohort_id_field_name,
	cohort_start_date,
	cohort_end_date
)
SELECT
	s.subject_id,
	s.cohort_definition_id,
	s.cohort_start_date,
	s.cohort_start_date cohort_end_date
FROM (
    SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.condition_start_date cohort_start_date
FROM @cdm_database_schema.condition_occurrence d
INNER JOIN #Codesets c ON c.concept_id = d.condition_concept_id
UNION ALL
SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.drug_exposure_start_date cohort_start_date
FROM @cdm_database_schema.drug_exposure d
INNER JOIN #Codesets c ON c.concept_id = d.drug_concept_id
UNION ALL
SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.device_exposure_start_date cohort_start_date
FROM @cdm_database_schema.device_exposure d
INNER JOIN #Codesets c ON c.concept_id = d.device_concept_id
UNION ALL
SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.measurement_date cohort_start_date
FROM @cdm_database_schema.measurement d
INNER JOIN #Codesets c ON c.concept_id = d.measurement_concept_id
UNION ALL
SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.observation_date cohort_start_date
FROM @cdm_database_schema.observation d
INNER JOIN #Codesets c ON c.concept_id = d.observation_concept_id
UNION ALL
SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.procedure_date cohort_start_date
FROM @cdm_database_schema.procedure_occurrence d
INNER JOIN #Codesets c ON c.concept_id = d.procedure_concept_id
UNION ALL
SELECT d.person_id subject_id,
        c.ancestor_concept_id cohort_definition_id,
        d.visit_start_date cohort_start_date
FROM @cdm_database_schema.visit_occurrence d
INNER JOIN #Codesets c ON c.concept_id = d.visit_concept_id
) s
;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;
