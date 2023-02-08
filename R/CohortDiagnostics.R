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

#load renv and install package
renv::init()
#in the "Build" menu, click "install package"

#set connection details
##Type ?createConnectionDetails for the specific settings required for the various database management systems, (DBMS) example below
connectionDetails <- createConnectionDetails(
  dbms = "postgresql",
  server = "localhost/ohdsi",
  user = "joe",
  password = "supersecret"
)

#Generate Cohorts
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(packageName = "EHDENCovidUseCaseCD",
                                                               settingsFileName = "Cohorts.csv",
                                                               cohortFileNameValue = "cohortId")

cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTable)

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