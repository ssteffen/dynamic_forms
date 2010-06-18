%w{ models controllers helpers views }.each do |dir|
  path = File.join(directory, 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  if dir =~ /controllers/
    config.controller_paths << path
  end
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end