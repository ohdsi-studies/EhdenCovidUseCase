EHDENCovidUseCaseCD
==============================

This repository contains Cohort Diagnostics for the EHDEN Covid Use Case Study. To run the Cohort Diagnostics, download this repository and follow the directions below.

#load renv and install package (this must be done before running the following steps, or the package will not install correctly)
renv::init()
#in the "Build" menu, click "install package"



#create a GITHUB PAT to download OHDSI packages (if one is not already downloaded)
install.packages("usethis")
library(usethis)
create_github_token(scopes = c("(no scope)"), description = "R:GITHUB_PAT2", host = "https://github.com")
edit_r_environ()
set_github_pat("insert generated pat")

#install Cohort Diagnostics
library(remotes)
remotes::install_github("OHDSI/CohortDiagnostics")

#load Cohort Diagnostics
library(CohortDiagnostics)


#set connection details
##Type ?createConnectionDetails for the specific settings required for the various database management systems, (DBMS) example below
connectionDetails <- createConnectionDetails(
  dbms = "postgresql",
  server = "localhost/ohdsi",
  user = "joe",
  password = "supersecret"
)

#Load cohort references
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "Cohorts.csv",
  jsonFolder = "cohorts",
  sqlFolder = "sql/sql_server",
  packageName = "EHDENUseCase6.5full"
  )

#run this to make sure the CohortDefinitionSet has loaded correctly from the study package
> View(cohortDefinitionSet)

cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = "cohort")

# Next create the tables on the database
CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortTableNames = cohortTableNames,
  cohortDatabaseSchema = "main",
  incremental = FALSE
)

# Generate the cohort set
CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = cohortDefinitionSet,
  incremental = FALSE
)


#Execute Diagnostics

exportFolder <- "export"

executeDiagnostics(cohortDefinitionSet,
                   connectionDetails = connectionDetails,
                   cohortTable = cohortTable,
                   cohortDatabaseSchema = cohortDatabaseSchema,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   exportFolder=outputfolder,
                   databaseId = "insert database id",
                   minCellCount = 5)

##this generates a zip file. to generate the sqlite file, run the following:
createMergedResultsFile(exportFolder)

#both the .zip file and sqlite file can be shared as results
