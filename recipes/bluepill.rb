directory "/var/bluepill" do
  owner "deploy"
  group "deploy"
  mode 0755
  recursive true
end

execute "touch /var/log/bluepill.log; chown deploy:deploy /var/log/bluepill.log"
