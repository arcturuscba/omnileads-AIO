DROP TRIGGER IF EXISTS queue_stats_ins;
DELIMITER $$
CREATE TRIGGER queue_stats_ins
AFTER INSERT ON queue_stats
FOR EACH ROW
BEGIN

SET @event_name = ''; SET @queue_name = ''; SET @agent_name = ''; SET @enterdate  = '';
SET @connectdate= ''; SET @clid       = ''; SET @position   = ''; SET @url        = '';
SET @overflow   = ''; SET @firstenter = ''; SET @lastenter  = ''; SET @did        = '';

SELECT event FROM qevent WHERE event_id = NEW.qevent INTO @event_name;
SELECT agent FROM qagent WHERE agent_id = NEW.qagent INTO @agent_name;
SELECT queue FROM qname  WHERE queue_id = NEW.qname  INTO @queue_name;

IF @event_name LIKE 'COMPLETE%' THEN

/*answered calls*/

/* Elige el primer evento ENTERQUEUE, y si elijo el ultimo? (DESC) */
SELECT datetime,info1,info2,info3,info5 FROM queue_stats JOIN qevent ON qevent=event_id WHERE event='ENTERQUEUE' 
AND uniqueid=NEW.uniqueid ORDER BY datetime LIMIT 1 INTO @enterdate,@url,@clid,@position,@did;

/* Elige el ultimo evento CONNECT */
SELECT datetime FROM queue_stats JOIN qevent ON qevent=event_id 
WHERE event='CONNECT' AND uniqueid=NEW.uniqueid ORDER BY datetime DESC LIMIT 1 INTO @connectdate;

SELECT IF(count(uniqueid)>1,1,0) FROM queue_stats JOIN qevent ON qevent=event_id WHERE event='ENTERQUEUE'
AND uniqueid=NEW.uniqueid INTO @overflow;

/*
SELECT COUNT(*),SUBSTRING_INDEX(GROUP_CONCAT(datetime),',',1),SUBSTRING_INDEX(GROUP_CONCAT(datetime),',',-1) 
FROM queue_stats LEFT JOIN qevent ON qevent = qevent.event_id  WHERE uniqueid=NEW.uniqueid AND event='ENTERQUEUE' 
INTO @overflow,@firstenter,@lastenter;
*/

REPLACE INTO queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,clid,position,url,did,overflow,info1,info2,info3,info4,info5) 
VALUES (NEW.uniqueid,@event_name,@agent_name,@queue_name,@enterdate,@connectdate,NEW.datetime,@clid,IFNULL(NEW.info3,1),IFNULL(@url,''),IFNULL(@did,''),
@overflow,IFNULL(NEW.info1,''),IFNULL(NEW.info2,''),IFNULL(NEW.info3,''),IFNULL(NEW.info4,''),IFNULL(NEW.info5,''));

ELSEIF @event_name='TRANSFER' THEN

/*transferred calls*/

SELECT datetime,info1,info2,info3,info4,info5 FROM queue_stats JOIN qevent ON qevent=event_id WHERE event='ENTERQUEUE' 
AND uniqueid=NEW.uniqueid ORDER BY datetime LIMIT 1 INTO @enterdate,@url,@clid,@position,@info4,@did;

SELECT datetime FROM queue_stats JOIN qevent ON qevent=event_id 
WHERE event='CONNECT' AND uniqueid=NEW.uniqueid ORDER BY datetime DESC LIMIT 1 INTO @connectdate;

SELECT count(*) FROM queue_stats JOIN qevent ON qevent=event_id WHERE event='ENTERQUEUE'
AND uniqueid=NEW.uniqueid INTO @overflow;

REPLACE INTO queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,clid,position,url,did,info1,info2,overflow,info3,info4,info5) 
VALUES (NEW.uniqueid,@event_name,@agent_name,@queue_name,@enterdate,@connectdate,NEW.datetime,@clid,IFNULL(@position,1),IFNULL(@url,''),IFNULL(@did,''),
IFNULL(NEW.info1,0),IFNULL(NEW.info2,0),@overflow,IFNULL(NEW.info3,''),IFNULL(NEW.info4,''),IFNULL(NEW.info5,''));

ELSEIF @event_name LIKE '%ABANDON%' OR @event_name LIKE 'EXIT%' THEN

/*unanswered calls*/

SELECT datetime,info1,info2,info3,info5 FROM queue_stats JOIN qevent ON qevent=event_id WHERE event='ENTERQUEUE' 
AND uniqueid=NEW.uniqueid ORDER BY datetime LIMIT 1 INTO @enterdate,@url,@clid,@position,@did;

SELECT count(*) FROM queue_stats JOIN qevent ON qevent=event_id WHERE event='ENTERQUEUE'
AND uniqueid=NEW.uniqueid INTO @overflow;

SET @connectdate = @enterdate;

REPLACE INTO queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,clid,position,url,did,info1,info2,overflow,info3,info4,info5) 
VALUES (NEW.uniqueid,@event_name,@agent_name,@queue_name,@enterdate,@connectdate,NEW.datetime,IFNULL(@clid,''),IFNULL(@position,1),IFNULL(@url,''),IFNULL(@did,''),
IFNULL(NEW.info1,0),IFNULL(NEW.info2,0),@overflow,IFNULL(NEW.info3,''),IFNULL(NEW.info4,''),IFNULL(NEW.info5,''));


ELSEIF @event_name LIKE 'AGENT%' OR @event_name LIKE '%PAUSE%' OR @event_name LIKE '%MEMBER%' THEN 

/* login, pausa, etc */

INSERT INTO queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,info1,info2,info3,info4,info5) 
VALUES (CONCAT_WS('.','x',UNIX_TIMESTAMP(NOW()),NEW.queue_stats_id),@event_name,@agent_name,@queue_name,NEW.datetime,NEW.datetime,NEW.datetime,
IFNULL(NEW.info1,0),IFNULL(NEW.info2,0),IFNULL(NEW.info3,''),IFNULL(NEW.info4,''),IFNULL(NEW.info5,''));

END IF;
END;
$$
DELIMITER ;


CREATE TABLE IF NOT EXISTS `queue_stats_mv` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `datetime` timestamp NOT NULL default '0000-00-00 00:00:00' on update CURRENT_TIMESTAMP,
  `datetimeconnect` timestamp NOT NULL default '0000-00-00 00:00:00',
  `datetimeend` timestamp NOT NULL default '0000-00-00 00:00:00',
  `queue` varchar(100) NOT NULL default '',
  `agent` varchar(100) NOT NULL default '',
  `event` varchar(40) NOT NULL default '',
  `uniqueid` varchar(50) NOT NULL default '',
  `clid` varchar(50) NOT NULL default '',
  `url` varchar(100) NOT NULL default '',
  `did` varchar(100) NOT NULL default '',
  `position` int(6) unsigned NOT NULL default '1',
  `info1` varchar(50) NOT NULL default '',
  `info2` varchar(50) NOT NULL default '',
  `info3` varchar(50) NOT NULL default '',
  `info4` varchar(50) NOT NULL default '',
  `info5` varchar(50) NOT NULL default '',
  `overflow` int(6) unsigned NOT NULL default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uni` (`uniqueid`),
  KEY `fecha` (`datetime`),
  KEY `ev` (`event`)
);

 
