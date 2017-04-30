*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
[Dataset Name] IMDB 5000 Movie Dataset

[Experimental Unit] 5000+ movies from IMDB website

[Number of Observations] 5,043

[Number of Features] 29

[Data Source] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset/downloads/imdb-5000-movie-dataset.zip

[Data Dictionary] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset, 
"genre" field generated from first genre in the "genres" field and added

[Unique ID Schema] The column “movie_imdb_link” is a primary key
;


*environmental setup;

*create output format;

proc format;
	value $country_bins
	"USA"="USA"
	other="Not_USA"
	;	
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
	value imdb_score_bins
		low-<5.8="Q1 imdb_score"
		5.8-<6.6="Q2 imdb_score"
		6.6-<7.2="Q3 imdb_score"
		7.2-high="Q4 imdb_score"
	;
	value grossfmt  
		low - <5333658.00				= "Gross Q1"
		5333658.00 - <25517500.00	= "Gross Q2"
		25517500.00 - <62318875.00	= "Gross Q3"
		62318875.00 - high				= "Gross Q4"
	;
run;



* setup environmental parameters;
%let inputDatasetURL =
https://github.com/stat6250/team-4_project1/blob/master/movie_metadata_edit.xls?raw=true
;

* load raw movie dataset over the wire;
filename tempfile TEMP;
proc http
	method="get"
	url="&inputDatasetURL."
	out=tempfile
	;
run;

proc import
	file=tempfile
	out=movie_data
	dbms=xls;
run;

filename tempfile clear;


* check movie dataset for duplicates with respect to its unique key;
* adding the title_year did not change the number of duplicates, 
* 	those are true duplicates;
proc sort nodupkey data=movie_data dupout=movie_data_dups out=_null_;
	by movie_imdb_link;
run;


* build analytic dataset from movie dataset with the least number of columns 
and minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;

data movie_analytic_file;
	retain 
		movie_imdb_link
		movie_title
		country
		title_year
		duration
		genre
		budget
		gross
		imdb_score
		actor_1_name
		actor_2_name
		actor_3_name
	;
	keep
		movie_imdb_link
		movie_title
		country
		title_year
		duration
		genre
		budget
		gross
		imdb_score
		actor_1_name
		actor_2_name
		actor_3_name
	;
	set movie_data;
run;



*data manipulation steps;
	
*
Use data step to store the reformatted "country" variable into a dataset;

data new_country_data;
	set movie_analytic_file;
	format country country_bins.;
run;

*
Use proc means to compute the five-number summary for both "budget" and 
"gross" to bin those two variables based on quartiles;

proc means min q1 median q3 max data=movie_analytic_file;
	var
		budget
		gross
	;
run;

*
Use proc means to obtain five-number summary of "imdb_score" to bin its 
values, and then store the reformatted variables into a new analysis-ready
dataset by a data step;

proc means min q1 median q3 max data=movie_analytic_file;
	var imdb_score;
run;
data new_imdb_score_data;
	set movie_analytic_file;
		keep movie_imdb_link movie_title imdb_score gross;
		format imdb_score imdb_score_bins.;
run;

*All data manipulation steps above will be used as part of data analysis by LW;

