library(remotes)
remotes::install_github("OHDSI/CohortDiagnostics")
library(CohortDiagnostics)

#run this to make sure the CohortDefinitionSet has loaded correctly from the study package
View(cohortDefinitionSet)

exportFolder <- "export"

#this uses connection details/definition sets that are already used in the study analysis
#so hopefully it is not necessary to redefine these variables if the study has already run
executeDiagnostics(cohortDefinitionSet,
                   connectionDetails = connectionDetails,
                   cohortTable = cohortTable,
                   cohortDatabaseSchema = cohortDatabaseSchema,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   exportFolder = exportFolder,
                   databaseId = "MyCdm",
                   minCellCount = 5)

#drop unnecessary tables
CohortGenerator::dropCohortStatsTables(connectionDetails = connectionDetails,
                                       cohortDatabaseSchema = cohortDatabaseSchema,
                                       cohortTableNames = cohortTableNames)

#merge results
createMergedResultsFile(exportFolder)
