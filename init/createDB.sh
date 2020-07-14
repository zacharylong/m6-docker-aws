#!/usr/bin/bash

#set up the database by creating a user and a database (M2) 
#create user image_gallery login password 'simple';
#create database image_gallery owner image_gallery;

psql -d postgresql://$IG_USER:$IG_PASSWD@$PG_HOST:$PG_PORT/$IG_DATABASE create user image_gallery login password 'n,|gRz$#_Bc&EmAjyI)t[j3vCv^4ty4n';
psql -d postgresql://$IG_USER:$IG_PASSWD@$PG_HOST:$PG_PORT/$IG_DATABASE create database image_gallery owner image_gallery;
psql -d postgresql://$IG_USER:$IG_PASSWD@$PG_HOST:$PG_PORT/$IG_DATABASE -f create_tables.sql