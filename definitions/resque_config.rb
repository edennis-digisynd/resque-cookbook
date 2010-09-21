define :resque_config, :path => nil, :owner => nil, :group => nil, :queues => "*", :workers => 1, :bundler => false, :memory_limit => 100.megabytes, :check_every => 1.minute, :restart_after => [3,5] do
  app_path = "#{params[:path]}/#{params[:name]}"
  pids_path = "#{app_path}/shared/pids"

  directory "pids_path" do
    owner params[:owner]
    group params[:group]
    mode "0755"
    recursive :true
  end

  template "#{app_path}/shared/resque.pill" do
    owner params[:owner]
    group params[:group]
    mode "0644"
    source "resque.pill.erb"
    variables({
      :app => params[:name],
      :app_path => app_path,
      :pids_path => pids_path,
      :owner => params[:owner],
      :group => params[:group],
      :bundler => params[:bundler],
      :workers => params[:workers],
      :memory_limit => params[:memory_limit],
      :check_every => params[:check_every],
      :restart_after => params[:restart_after]
    })
  end

  execute "Ensuring bluebill is monitoring resque" do
    command %Q{
      bluepill load #{app_path}/shared/resque.pill
    }
  end
end