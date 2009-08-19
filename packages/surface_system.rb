require 'package'

class SurfaceSystem < Package
  name :surface_system
  depends_on :tdsurface, :pason_daemon, :toolserver, :mwd_daemon

  def installed?
    (Packages.installed?(:tdsurface) and
     Packages.installed?(:pason_daemon) and
     Packages.installed?(:toolserver) and
     Packages.installed?(:mwd_daemon))
  end
end
