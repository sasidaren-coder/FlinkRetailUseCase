
SET 'pipeline.name' = 'claim_diagnosis_bronze_ingestion';
INSERT INTO claim_diagnosis_delta_table SELECT claim_id, member_id, diagnosis_code, diagnosis_description, diagnosis_date, lab_results, event_time FROM claim_diagnosis;

SET 'pipeline.name' = 'claim_procedure_bronze_ingestion';
INSERT INTO claim_procedure_delta_table SELECT claim_id, member_id, diagnosis_code, procedure_code, procedure_description, procedure_date, procedure_cost, event_time FROM claim_procedure;

SET 'pipeline.name' = 'claim_provider_bronze_ingestion';
INSERT INTO claim_provider_delta_table SELECT claim_id, provider_id, provider_name, in_network, facility_name, event_time FROM claim_provider;


-- Insert data into new eligible procedures table
SET 'pipeline.name' = 'eligible_procedures_static_data';
INSERT INTO eligible_procedures VALUES
('PRC001', 'Appendectomy'),
('PRC002', 'Cataract Surgery'),
('PRC003', 'Dental Filling'),
('PRC004', 'Orthopedic Surgery'),
('PRC005', 'Cardiac Surgery'),
('PRC006', 'Stroke Treatment'),
('PRC007', 'Chemotherapy'),
('PRC008', 'ENT Surgery'),
('PRC009', 'Hypertension Treatment'),
('PRC010', 'Asthma Treatment');


-- Insert data into ineligible procedures table
SET 'pipeline.name' = 'ineligible_procedures_static_data';
INSERT INTO ineligible_procedures VALUES
('PRC011', 'Blood Transfusion'),
('PRC012', 'Chickenpox Vaccination'),
('PRC013', 'Measles Vaccination'),
('PRC014', 'Mumps Vaccination'),
('PRC015', 'Malaria Treatment'),
('PRC016', 'Typhoid Treatment'),
('PRC017', 'Dengue Treatment'),
('PRC018', 'Cholera Treatment'),
('PRC019', 'Leprosy Treatment'),
('PRC020', 'Tuberculosis Treatment'),
('PRC021', 'Hepatitis Treatment'),
('PRC022', 'Influenza Treatment'),
('PRC023', 'Pneumonia Treatment'),
('PRC024', 'Polio Vaccination'),
('PRC025', 'Rabies Vaccination'),
('PRC026', 'Scabies Treatment'),
('PRC027', 'Smallpox Vaccination'),
('PRC028', 'Tetanus Vaccination'),
('PRC029', 'Whooping Cough Vaccination'),
('PRC030', 'Zika Virus Treatment'),
('PRC031', 'Ebola Treatment'),
('PRC032', 'SARS Treatment'),
('PRC033', 'MERS Treatment'),
('PRC034', 'HIV/AIDS Treatment'),
('PRC035', 'Chikungunya Treatment'),
('PRC036', 'Yellow Fever Vaccination'),
('PRC037', 'West Nile Virus Treatment'),
('PRC038', 'Avian Influenza Treatment'),
('PRC039', 'Swine Flu Treatment');


-- Create eligible_diagnosis table


-- Insert data into eligible_diagnosis table
SET 'pipeline.name' = 'eligible_diagnosis_static_data';
INSERT INTO eligible_diagnosis VALUES
('DG001', 'Appendicitis'),
('DG002', 'Cataract'),
('DG003', 'Tooth Decay'),
('DG004', 'Fracture'),
('DG005', 'Heart Attack'),
('DG006', 'Stroke'),
('DG007', 'Cancer'),
('DG008', 'Sinusitis'),
('DG009', 'Hypertension'),
('DG010', 'Asthma');

-- Create ineligible_diagnosis table


-- Insert data into ineligible_diagnosis table
SET 'pipeline.name' = 'ineligible_diagnosis_static_data';
INSERT INTO ineligible_diagnosis VALUES
('DG011', 'Anemia'),
('DG012', 'Chickenpox'),
('DG013', 'Measles'),
('DG014', 'Mumps'),
('DG015', 'Malaria'),
('DG016', 'Typhoid'),
('DG017', 'Dengue'),
('DG018', 'Cholera'),
('DG019', 'Leprosy'),
('DG020', 'Tuberculosis'),
('DG021', 'Hepatitis'),
('DG022', 'Influenza'),
('DG023', 'Pneumonia'),
('DG024', 'Polio'),
('DG025', 'Rabies'),
('DG026', 'Scabies'),
('DG027', 'Smallpox'),
('DG028', 'Tetanus'),
('DG029', 'Whooping Cough'),
('DG030', 'Zika Virus'),
('DG031', 'Ebola'),
('DG032', 'SARS'),
('DG033', 'MERS'),
('DG034', 'HIV/AIDS'),
('DG035', 'Chikungunya'),
('DG036', 'Yellow Fever'),
('DG037', 'West Nile Virus'),
('DG038', 'Avian Influenza'),
('DG039', 'Swine Flu');




