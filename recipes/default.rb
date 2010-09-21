#
# Cookbook Name:: resque
# Recipe:: default
#
if ['solo', 'util'].include?(node[:instance_role])

  %w[bluepill resque redis redis-namespace yajl-ruby].each do |install_gem|
    gem_package install_gem do
      action :install
    end
  end

  # This is specific to EngineYard.
  case node[:ec2][:instance_type]
  when 'm1.small': worker_count = 2
  when 'c1.medium': worker_count = 3
  when 'c1.xlarge': worker_count = 8
  else worker_count = 4
  end

  node[:applications].each do |app, data|

    config_path = "/data/#{app}/shared/config/resque"
    pid_path = "/var/run/resque/#{app}"
    execute "make resque directories" do
      command "mkdir -p #{config_path} #{pid_path} && chmod 755 #{config_path} #{pid_path} && chown #{node[:owner_name]}:#{node[:owner_name]} #{config_path} #{pid_path}"
    end

    template "#{config_path}/resque.pill" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "resque.pill.erb"
      variables({
        :num_workers => worker_count,
        :app_name => app,
        :rails_env => node[:environment][:framework_env],
        :owner_name => node[:owner_name],
        :bundler => false
      })
    end

    execute "ensure-bluebill-has-pill" do
      command %Q{
        bluepill load #{config_path}/resque.pill
      }
    end

  end

end
