DROP TRIGGER IF EXISTS queue_stats_ins;
DELIMITER $$
CREATE TRIGGER queue_stats_ins
AFTER INSERT ON queue_log
FOR EACH ROW
BEGIN

SET @agent_id   = '';
SET @queue_id   = '';
SET @event_id   = '';

SELECT agent_id FROM qstats.qagent WHERE agent=NEW.agent INTO @agent_id;
IF @agent_id = '' THEN
INSERT INTO qstats.qagent VALUES ('',NEW.agent);
SELECT LAST_INSERT_ID() INTO @agent_id;
END IF;

SELECT queue_id FROM qstats.qname WHERE queue=NEW.queuename INTO @queue_id;
IF @queue_id = '' THEN
INSERT INTO qstats.qname VALUES ('',NEW.queuename);
SELECT LAST_INSERT_ID() INTO @queue_id;
END IF;

SELECT event_id FROM qstats.qevent WHERE event=NEW.event INTO @event_id;
IF @event_id = '' THEN
INSERT INTO qstats.qname VALUES ('',NEW.event);
SELECT LAST_INSERT_ID() INTO @event_id;
END IF;

INSERT INTO qstats.queue_stats (uniqueid,datetime,qname,qagent,qevent,info1,info2,info3,info4,info5) VALUES
(NEW.callid,NEW.time,@queue_id,@agent_id,@event_id,NEW.data1,NEW.data2,NEW.data3,NEW.data4,NEW.data5);

END;
$$
DELIMITER ;

