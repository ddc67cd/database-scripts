CREATE TABLE dual (dummy STRING);

LOAD DATA LOCAL INPATH '/home/hadoop/dual.txt' OVERWRITE INTO TABLE DUAL;

SELECT * FROM dual;