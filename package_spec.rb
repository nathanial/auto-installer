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
  packages = Defaults.package_directory
  after(:each) do 
    packages.clear
  end

  describe "register" do
    it "should increment package_directory.count" do
      lambda {
        Package.new(:foo).register 
      }.should change(packages, :count).from(0).to(1)
    end
  end
end

describe "package" do 
  packages = Defaults.package_directory
  after(:each) do 
    packages.clear
  end
  
  it "should self register" do
    package(:foo) {}
    packages.count.should eql(1)
    lambda { packages[:foo] }.should_not raise_error
  end

  describe "defaults" do
    foo = nil
    before(:all) do
      foo = package(:foo) {}
    end

    it "should all equal $do_nothing" do
      foo.install_callback.should eql($do_nothing)
      lambda { foo.install }.should_not raise_error

      foo.remove_callback.should eql($do_nothing)
      lambda { foo.remove }.should_not raise_error

      foo.installed_callback.should eql($do_nothing)
      lambda { foo.installed? }.should_not raise_error
    end
  end

  describe "install" do
    it "should set install_callback" do
      package(:foo) {
        install {
          "I install"
        }
        installed? { false }
      }
      packages[:foo].install.should eql("I install")
    end
  end

  describe "remove" do
    it "should set remove_callback" do
      package(:foo) {
        remove {
          "I remove"
        }
        installed? { true }
      }
      packages[:foo].remove.should eql("I remove")
    end
  end

  describe "installed?" do 
    it "should set installed_callback" do 
      package(:foo) {
        installed? {
          "I'm installed" 
        }
      }
      packages[:foo].installed?.should eql("I'm installed")
    end
  end
    
  describe "before_install" do
    it "should add a before_install_hook" do
      foo = package(:foo) {
        before_install {}
      }
      foo.instance_eval { @before_install_hooks }.count.should eql(1)
    end
  end
  
  describe "before_install_hooks" do
    it "should be able to run before_install" do 
      order_mock = mock(:order_test)
      order_mock.should_receive(:before).ordered
      order_mock.should_receive(:install).ordered
      foo = package(:foo) {
        before_install {
          order_mock.before
        }
        install {
          order_mock.install
        }
      }
      foo.install
    end  
  end    

  describe "after_install" do 
    it "should add an after_install_hook" do 
      package(:foo) {
        after_install {}
      }
      packages[:foo].after_install_hooks.count.should eql(1)
    end
  end
    
  it "should set remove_hooks" do
    flag = false
    package(:foo) {
      before_remove {
        flag = true
      }
    }
    packages[:foo].run_remove_hooks
    flag.should be_true
  end

  describe "add_dependency" do
    it "should add new dependency" do 
      foo = package(:foo) {}
      foo.add_dependency(:bar)
      foo.dependencies.count.should eql(1)
    end
  end

end
  
describe "meta_package method" do
  packages = Defaults.package_directory
  before(:each) do
    packages.clear
  end

  it "should register a package" do
    meta_package(:foo) {}
    packages.count.should eql(1)
  end

  describe "consists_of" do
    before(:each) do 
      packages.clear
    end

    it "should be installed if all packages are installed" do 
      foo = mock(:foo)
      bar = mock(:bar)
      packages[:foo] = foo
      packages[:bar] = bar
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(true)
      packages[:baz].installed?.should be_true
    end

    it "should not be installed if any package isn't installed" do
      foo = mock(:foo)
      bar = mock(:bar)
      packages[:foo] = foo
      packages[:bar] = bar
      meta_package(:baz) { 
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(false)
      packages[:baz].installed?.should be_false
    end

    it "should install all packages" do
      foo = mock(:foo)
      bar = mock(:bar)
      packages[:foo] = foo
      packages[:bar] = bar
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(false)
      bar.stub!(:installed?).and_return(false)
      foo.should_receive(:install)
      bar.should_receive(:install)
      packages[:baz].install
    end

    it "should remove all packages" do
      foo = mock(:foo)
      bar = mock(:bar)
      packages[:foo] = foo
      packages[:bar] = bar
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(true)
      foo.should_receive(:remove)
      bar.should_receive(:remove)
      packages[:baz].remove
    end
  end
end
