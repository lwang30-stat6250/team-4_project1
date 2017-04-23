*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file is used to analyze 3 research questions from the IMDB 5000+ movie 
dataset.

Dataset Name: Movie_dataset created in external file
STAT6250-02_s17-team-4_project1_data_preparation.sas, which is assumed to be
in the same directory as this file.

See included file for dataset properties.
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick;
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that generates analytic dataset FRPM1516_analytic_file;
%include '.\STAT6250-02_s17-team-4_project1_data_preparation.sas';



*
Research Question:Does US movie have a higher imdb_score than other country's 
movie ?

Rationale:This indicates how the US-made movies are different from the other 
countries' based on the audience ratings.

Methodology:Use Proc Format to categorize the variable "country" into two 
groups, "USA" and "Not_USA". Use a data procedure to associate the new format 
with the variable "country", and store into a new dataset. Compute five-number 
summaries by the reformatted variable consisting of two country groups.

Limitations:This methodology does not count missing data. In addition, the 
five-number summaries may not be able to reflect all the characteristics of 
the imdb_score data.

Possible follow-up steps:Deal with the missing data by a further cleaning 
step.Perform one-way ANOVA to test the difference between two country groups 
on the imdb_score.
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
Research Question:Can "budget" be used to predict the "gross" income of 
a movie ?

Rationale:This helps determine if the movies that make more money are 
associated with a higher investment for manufacturing.

Methodology:Use Proc Means to obtain the five-number summary of both 
"budget" and "gross". Then use quartiles to bin values for each variable, 
and use Proc Freq to crosstabulate bins.

Limitations:This method only uses descriptive statistics to examine the 
relationship between two numeric variables. 

Possible follow-up steps:A better approach would be to apply an 
appropriate regression model to study their relationship.
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
Research Question:Is a high "imdb_score" associated with more "gross" 
income of a movie ?

Rationale:This helps assess if a movie's ratings online matches with 
its popularity in the theater.

Methodology:Use Proc Means to compute five-number summary of imdb_score, 
and use Proc Format to bin its values by quartiles, which will be further 
stored into a new dataset. Use Proc GLM to perform a one-way ANOVA model for 
the variables "gross" and reformatted "imdb_score".

Limitations:The assumptions for one-way ANOVA model may not be valid due 
to a large variety in the data source. 

Possible follow-up steps:Check the independency,normality,and homogeneity 
of variance assumptions for the one-way ANOVA model. If the assumptions 
fail or the R-square value is small, other inferential models should be 
considered to conduct the test.
;

proc means min q1 median q3 max data=movie_analytic_file;
	var imdb_score;
run;

proc format;
	value imdb_score_bins
		low-<5.8="Q1 imdb_score"
		5.8-<6.6="Q2 imdb_score"
		6.6-<7.2="Q3 imdb_score"
		7.2-high="Q4 imdb_score"
		;
run;

data new_imdb_score_data;
	set movie_analytic_file;
		keep movie_imdb_link movie_title imdb_score gross;
		format imdb_score imdb_score_bins.;
run;
 
proc glm data=new_imdb_score_data;
	class imdb_score;
	model gross=imdb_score;
	means imdb_score/lsd;
	means imdb_score/hovtest=levene;
	output out=resids r=res;
run;

proc univariate normal plot;
	var res;
run;
*
Conclusion:ANOVA is not the appropriate model for this analysis. 
Consider other models instead.
;

