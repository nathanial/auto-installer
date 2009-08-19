require 'rubygems'
require 'package'

describe "the all predicate" do
  it "should guarantee all are true" do
    all(1..10, lambda {|x| x > 0}).should be_true
  end
  it "should guarantee none are false" do
    all(1..10, lambda {|x| x > 1}).should be_false
  end
end

describe "the some predicate" do 
  it "should guarantee at least one is true" do
    some([true, false], lambda {|x| x}).should be_true
    some([false, false], lambda {|x| x}).should be_false
  end
end

describe Package do 
  after(:each) do 
    Packages.clear
  end

  describe "register" do
    it "should increment package_directory.count" do
      lambda {
        Packages.register(:foo, Package.new(:foo))
      }.should change(Packages, :count).from(0).to(1)
    end
  end
end

describe "package" do 
  after(:each) do 
    Packages.clear
  end
  
  it "should self register" do
    Packages.register(:foo, Package.new(:foo))
    Packages.count.should eql(1)
    lambda { Packages.lookup(:foo) }.should_not raise_error
  end

  describe "defaults" do
    foo = nil
    before(:all) do
      foo = Package.new(:foo)
      Packages.register(:foo, foo)
    end

    it "should all be absent" do
      lambda { foo.install }.should raise_error

      lambda { foo.remove }.should raise_error

      lambda { foo.installed? }.should raise_error
    end
  end

  describe "install" do
    it "should set install_callback" do
      class Installer < Package
        def install 
          "I install"
        end
        def remove 
          "nothing"
        end
        def installed?
          false
        end
      end
      Packages.register(:installer, Installer.new(:installer))
      Packages.install(:installer).should eql("I install")
    end
  end

  describe "remove" do
    it "should set remove_callback" do
      class Remover < Package
        def install 
          "nothing"
        end
        def remove 
          "I remove"
        end
        def installed?
          true
        end
      end
      Packages.register(:remover, Remover.new(:remover))
      Packages.remove(:remover).should eql("I remove")
    end
  end

  describe "installed?" do 
    it "should set installed_callback" do 
      class Installed < Package
        def installed? 
          "I'm installed" 
        end
      end
      Packages.register(:installed?, Installed.new(:installed?))
      Packages.installed?(:installed?).should eql("I'm installed")
    end
  end
    
  describe "add_dependency" do
    it "should add new dependency" do 
      foo = Package.new(:foo)
      foo.add_dependency(:bar)
      foo.dependency_names.count.should eql(1)
    end
  end

  describe "depends_on" do
    it "should add new dependencies" do
      a = Package.new(:a)
      b = Package.new(:b)
      c = Package.new(:c)
      class Depender < Package
        depends_on :a, :b, :c
      end
      foo = Depender.new(:depender)
      foo.dependency_names.count.should eql(3)
    end      
  end
end
 
