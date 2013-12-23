#!/usr/bin/env bash
#Purpose = To back up indices and set retention on logs, indices, and backups.
#Email = Twv25@drexel.edu
#Author = Tom Vasile
#P.S = Dirty script to be updated
#Version= 1.0

#START

#Initializing Variables
#Formatted dates in 1, 30, and 60 days prior.
DAY01=`date -d '01 days ago' +'%Y.%m.%d'`
DAY30=`date -d '30 days ago' +'%Y.%m.%d'`
DAY60=`date -d '60 days ago' +'%Y.%m.%d'`
#Directorys where backups, logs, and indices are stored.
INDEX_DIR="/opt/data/elasticsearch/nodes/0/indices/"
BACKUP_DIR="/opt/elasticsearch/backups"
ES_LOG_DIR="/opt/log/elasticsearch"
GRAVEYARD="/opt/elasticsearch/graveyard"
#File names 
INDEX="logstash-$DAY01"
BACKUP="$INDEX.tar.gz"
RM_INDEX="logstash-$DAY30"
RM_BACKUP="logstash-$DAY60.tar.gz"

#Check if graveyard is present. Used so rm -f doesn't end badly. ;)
if [ ! -d $GRAVEYARD ]; then
  mkdir $GRAVEYARD
fi

#Check if yesterday's index exists.
if [ -d "$INDEX_DIR/$INDEX" ]; then
  #Creating backup
  tar -cpzf "$BACKUP_DIR/$BACKUP" "$INDEX_DIR/$INDEX"
fi

#Check if index exists based on 30 day retention.
if [ -d "$INDEX_DIR/$RM_INDEX" ]; then
  #Removing Index
  mv -f "$INDEX_DIR/$RM_INDEX" "$GRAVEYARD/$RM_INDEX"
  rm -rf "$GRAVEYARD/$RM_INDEX"
  curl -XDELETE "http://localhost:9200/$RM_INDEX/"
  #Removing log if exists
  if [ -e "$ES_LOG_DIR/$RM_INDEX.log" ]; then
    mv -f "$ES_LOG_DIR/$RM_INDEX.log" "$GRAVEYARD/$RM_INDEX.log"
    rm -f "$GRAVEYARD/$RM_INDEX.log"
  fi
fi

#Check if backup exists based on 60 dat retention.
if [ -e "$BACKUP_DIR/$RM_BACKUP" ]; then
  #Removing Backup
  mv -f "$BACKUP_DIR/$RM_BACKUP" "$GRAVEYARD/$RM_BACKUP"
  rm -f "$GRAVEYARD/$RM_BACKUP"
fi
exit

#FINISHED
