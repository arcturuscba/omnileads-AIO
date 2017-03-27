INSTALL = install
CHKCONFIG = /sbin/chkconfig
prefix  := /usr/local

PROGRAMS := precheck parselog initscripts ioncube mysql webfiles perlfinal
	
$(phony all): $(PROGRAMS)

.PHONY install: precheck parselog initscripts ioncube mysql webfiles perlfinal
.PHONY upgrade: precheckupgrade parselog initscripts webfiles

precheck:
	@echo "Checking if Asternic is already installed"
	@if [ -f /var/www/html/stats/answered.php ]; then \
		echo "Already Installed! If you want to upgrade, run 'make upgrade'"; \
		exit 1; \
	fi
	@if [ -f /var/www/stats/answered.php ]; then \
		echo "Already Installed! If you want to upgrade, run 'make upgrade'"; \
		exit 1; \
	fi

precheckupgrade:
	@echo "Checking if Asternic is installed"
	@if [ ! -f /var/www/html/stats/answered.php ] && [ ! -f /var/www/stats/answered.php ]; then \
		echo "Asternic is not installed!"; \
		exit 1; \
	fi

parselog:
	@test -d $(prefix) || mkdir -p $(prefix); 
	@$(INSTALL) -d -m 755 parselog /usr/local/parselog;
	@$(INSTALL) -m 755 parselog/* /usr/local/parselog/; 

initscripts:
	@echo "Installing init scripts..."
	@if [ -f /etc/debian_version ]; then \
		$(INSTALL) -m 755 init/asterniclog.debian /etc/init.d/asterniclog; \
		if [ ! -f /etc/default/asterniclog ]; then \
			$(INSTALL) -m 644 init/default.asterniclog /etc/default/asterniclog; \
		fi; \
		update-rc.d asterniclog defaults; \
	elif [ -f /etc/redhat-release ] || [ -f /etc/os-release ]; then \
		$(INSTALL) -m 755 init/asterniclog.redhat /etc/rc.d/init.d/asterniclog; \
		${CHKCONFIG} --add asterniclog ; \
		if [ ! -f /etc/sysconfig/asterniclog ]; then \
			$(INSTALL) -m 644 init/sysconfig.asterniclog /etc/sysconfig/asterniclog; \
		fi; \
	else \
		echo "Init script not installed, cannot detect Linux distro"; \
	fi
	@if [ ! -f /etc/freepbx.conf ]; then \
		if [ ! -f /etc/amportal.conf ]; then \
			if [ -f /etc/default/asterniclog ]; then \
				cat /etc/default/asterniclog  | sed 's/-c //' >/etc/default/asterniclognew; \
				mv -f /etc/default/asterniclognew /etc/default/asterniclog; \
 			fi; \
			if [ -f /etc/sysconfig/asterniclog ]; then \
				cat /etc/sysconfig/asterniclog  | sed 's/-c //' >/etc/sysconfig/asterniclognew; \
				mv -f /etc/sysconfig/asterniclognew /etc/sysconfig/asterniclog; \
 			fi; \
 		fi; \
 	fi

webfiles:
	@echo "Installing html files and directories..."
	@if [ -x /var/www/html ]; then \
		if [ -f /var/www/html/stats/config.php ]; then \
			cp /var/www/html/stats/config.php /var/www/html/stats/config.orig.php; \
		fi; \
		if [ -f /var/www/html/stats/custom.php ]; then \
			cp /var/www/html/stats/custom.php /var/www/html/stats/custom.orig.php; \
		fi; \
		$(INSTALL) -d -m 755 html /var/www/html/stats; \
		cp -rp html/* /var/www/html/stats/; \
		if [ -f /var/www/html/stats/config.orig.php ]; then \
			cp /var/www/html/stats/config.php /var/www/html/stats/config.new.php; \
			cp /var/www/html/stats/config.orig.php /var/www/html/stats/config.php; \
			rm /var/www/html/stats/config.orig.php; \
		fi; \
		if [ -f /var/www/html/stats/custom.php ]; then \
			cp /var/www/html/stats/custom.php /var/www/html/stats/custom.new.php; \
			cp /var/www/html/stats/custom.orig.php /var/www/html/stats/custom.php; \
			rm /var/www/html/stats/custom.orig.php; \
		fi; \
		if [ -f /etc/amportal.conf ]; then \
	        	chown asterisk.asterisk /var/www/html/stats; \
        		chown -R asterisk.asterisk /var/www/html/stats/*; \
		fi \
	elif [ -x /var/www ]; then \
		$(INSTALL) -d -m 755 html /var/www/stats; \
		$(INSTALL) --backup=numbered -m 644 html/config.php /var/www/stats/; \
		$(INSTALL) --backup=numbered -m 644 html/custom.php /var/www/stats/; \
		cp -rp html/* /var/www/stats/; \
	fi; 

ioncube:
	@php -v | grep ionCube >/dev/null; \
	if [ $$? -eq 1 ]; then \
		echo "Installing Ioncube Loader..."; \
		PHPVER=$$(php -v | head -n1 | cut -d ' ' -f2 | awk -F. '{print $$1"."$$2}'); \
		PHPSOFILE="zend_extension=/usr/local/ioncubeloader/ioncube_loader_lin_$$PHPVER.so"; \
		if [ -f /etc/debian_version ]; then \
			if [ -d /etc/php5/conf.d ]; then \
				if [ ! -f /etc/php5/conf.d/00-ioncube.ini ]; then \
					echo $$PHPSOFILE > /etc/php5/conf.d/00-ioncube.ini; \
				fi; \
			fi; \
			if [ -d /etc/php5/apache2/conf.d ]; then \
				if [ ! -f /etc/php5/apache2/conf.d/00-ioncube.ini ]; then \
					echo $$PHPSOFILE > /etc/php5/apache2/conf.d/00-ioncube.ini; \
				fi; \
			fi; \
			if [ -d /etc/php5/cli/conf.d ]; then \
				if [ ! -f /etc/php5/cli/conf.d/00-ioncube.ini ]; then \
					echo $$PHPSOFILE > /etc/php5/cli/conf.d/00-ioncube.ini; \
				fi; \
			fi; \
		elif [ -f /etc/redhat-release ]; then \
			if [ ! -f /etc/php.d/00-ioncube.ini ]; then \
				echo $$PHPSOFILE > /etc/php.d/00-ioncube.ini; \
			fi; \
		fi; \
		uname -a | grep 64; \
		if [ $$? -eq 1 ]; then \
			echo "IONCUBE 32 bits"; \
			wget -qnc http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz; \
			tar zxvf ioncube_loaders_lin_x86.tar.gz >/dev/null; \
			mkdir -p /usr/local/ioncubeloader; \
			cp -rp ioncube/*.so /usr/local/ioncubeloader/; \
		else \
			echo "IONCUBE 64 bits"; \
			wget -qnc http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz; \
			tar zxvf ioncube_loaders_lin_x86-64.tar.gz >/dev/null; \
			mkdir -p /usr/local/ioncubeloader; \
			cp -rp ioncube/*.so /usr/local/ioncubeloader/; \
		fi; \
	else \
		echo "Ioncube already installed..."; \
	fi; 
mysql:
	@echo "Creating MySQL database and tables..."
	@if [ -f /etc/elastix.conf ]; then \
		echo "Using MySQL root password from elastix.conf"; \
		NEWMYSQLROOT=$$(cat /etc/elastix.conf | grep mysqlrootpwd | cut -d= -f2); \
		export MYSQLROOT=$${NEWMYSQLROOT}; \
		export PARAMMYSQLPWD="-p$${NEWMYSQLROOT}"; \
		mysql -sss -u root $${PARAMMYSQLPWD} -e "SELECT ''"; \
    		if [ $$? -ne 0 ]; then \
			echo "Bad MySQL password in elastix.conf. Abort!"; \
			exit 1; \
		fi; \
	fi; \
	if [ "$${MYSQLROOT}" = "" ]; then \
		export x=1; \
		while [ $$x -le 3 ]; do \
			x=$$(( $$x + 1 )); \
			read -p "Please enter the MySQL root password: " MYSQLROOT; \
			if [ "$${MYSQLROOT}" = "" ]; then \
				export PARAMMYSQLPWD=""; \
			else \
				export PARAMMYSQLPWD="-p$${MYSQLROOT}"; \
			fi; \
			mysql -sss -u root $${PARAMMYSQLPWD} -e "SELECT ''"; \
	    		if [ $$? -ne 0 ]; then \
				echo "Bad MySQL password!"; \
			else \
				echo "Correct!"; \
				x=$$(( $$x + 100 )); \
			fi; \
		done; \
		if [ $${x} -lt 90 ]; then \
			echo "Bad Password. Abort"; \
			exit 1; \
		fi; \
	fi; \
	echo "Creating qstats database"; \
	mysqladmin -u root $${PARAMMYSQLPWD} create qstats; \
	if [ $$? -eq 0 ]; then \
		mysql -u root $${PARAMMYSQLPWD} qstats < sql/mysql-tables.sql; \
		mysql -u root $${PARAMMYSQLPWD} qstats < sql/trigger.sql; \
		mysql -u root $${PARAMMYSQLPWD} -e "GRANT all privileges on qstats.* to qstatsUser@localhost identified by 'qstatsPassw0rd'";\
	else \
		echo "Database already there."; \
		exit 1; \
	fi

perlfinal:
	@if [ -f /etc/redhat-release ]; then \
		yum -y install perl-Time-HiRes ; \
		yum -y install at ; \
	fi
	@if [ -f /etc/redhat-release ]; then \
		service httpd restart; \
		service asterniclog start; \
	fi
	@if [ -f /etc/debian_version ]; then \
		/etc/init.d/apache2 restart; \
		/etc/init.d/asterniclog start; \
	fi
	@if [ -f /etc/redhat-release ]; then \
		echo ""; \
		echo "Done!"; \
		echo ""; \
		echo "You must set the correct a valid manager user and secret in /var/www/html/stats/config.php"; \
		echo "for the realtime page to work correctly."; \
		echo ""; \
	else \
		echo ""; \
		echo "Done!"; \
		echo ""; \
		echo "You must set the correct a valid manager user and secret in /var/www/stats/config.php"; \
		echo "for the realtime page to work correctly."; \
		echo ""; \
	fi;
