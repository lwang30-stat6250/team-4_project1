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



title1
'Research Question:Does US movies have a higher imdb_score than other country movies ?'
;

title2
'Rationale:This indicates how the US-made movies are different from the other country movies based on the audience ratings.'
;

footnote1
'Based on the above output, we can see that all the five numbers (min,q1,median,q3,max) of non-US-made movies are higher than that of US-made movies.'
;

footnote2
'In a conclusion, the other country movies actually have a higher imdb_score than US movies, indicating a high quality of film production all over the world.'
;

*
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

proc means min q1 median q3 max data=new_country_data;
	class country;
	var imdb_score;
run;
title;
footnote;


title1
'Research Question:Can "budget" be used to predict the "gross" income of a movie ?'
;

title2
'Rationale:This helps determine if the movies that make more money are associated with a higher investment for manufacturing.'
;

footnote1
'Based on the output, we see that at the Q1 budget level, the Q1 quartile of gross has the largest frequency. At the Q2 budget level, the Q2 quartile of gross has the largest frequency. At the Q3 budget level, the Q3 quartile of gross has the largest frequency. At the Q4 budget level, the Q4 quartile of gross has the largest frequency.'
;

footnote2
'Although the exact number of gross income can not be determined by budget, we can still observe a trend that as the budget level goes up, the gross will increase, and there should be a positive relationship between the two variables.'
;

*
Methodology:Use Proc Means to obtain the five-number summary of both 
"budget" and "gross". Then use quartiles to bin values for each variable, 
and use Proc Freq to crosstabulate bins.

Limitations:This method only uses descriptive statistics to examine the 
relationship between two numeric variables. 

Possible follow-up steps:A better approach would be to apply an 
appropriate regression model to study their relationship.
;

proc freq data=movie_analytic_file;
	table budget*gross/missing norow nocol nopercent;
	format 
		budget budget_bins.
		gross gross_bins.
	;
run;
title;
footnote;


title1
'Research Question:Is a high "imdb_score" associated with more "gross" income of a movie ?'
;

title2
'Rationale:This helps assess if the online rating of a movie matches with its popularity in the theater.'
;

footnote1
'Based on the output, we see from the side-by-side boxplot that Q4 imdb_score group is apparently associated with a higher gross income than Q1 imdb_score group, but each group has many outliers, indicating the response values are not normally distributed.'
;

footnote2
'From the ANOVA table, the R-square value is 0.032875, meaning that only 3.3% of the data can be explained by the model.'
;

footnote3
'From the qqplot, the residuals do not follow a normal distribution at all, and our assumption for performing one-way ANOVA fails. Thus, we should consider other models or a transformation of the data instead.'
;

*
Methodology:Use Proc Means to compute five-number summary of imdb_score, 
and use Proc Format to bin its values by quartiles, which will be further 
stored into a new dataset. Use Proc GLM to perform a one-way ANOVA model 
for the variables "gross" and reformatted "imdb_score".

Limitations:The assumptions for one-way ANOVA model may not be valid due 
to a large variety in the data source. 

Possible follow-up steps:Check the independency,normality,and homogeneity 
of variance assumptions for the one-way ANOVA model. If the assumptions 
fail or the R-square value is small, other inferential models should be 
considered to conduct the test.
;

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
title;
footnote;

