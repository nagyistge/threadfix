##//////////////////////////////////////////////////////////////////////
##
##     Copyright (c) 2009-2012 Denim Group, Ltd.
##
##     The contents of this file are subject to the Mozilla Public License
##     Version 1.1 (the "License"); you may not use this file except in
##     compliance with the License. You may obtain a copy of the License at
##     http://www.mozilla.org/MPL/
##
##     Software distributed under the License is distributed on an "AS IS"
##     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
##     License for the specific language governing rights and limitations
##     under the License.
##
##     The Original Code is Vulnerability Manager.
##
##     The Initial Developer of the Original Code is Denim Group, Ltd.
##     Portions created by Denim Group, Ltd. are Copyright (C)
##     Denim Group, Ltd. All Rights Reserved.
##
##     Contributor(s): Denim Group, Ltd.
##
##//////////////////////////////////////////////////////////////////////

# custom.rb
# Ubuntu 12.04
# Denim Group 2012

# The scripts included with this project are not intended to be generic.


client_package = package "unzip" 
client_package.run_action(:install)

fabric_package = package "fabric" 
fabric_package.run_action(:install)

curl_package = package "curl" 
curl_package.run_action(:install)

git_package = package "git" 
git_package.run_action(:install)

maven_package = package "maven" 
maven_package.run_action(:install)

template "/home/vagrant/fabfile.py" do
  source "fabfile.py.erb"
  owner "root"
  group "root"
  mode "0744"
end

template "/reset-database.sh" do
  source "reset-database.sh.erb"
  owner "root"
  group "root"
  mode "0744"
end

script "run fabric" do
  interpreter "bash"
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
    fab deploy
  EOH
end

script "deploy WAR" do
  interpreter "bash"
  user "root"
  cwd "/home/vagrant"
  code <<-EOH
    fab deploy_war
	fab verify_site
  EOH
end

script "move_files" do
  interpreter "bash"
  user "root"
  cwd "/home/vagrant"
  code <<-EOH
    service tomcat6 stop
	mv /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/jdbc.properties.mysql /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/jdbc.properties
	mv /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/applicationContext-scheduling.xml.deploy /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/applicationContext-scheduling.xml
	mv /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/log4j.xml.deploy /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/log4j.xml
	chown tomcat6 /var/lib/tomcat6
	service tomcat6 start
  EOH
end

script "import_db" do
  interpreter "bash"
  user "root"
  cwd "/vagrant"
  code <<-EOH
    echo "use threadfix;" > /tmp/db.sql
	cat /tmp/db.sql /var/lib/tomcat6/webapps/threadfix/WEB-INF/classes/import-mysql.sql | /usr/bin/mysql -u threadfix -ptfpassword
  EOH
end
