# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of DiabetesTxPath
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Stanford University Center for Biomedical Informatics - Nigam Shah Lab
# @author Rohit Vashisht
#
#' @title
#' buildCohort
#'
#' @author
#' Rohit Vashisht
#'
#
#' Create the exposure and outcome cohorts
#'
#' @details
#' This function will create treatment, comparator and outcomes cohort as included in this package.
#'
#' @param connectionDetails       An object of type \code{connectionDetails} as created using the
#'                                \code{\link[DatabaseConnector]{createConnectionDetails}} function in
#'                                the DatabaseConnector package.
#' @param cdmDatabaseSchema       Schema name where your patient-level data in OMOP CDM format resides.
#'                                Note that for SQL Server, this should include both the database and
#'                                schema name, for example 'cdm_data.dbo'.
#' @param resultsDatabaseSchema   Schema name where intermediate data can be stored. You will need to
#'                                have write priviliges in this schema. Note that for SQL Server, this
#'                                should include both the database and schema name, for example
#'                                'cdm_data.dbo'.
#' @param treatment               The name of the of treatment cohort that you want to create.
#' @param comparator              The name of the comparator cohort that you want to create.
#' @param outComeId               The outcome Id of interest.
#'
#' @export
buildCohort <- function(connectionDetails,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema,
                        treatment,
                        comparator,
                        outComeId) {
  # Will build the cohorts depending on the outcome of interest
  outComeOne <- c("HbA1c7Good.sql")  #cohortId = 3
  outComeTwo <- c("HbA1c8Moderate.sql")
  outComeThree <- c("myocardialInfraction.sql")  #cohortId = 4
  outComeFour <- c("kidneyDisorder.sql")  #cohortId = 5
  outComeFive <- c("eyeDisorder.sql")  #cohortId = 6
  targetDatabaseSchema <- resultsDatabaseSchema
  targetCohortTable <- "ohdsi_t2dpathway"
  conn <- DatabaseConnector::connect(connectionDetails)
  sql <- "IF OBJECT_ID('@results_database_schema.@target_cohort_table', 'U') IS NOT NULL\n  DROP TABLE @results_database_schema.@target_cohort_table;\n    CREATE TABLE @results_database_schema.@target_cohort_table (cohort_definition_id INT, subject_id BIGINT, cohort_start_date DATE, cohort_end_date DATE);"
  sql <- SqlRender::renderSql(sql,
                              results_database_schema = resultsDatabaseSchema,
                              target_cohort_table = targetCohortTable)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  # Constructing treatment cohort - Treatment Cohort Id will always be 1
  sql <- readSql(system.file(paste("sql/sql_server/", treatment, sep = ""),
                             package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                              cdm_database_schema = cdmDatabaseSchema,
                              target_database_schema = targetDatabaseSchema,
                              target_cohort_table = targetCohortTable,
                              target_cohort_id = 1)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  # Constructing comparator cohort - Comparator Cohort ID will always be 2
  sql <- readSql(system.file(paste("sql/sql_server/", comparator, sep = ""),
                             package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                              cdm_database_schema = cdmDatabaseSchema,
                              target_database_schema = targetDatabaseSchema,
                              target_cohort_table = targetCohortTable,
                              target_cohort_id = 2)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  # Constructing outcome HbA1c cohort - Outcome cohort HbA1c will always have cohort id as 3
  if (outComeId == 3) {
    # will construct the outcome cohort for HbA1c7Good
    sql <- readSql(system.file(paste("sql/sql_server/", outComeOne, sep = ""),
                               package = "DiabetesTxPath"))
    sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 3)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  } else if (outComeId == 4) {
    # will construct the outcome cohort for HbA1c8Moderate
    sql <- readSql(system.file(paste("sql/sql_server/", outComeTwo, sep = ""),
                               package = "DiabetesTxPath"))
    sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 4)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  } else if (outComeId == 5) {
    # will construct the outcome cohort for Myocardial Infraction
    sql <- readSql(system.file(paste("sql/sql_server/", outComeThree, sep = ""),
                               package = "DiabetesTxPath"))
    sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 5)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  } else if (outComeId == 6) {
    # will construct the outcome cohort for kidney related disorders
    sql <- readSql(system.file(paste("sql/sql_server/", outComeFour, sep = ""),
                               package = "DiabetesTxPath"))
    sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 6)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  } else if (outComeId == 7) {
    # will construct the outcome cohort for eye related disorders
    sql <- readSql(system.file(paste("sql/sql_server/", outComeFour, sep = ""),
                               package = "DiabetesTxPath"))
    sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 7)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  } else {
    print(paste("Please enter correct OutComeId. It should be either 3, 4, 5, 6 or 7", sep = ""))
  }
}
