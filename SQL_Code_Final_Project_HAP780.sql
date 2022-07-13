SELECT TOP (1000) [Patient ID]
      ,[Age recode with single ages and 85+]
      ,[Sex]
      ,[Race recode (White, Black, Other)]
      ,[Year of diagnosis]
      ,[Site recode ICD-O-3/WHO 2008]
      ,[Primary Site - labeled]
      ,[Grade (thru 2017)]
      ,[Laterality]
      ,[Diagnostic Confirmation]
      ,[ICD-O-3 Hist/behav]
      ,[Reason no cancer-directed surgery]
      ,[Combined Summary Stage (2004+)]
      ,[Primary Site]
      ,[Survival months]
      ,[Vital status recode (study cutoff used)]
  FROM [FianlProjectHAP780].[dbo].[OCPC_SEEER_Data]

--Casting 
DROP TABLE #CastData
USE FianlProjectHAP780
SELECT CAST([Patient ID] AS INT ) AS Patient_ID
      ,CAST([Age recode with single ages and 85+] AS FLOAT) AS AgeAtDx
      ,[Sex] AS Sex
      ,[Race recode (White, Black, Other)] AS Race
      ,CAST([Year of diagnosis] AS FLOAT) AS YearOfDx
      ,[Site recode ICD-O-3/WHO 2008] AS Primary_Site
      ,[Grade (thru 2017)] AS Garde
      ,[Diagnostic Confirmation] AS Diagnostic_Confirmation
      ,[ICD-O-3 Hist/behav] AS [ICD-O-3 Hist/behav] 
      ,[Reason no cancer-directed surgery] AS Rx_Surgery_reason
      ,[Combined Summary Stage (2004+)] AS Extend_of_Disease
      ,CAST([Survival months] AS FLOAT ) AS Survival_months
      ,[Vital status recode (study cutoff used)] AS Vital_status
	  INTO #CastData
  FROM [FianlProjectHAP780].[dbo].OCPC_SEEER_Data -- (76072 rows affected)


--Grouping Age into 7 Categories
drop table #temp
select *, case  
when ageatdx between 50 and 54 then '50-54'
when ageatdx  between 55 and 59 then '55-59'
when ageatdx  between 60 and 64 then '60-64'
when ageatdx  between 65 and 69 then '65-69'
when ageatdx  between 70 and 74 then '70-74'
when ageatdx  between 75 and 79 then '75-79'
when ageatdx  between 80 and 84 then '80-84'
end as Age_Group into #temp
from #castdata 

--Grouping carcinomas based on histological behavior
drop table #temp_table
select  *, case when 
[ICD-O-3 Hist/behav] like '_%Squamous cell carcinoma%' then 'Squamous cell carcinoma'
else 'Non-Squamous cell carcinoma'
end as Hist_Behav into #temp_table from #temp 

--grouping surgery data
drop table #temp_table2
select *, case
when [Rx_Surgery_reason] like 'Surgery Performed' then 'Yes'
else 'No_Unknown'end as Rx_Surgery into #temp_table2 from #temp_table

select * FROM #temp_table2 


drop table #OCPC_Binary_Data
USE FianlProjectHAP780
SELECT  Patient_ID,  Yearofdx

,max(case when  [Race] = 'White'  then 1 else 0 end) as White
,max(case when [Race] = 'Black'  then 1 else 0 end) as Black

,max(case when [Sex] = 'Male'  then 1 else 0 end) as Male
,max(case when [Sex] = 'Female'  then 1 else 0 end) as Female 

,max(case when Age_Group  ='50-54' then 1 else 0 end) as    Age_DX_50_54
,max(case when Age_Group = '55-59' then 1 else 0 end) as 	Age_DX_55_59
,max(case when Age_Group = '60-64' then 1 else 0 end) as 	Age_DX_60_64
,max(case when Age_Group = '65-69' then 1 else 0 end) as 	Age_DX_65_69
,max(case when Age_Group = '70-74' then 1 else 0 end) as 	Age_DX_70_74
,max(case when Age_Group = '75-79' then 1 else 0 end) as 	Age_DX_75_79
,max(case when Age_Group = '80-84' then 1 else 0 end) as 	Age_DX_80_84


