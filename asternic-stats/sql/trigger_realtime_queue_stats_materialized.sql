DROP TRIGGER IF EXISTS queue_stats_ins;
DELIMITER $$
CREATE TRIGGER queue_stats_ins
AFTER INSERT ON queue_log
FOR EACH ROW
BEGIN

SET @event_name = ''; SET @queue_name = ''; SET @agent_name = ''; SET @enterdate  = '';
SET @connectdate= ''; SET @clid       = ''; SET @position   = ''; SET @url        = '';
set @overflow   = ''; SET @firstenter = ''; SET @lastenter  = '';

SET @event_name = NEW.event;

IF @event_name LIKE 'COMPLETE%' THEN

/*answered calls*/

/* Elige el primer evento ENTERQUEUE, y si elijo el ultimo? (DESC) */
SELECT time,queuename,agent,data1,data2,data3 FROM queue_log WHERE event='ENTERQUEUE' 
AND callid=NEW.callid ORDER BY time DESC LIMIT 1 INTO @enterdate,@queue_name, @agent_name, @url,@clid,@position;

/* Elige el ultimo evento CONNECT */
SELECT time FROM queue_log  
WHERE event='CONNECT' AND callid=NEW.callid ORDER BY time DESC LIMIT 1 INTO @connectdate;

SELECT count(*) FROM queue_log WHERE event='ENTERQUEUE'
AND callid=NEW.callid INTO @overflow;


REPLACE INTO qstats.queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,clid,position,url,overflow) 
VALUES (NEW.callid,@event_name,NEW.agent,@queue_name,@enterdate,@connectdate,NEW.time,@clid,IFNULL(NEW.data3,1),@url,@overflow);

ELSEIF @event_name='TRANSFER' THEN

/*transferred calls*/

SELECT time,queuename,agent,data1,data2,data3 FROM queue_log WHERE event='ENTERQUEUE' 
AND callid=NEW.callid ORDER BY time LIMIT 1 INTO @enterdate,@queue_name, @agent_name,@url,@clid,@position;

SELECT time FROM queue_log  
WHERE event='CONNECT' AND callid=NEW.callid ORDER BY time DESC LIMIT 1 INTO @connectdate;

SELECT count(*) FROM queue_log WHERE event='ENTERQUEUE'
AND callid=NEW.callid INTO @overflow;

REPLACE INTO qstats.queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,clid,position,url,info1,info2,overflow) 
VALUES (NEW.callid,@event_name,NEW.agent,@queue_name,@enterdate,@connectdate,NEW.time,@clid,IFNULL(@position,1),@url,IFNULL(NEW.data1,0),IFNULL(NEW.data2,0),@overflow);

ELSEIF @event_name LIKE '%ABANDON%' OR @event_name LIKE 'EXIT%' THEN

/*unanswered calls*/

SELECT time,queuename,agent,data1,data2,data3 FROM queue_log WHERE event='ENTERQUEUE' 
AND callid=NEW.callid ORDER BY time LIMIT 1 INTO @enterdate,@queue_name, @agent_name, @url,@clid,@position;

SELECT count(*) FROM queue_log WHERE event='ENTERQUEUE'
AND callid=NEW.callid INTO @overflow;

SET @connectdate = @enterdate;

REPLACE INTO qstats.queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,clid,position,url,info1,info2,overflow) 
VALUES (NEW.callid,@event_name,@agent_name,@queue_name,@enterdate,@connectdate,NEW.time,IFNULL(@clid,''),IFNULL(@position,1),@url,IFNULL(NEW.data1,0),IFNULL(NEW.data2,0),@overflow);

ELSEIF @event_name LIKE 'AGENT%' OR @event_name LIKE '%PAUSE%' OR @event_name LIKE '%MEMBER%' THEN 

/* login, pausa, etc */

INSERT INTO qstats.queue_stats_mv (uniqueid,event,agent,queue,datetime,datetimeconnect,datetimeend,info1,info2) 
VALUES (CONCAT_WS('.','x',UNIX_TIMESTAMP(NOW()),NEW.callid),NEW.event,NEW.agent,NEW.queuename,NEW.time,NEW.time,NEW.time,IFNULL(NEW.data1,0),IFNULL(NEW.data2,0));

END IF;
END;
$$
DELIMITER ;

CREATE TABLE `qstats.queue_stats_mv` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `datetimeconnect` timestamp NOT NULL default '0000-00-00 00:00:00',
  `datetimeend` timestamp NOT NULL default '0000-00-00 00:00:00',
  `queue` varchar(100) NOT NULL default '',
  `agent` varchar(100) NOT NULL default '',
  `event` varchar(40) NOT NULL default '',
  `uniqueid` varchar(50) NOT NULL default '',
  `clid` varchar(50) NOT NULL default '',
  `url` varchar(100) NOT NULL default '',
  `position` int(6) unsigned NOT NULL default '1',
  `info1` varchar(50) NOT NULL default '',
  `info2` varchar(50) NOT NULL default '',
  `overflow` int(6) unsigned NOT NULL default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uni` (`uniqueid`),
  KEY `fecha` (`datetime`)
);


