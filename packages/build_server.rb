
class BuildServer < Package
  name :build_server
  depends_on :hudson, :tdsurface, :rspec_gem
  
  def install
    install_jobs
  end

  def installed?
    Packages.installed?(:hudson)
  end

  def remove 
    Packages.remove(:hudson)
  end

  def install_jobs 
    client = HTTPClient.new
    client.post('http://localhost:8080/createItem?name=autoinstaller', 
                File.open("#@support/hudson/auto-installer-config.xml").read,
                {'Content-Type' => 'text/xml'})
    client.post('http://localhost:8080/createItem?name=tdsurface',
                File.open("#@support/hudson/tdsurface-config.xml").read,
                {'Content-Type' => 'text/xml'})
  end
end