,max(case when Primary_Site  = 'Lip' then 1 else 0 end) as Primary_Site_Lip
,max(case when Primary_Site = 'Tongue' then 1 else 0 end) as Primary_Site_Tongue
,max(case when Primary_Site = 'Oropharynx' then 1 else 0 end) as Primary_Site_Oropharynx
,max(case when Primary_Site = 'Tonsil' then 1 else 0 end) as Primary_Site_Large_Intestine
,max(case when Primary_Site = 'Gum and Other Mouth' then 1 else 0 end) as Primary_Site_Gum_and_Other_Mouth
,max(case when Primary_Site = 'Salivary Gland' then 1 else 0 end) as Primary_Site_Salivary_Gland 
,max(case when Primary_Site = 'Floor of Mouth' then 1 else 0 end) as Primary_Site_Floor_of_Mouth
,max(case when Primary_Site = 'Hypopharynx' then 1 else 0 end) as Primary_Site_Hypopharynx
,max(case when Primary_Site = 'Nasopharynx' then 1 else 0 end) as Primary_Site_Sigmoid_Nasopharynx
,max(case when Primary_Site = 'Other Oral Cavity and Pharynx' then 1 else 0 end) as Primary_Site_Other

,max(case when Garde = 'Well differentiated; Grade I'   then 1 else 0 end) as GradeI
,max(case when Garde = 'Moderately differentiated; Grade II'  then 1 else 0 end) as GradeII
,max(case when Garde = 'Poorly differentiated; Grade III' then 1 else 0 end) as GradeIII
,max(case when Garde = 'Undifferentiated; anaplastic; Grade IV'  then 1 else 0 end) as GradeIV

,max(case when [Extend_of_Disease]  = 'Regional'  then 1 else 0 end) as 	Historic_Stage_Regional
,max(case when [Extend_of_Disease] = 'Distant'  then 1 else 0 end) as 	Historic_Stage_Distant
,max(case when [Extend_of_Disease] = 'Localized' then 1 else 0 end) as  Historic_Stage_Localized

,max(case when Hist_Behav='Squamous cell carcinoma' then 1 else 0 end) as SCC
,max(case when Hist_Behav='Non-Squamous cell carcinoma' then 1 else 0 end) as other

,max(case when [Diagnostic_Confirmation]= 'Positive histology'  then 1 else 0 end) as 	Positive_histology
,max(case when [Diagnostic_Confirmation] = 'Clinical diagnosis only'  then 1 else 0 end) as Clinical_diagnosis_only
,max(case when [Diagnostic_Confirmation] = 'Direct visualization without microscopic confirmation' then 1 else 0 end) as Direct_vis_without_microscopic
,max(case when [Diagnostic_Confirmation] = 'Pos hist AND immunophenotyping AND/OR pos genetic studies' then 1 else 0 end) as  pos_hist_immunophenotyping_and_genetic_studies
,max(case when [Diagnostic_Confirmation] = 'Positive exfoliative cytology, no positive histology' then 1 else 0 end) as  no_positive_histology
,max(case when [Diagnostic_Confirmation] = 'Positive laboratory test/marker study' then 1 else 0 end) as Positive_laboratory_test
,max(case when [Diagnostic_Confirmation] = 'Radiography without microscopic confirm' then 1 else 0 end) as Radiography_without_microscopic
,max(case when [Diagnostic_Confirmation] = 'Positive microscopic confirm, method not specified' then 1 else 0 end) as Positive_microscopic_confirm 

,max (case when Rx_Surgery ='Yes'	then 1 else 0 end) as 	Rx_Surgery_Yes
,max (case when Rx_Surgery ='No/Unknown'	then 1 else 0 end) as 	Rx_Surgery_N

,max(case when [Vital_status] = 'Alive'  then 1 else 0 end) as Vital_status 
,max(case when [Survival_Months] >= 48 then 1 else 0 end) as Survival 

into #OCPC_Binary_Data
From  #temp_table2
group by  Patient_ID,  Yearofdx -- (75437 rows affected)

SELECT * into OCPC_Binary_Data from #OCPC_Binary_Data  

SELECT distinct count (*) from #OCPC_Binary_Data 











