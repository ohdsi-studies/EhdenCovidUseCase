EHDEN COVID Use Case

This version contains the simplified PS model with CCI + Sex as covariates. For the study package containing the full PS model, visit the branch "Hydrated Minus Criteria 1".

=============

<img src="https://camo.githubusercontent.com/6a807f81d8ed58fdaab1b8b8d7391a347907567ec8771dfb4d1b8faa7ba0e61b/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53747564792532305374617475732d5265706f253230437265617465642d6c69676874677261792e737667" alt="Study Status: Protocol in Progress">

- Analytics use case(s): Estimation
- Study type: Clinical Application
- Tags: OHDSI, COVID-19
- Study lead: **-**
- Study lead forums tag: **[Ravinder Claire](https://forums.ohdsi.org/u/ravclaire) , [Christina Read](https://forums.ohdsi.org/u/christina_read) , [lead](https://forums.ohdsi.org/)]**
- Study start date: **-**
- Study end date: **-**
- Protocol: [EHDEN Use Case Protocol.pdf](https://github.com/ohdsi-studies/EhdenCovidUseCase/blob/Minus-Criteria-1/documents/EHDEN%20Use%20Case%20Protocol.pdf)
- Results explorer: **-**

The aim of this study is to estimate treatment effects for COVID-19 treatments using data from the EHDEN network and to combine these observational results with data from randomised studies.

Primary objectives: 
1) To assess comparative effectiveness and safety among Tocilizumab, Baricitinib, and Remdesivir in hospitalised patients
2) To assess comparative effectiveness and safety among Aspirin and Heparin in hospitalised patients 

Subgroup Analyses:
1) Effectiveness and safety in ICU patients  
2) Effectiveness and safety in patients receiving corticosteroids
3) Effectiveness and safety in patients receiving oxygen



Requirements
============

- A database in [Common Data Model version 5](https://ohdsi.github.io/CommonDataModel/) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, Spark, or Microsoft APS.
- R version 4.0.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 25 GB of free disk space

How to run
==========
1. Follow [these instructions](https://ohdsi.github.io/Hades/rSetup.html) for setting up your R environment, including RTools and Java. 

2. Create an empty folder or new RStudio project, and in `R`, use the following code to install the study package and its dependencies:

    ```r
    install.packages("renv")
    download.file("https://raw.githubusercontent.com/ohdsi-studies/EHDENUseCase6.4CCISex/main/renv.lock", "renv.lock")
    renv::init()
    ```  
    
    If renv mentions that the project already has a lockfile select "*1: Restore the project from the lockfile.*".

3. Once installed, you can execute the study by modifying and using the code below. For your convenience, this code is also provided under `extras/CodeToRun.R`:

    ```r
    library(EHDENUseCase6.4CCISex)

    # Optional: specify where the temporary files (used by the Andromeda package) will be created:
    options(andromedaTempFolder = "s:/andromedaTemp")
	
    # Maximum number of cores to be used:
    maxCores <- parallel::detectCores()
	
    # Minimum cell count when exporting data:
    minCellCount <- 5
	
    # The folder where the study intermediate and result files will be written:
    outputFolder <- "c:/EHDENUseCase6.4CCISex"
	
    # Details for connecting to the server:
    # See ?DatabaseConnector::createConnectionDetails for help
    connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                connectionString = keyring::key_get("redShiftConnectionStringOhdaMdcr"),
                                                                user = keyring::key_get("redShiftUserName"),
                                                                password = keyring::key_get("redShiftPassword"))

    # The name of the database schema where the CDM data can be found:
    cdmDatabaseSchema <- "cdm_truven_mdcr_v1911"

    # The name of the database schema and table where the study-specific cohorts will be instantiated:
    cohortDatabaseSchema <- "scratch_mschuemi"
    cohortTable <- "estimation_skeleton"

    # Some meta-information that will be used by the export function:
    databaseId <- "IBM_MDCR"
    databaseName <- "IBM MarketScan® Medicare Supplemental and Coordination of Benefits Database"
    databaseDescription <- "IBM MarketScan® Medicare Supplemental and Coordination of Benefits Database (MDCR) represents health services of retirees in the United States with primary or Medicare supplemental coverage through privately insured fee-for-service, point-of-service, or capitated health plans.  These data include adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy). Additionally, it captures laboratory tests for a subset of the covered lives."

    # For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
    options(sqlRenderTempEmulationSchema = NULL)

    execute(connectionDetails = connectionDetails,
            cdmDatabaseSchema = cdmDatabaseSchema,
            cohortDatabaseSchema = cohortDatabaseSchema,
            cohortTable = cohortTable,
            outputFolder = outputFolder,
            databaseId = databaseId,
            databaseName = databaseName,
            databaseDescription = databaseDescription,
            verifyDependencies = TRUE,
            createCohorts = TRUE,
            synthesizePositiveControls = TRUE,
            runAnalyses = TRUE,
            packageResults = TRUE,
            maxCores = maxCores)
    ```
    
4. Email results to christina.read@nice.org.uk and ravinder.claire@nice.org.uk
		
5. To view the results, use the Shiny app:

	```r
	prepareForEvidenceExplorer("Result_<databaseId>.zip", "/shinyData")
	launchEvidenceExplorer("/shinyData", blind = TRUE)
	```
  
  Note that you can save plots from within the Shiny app. It is possible to view results from more than one database by applying `prepareForEvidenceExplorer` to the Results file from each database, and using the same data folder. Set `blind = FALSE` if you wish to be unblinded to the final results.

License
=======
The EHDENUseCase6.4CCISex package is licensed under Apache License 2.0

Development
===========
EHDENUseCase6.4CCISex was developed in ATLAS and R Studio.
