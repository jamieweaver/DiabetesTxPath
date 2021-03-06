# @file functions
#
# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of:
#  ----------------------------------------------
#  DiabetesTxPath
#  ----------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Stanford University Center for Biomedical Informatics - Shah Lab
# @author Rohit Vashisht
#
#' @title
#' runCompleteStudy
#'
#' @author
#' Rohit Vashisht
#'
#' @details
#' This function can be used to perform the DiabetesTxPathway analysis end-to-end. Just supply the
#' details and leave it running overnight. Please note the function will perform analysis if there are
#' atleast 250 patients for each of the drug group considered in the study.
#'
#' @param connectionDetails       The connection details of the database.
#' @param cdmDatabaseSchema       The cdm database schema
#' @param resultsDatabaseSchema   The results datavase schema
#' @param cdmVersion              The cdm version, should be 5 only
#'
#' @export
runCompleteStudy <- function(connectionDetails = connectionDetails,
                             cdmDatabaseSchema = cdmDatabaseSchema,
                             resultsDatabaseSchema = resultsDatabaseSchema,
                             cdmVersion = cdmVersion,
                             results_path = results_path) {
  #Creating an intermediate directory to store results that you might
  #need to re-run the study in case it crashes. Please make sure that
  #you don't share this subdirectory. We are therefore naming it as
  #deleteMeBeforeSharing
  unlink(paste(results_path,"deleteMeBeforeSharing",sep=""), recursive = TRUE)
  dir.create(file.path(paste(results_path,"deleteMeBeforeSharing",sep="")))
  outComeId <- c(3, 4, 5, 6, 7)
  # 3 - HbA1c7Good 4 - HbA1c8Moderate 5 - MI 6 - KD 7 - ED
  outComeName <- c("HbA1c7Good", "HbA1c8Moderate", "MI", "KD", "ED")
  drugComp <- list()
  for (i in 1:length(outComeId)) {
    drugComp[[i]] <- runStudy(connectionDetails = connectionDetails,
                              cdmDatabaseSchema = cdmDatabaseSchema,
                              resultsDatabaseSchema = resultsDatabaseSchema,
                              cdmVersion = cdmVersion,
                              outComeId = outComeId[i],
                              outComeName = outComeName[i],
                              results_path = results_path)
    print(paste("*************** Study Completed for outcome - ",
                outComeName[i],
                " *******************",
                sep = ""))
  }
  resultBundle <- data.frame()
  for (i in 1:length(drugComp)) {
    dat <- drugComp[[i]]
    resultBundle <- rbind(resultBundle, dat)
    remove(dat)
  }
  write.csv(resultBundle, file = paste(results_path, "resultBundel.csv", sep = ""))
  remove(resultBundle)
}
