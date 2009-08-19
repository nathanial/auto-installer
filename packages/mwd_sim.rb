class MWDSim < Package
  name :mwd_sim
  depends_on :python, :git, :tdsurface
  repository :git, "git@github.com:teledrill/mwd-daemon.git"
  
  def install 
    ln_s TDSurface.project_directory, @project_directory
  end
end