-- Insert data into procedure_thresholds table
SET 'pipeline.name' = 'procedure_thresholds_static_data';
INSERT INTO procedure_thresholds VALUES
('PRC001', 1000.00),
('PRC002', 2000.00),
('PRC003', 3500.00),
('PRC004', 3000.00),
('PRC005', 5500.00),
('PRC006', 4500.00),
('PRC007', 6500.00),
('PRC008', 1500.00),
('PRC009', 1200.00),
('PRC010', 2500.00);



SET 'pipeline.name' = 'full_join_l1_v1';
INSERT INTO claim_full_info
SELECT
  d.claim_id,
  d.member_id,
  d.diagnosis_code,
  d.diagnosis_description,
  d.diagnosis_date,
  d.lab_results,
  p.procedure_code,
  p.procedure_description,
  p.procedure_date,
  p.procedure_cost,
  pr.provider_id,
  pr.provider_name,
  pr.in_network,
  pr.facility_name,
  d.event_time
FROM claim_diagnosis_delta_table/*+ OPTIONS('mode' = 'streaming') */ d
JOIN claim_procedure_delta_table/*+ OPTIONS('mode' = 'streaming') */ p ON d.claim_id = p.claim_id and d.diagnosis_code = p.diagnosis_code
JOIN claim_provider_delta_table/*+ OPTIONS('mode' = 'streaming') */ pr ON d.claim_id = pr.claim_id and p.claim_id = pr.claim_id;


select * from claim_full_info;



SET 'pipeline.name' = 'processed_claims_full_info_l1_v2';
INSERT INTO processed_claim_full_info
SELECT
    c.claim_id,
    c.member_id,
    c.diagnosis_code,
    c.diagnosis_description,
    c.diagnosis_date,
    c.lab_results,
    c.procedure_code,
    c.procedure_description,
    c.procedure_date,
    c.procedure_cost,
    c.provider_id,
    c.provider_name,
    c.in_network,
    c.facility_name,
    c.event_time,
    CASE
        WHEN c.procedure_cost > t.cost_threshold THEN FALSE
        ELSE TRUE
    END AS adjudicated
FROM claim_full_info/*+ OPTIONS('mode' = 'streaming') */ c
JOIN eligible_procedures e ON c.procedure_code = e.procedure_code
JOIN eligible_diagnosis d ON c.diagnosis_code = d.diagnosis_code
JOIN procedure_thresholds t ON c.procedure_code = t.procedure_code;


select * from processed_claim_full_info;


-- Create rejected_claims_delta_table


-- Insert data into rejected_claims_delta_table for ineligible procedures
SET 'pipeline.name' = 'rejected_claims_ineligible_procedures_diagnosis_l1_v1';
INSERT INTO rejected_claims_delta_table
SELECT
    c.claim_id,
    c.member_id,
    c.diagnosis_code,
    c.diagnosis_description,
    c.diagnosis_date,
    c.lab_results,
    c.procedure_code,
    c.procedure_description,
    c.procedure_date,
    c.procedure_cost,
    c.provider_id,
    c.provider_name,
    c.in_network,
    c.facility_name,
    c.event_time,
    FALSE AS adjudicated
FROM claim_full_info/*+ OPTIONS('mode' = 'streaming') */ c
INNER JOIN ineligible_procedures e ON c.procedure_code = e.procedure_code
INNER JOIN ineligible_diagnosis d ON c.diagnosis_code = d.diagnosis_code;



SET 'pipeline.name' = 'adjudicated_claims_l2_v1';
INSERT INTO adjudicated_claims (
    SELECT * FROM processed_claim_full_info/*+ OPTIONS('mode' = 'streaming') */
    WHERE adjudicated = TRUE
);


SET 'pipeline.name' = 'unadjudicated_claims_l2_v1';
INSERT INTO unadjudicated_claims (
    SELECT * FROM processed_claim_full_info/*+ OPTIONS('mode' = 'streaming') */
    WHERE adjudicated = FALSE
    UNION ALL
    SELECT * FROM rejected_claims_delta_table/*+ OPTIONS('mode' = 'streaming') */
);


SET 'pipeline.name' = 'adjudicated_claims_summary_gold_l2_v2';
INSERT INTO adjudicated_claims_summary
SELECT
     claim_id,
     COUNT(DISTINCT diagnosis_code) AS total_diagnoses,
     COUNT(DISTINCT procedure_code) AS total_procedures
 FROM adjudicated_claims/*+ OPTIONS('mode' = 'streaming') */
 GROUP BY
     TUMBLE(PROCTIME(), INTERVAL '30' SECONDS),
     claim_id;


SET 'pipeline.name' = 'unadjudicated_claims_summary_gold_l2_v2';
INSERT INTO unadjudicated_claims_summary
SELECT
     claim_id,
     COUNT(DISTINCT diagnosis_code) AS total_diagnoses,
     COUNT(DISTINCT procedure_code) AS total_procedures
 FROM unadjudicated_claims/*+ OPTIONS('mode' = 'streaming') */
 GROUP BY
     TUMBLE(PROCTIME(), INTERVAL '30' SECONDS),
     claim_id;




