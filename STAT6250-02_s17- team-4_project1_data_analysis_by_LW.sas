*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file is used to analyze 3 research questions from the IMDB 5000+ movie dataset

Dataset Name: Movie_dataset created in external file
STAT6250-02_s17-team-4_project1_data_preparation.sas, which is assumed to be
in the same directory as this file
;

*
Research Question: Does longer movie cost more to be produced ?

Rationale: This can help determine the relationship between the duration of a movie and its budget.

Methodology: Use PROC GLM to test for linear regression model between the variable "duration" and variable "budget".
;

*
Research Question: What is the average income of a movie ? Does the income follow a normal distribution ?

Rationale: This provides a basic understanding of how much the filmmakers can earn.

Methodology: Compute five-number summary for the variable "gross" and test for its nomality.
;

*
Research Question: Does US movie have a higher imdb_score than other country's movie ?

Rationale: This reveals if US movie has a better audience feedback.

Methodology: Use PROC GLM to perform ANOVA for the variables "country" and "imdb_score".
;

