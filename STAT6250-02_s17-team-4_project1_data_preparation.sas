*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
[Dataset Name] IMDB 5000 Movie Dataset

[Experimental Unit] 5000+ movies from IMDB website

[Number of Observations] 5,043

[Number of Features] 28

[Data Source] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset/downloads/imdb-5000-movie-dataset.zip

[Data Dictionary] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset

[Unique ID Schema] The column “movie_imdb_link” is a primary key
;

* setup environmental parameters;
%let inputDatasetURL =
https://github.com/stat6250/team-4_project1/blob/master/movie_metadata.xls?raw=true
;

* load raw Flights dataset over the wire;
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


* check raw flights dataset for duplicates with respect to its composite key;
proc sort nodupkey data=movie_data dupout=movie_data_dups out=_null_;
	by movie_imdb_link;
run;


* build analytic dataset from Homicide dataset with the least number of columns and
minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;

data movie_analytic_file;
	retain 
		movie_imdb_link
		movie_title
		country
		title_year
		duration
		genres
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
		genres
		budget
		gross
		imdb_score
		actor_1_name
		actor_2_name
		actor_3_name
	;
	set movie_data;
run;


		
