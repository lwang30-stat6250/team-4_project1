*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file is used to analyze 3 research questions from the IMDB 5000+ movie dataset

Dataset Name: Movie_dataset created in external file
STAT6250-02_s17-team-4_project1_data_preparation.sas, which is assumed to be
in the same directory as this file

See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick;
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that generates analytic dataset FRPM1516_analytic_file;
%include '.\STAT6250-02_s17-team-4_project1_data_preparation.sas';



*
Research Question:Does US movie have a higher imdb_score than other country's movie ?

Rationale:It indicates how the US-made movies are different from the other countries' based on the audience ratings.

Methodology:Use Proc Format to categorize the variable "country" into two groups, "USA" and "Not_USA". 
			
			Use a data procedure to associate the new format with the variable "country", and store into a new dataset.

			Compute five-number summaries by the reformatted variable consisting of two country groups.

Limitations:This methodology does not count missing data. In addition, the five-number summaries may not be able to

			reflect all the characteristics of the imdb_score data.

Possible follow-up steps:Deal with the missing data by a further cleaning step.Perform one-way ANOVA to test the difference

			between two country groups on the imdb_score.
;
proc format;
	value $country_bins
	"USA"="USA"
	other="Not_USA"
	;	
run;

data new_country_data;
	set movie_analytic_file;
	format country country_bins.;
run;

proc means min q1 median q3 max data=new_country_data;
	class country;
	var imdb_score;
run;



*
Research Question:Can "budget" be used to predict the "gross" income of a movie ?

Rationale: This helps determine if the movies that make more money are associated with a higher investment for manufacturing.

Methodology: Use Proc Means to obtain the five-number summary of both "budget" and "gross".

			Then use quartiles to bin values for each variable, and use Proc Freq to crosstabulate bins.

Limitations:This method only uses descriptive statistics to examine the relationship between two numeric variables. 

Possible follow-up steps:A better approach would be to apply an appropriate regression model to study their relationship.
;

proc means min q1 median q3 max data=movie_analytic_file;
	var
		budget
		gross
	;
run;

proc format;
	value budget_bins
		low-6000000="Q1 budget"
		6000001-20000000="Q2 budget"
		20000001-45000000="Q3 budget"
		45000001-high="Q4 budget"
	;
	value gross_bins
		low-5333658="Q1 gross"
		5333659-25517500="Q2 gross"
		25517501-62318875="Q3 gross"
		62318876-high="Q4 gross"
	;
run;

proc freq data=movie_analytic_file;
	table budget*gross/missing norow nocol nopercent;
	format 
		budget budget_bins.
		gross gross_bins.
	;
run;



*
Research Question: 
;

