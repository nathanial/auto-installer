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
        Package.new(:foo).register 
      }.should change(Packages, :count).from(0).to(1)
    end
  end
end

describe "package" do 
  after(:each) do 
    Packages.clear
  end
  
  it "should self register" do
    package(:foo) {}
    Packages.count.should eql(1)
    lambda { Packages.lookup(:foo) }.should_not raise_error
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
      Packages.install(:foo).should eql("I install")
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
      Packages.remove(:foo).should eql("I remove")
    end
  end

  describe "installed?" do 
    it "should set installed_callback" do 
      package(:foo) {
        installed? {
          "I'm installed" 
        }
      }
      Packages.installed?(:foo).should eql("I'm installed")
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
      Packages.lookup(:foo).after_install_hooks.count.should eql(1)
    end
  end
    
  it "should set remove_hooks" do
    flag = false
    package(:foo) {
      before_remove {
        flag = true
      }
    }
    Packages.run_remove_hooks(:foo)
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
  before(:each) do
    Packages.clear
  end

  it "should register a package" do
    meta_package(:foo) {}
    Packages.count.should eql(1)
  end

  describe "consists_of" do
    before(:each) do 
      Packages.clear
    end

    it "should be installed if all packages are installed" do 
      foo = mock(:foo)
      bar = mock(:bar)
      Packages.register(:foo,foo)
      Packages.register(:bar,bar)
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(true)
      Packages.installed?(:baz).should be_true
    end

    it "should not be installed if any package isn't installed" do
      foo = mock(:foo)
      bar = mock(:bar)
      Packages.register(:foo,foo)
      Packages.register(:bar,bar)
      meta_package(:baz) { 
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(false)
      Packages.installed?(:baz).should be_false
    end

    it "should install all packages" do
      foo = mock(:foo)
      bar = mock(:bar)
      Packages.register(:foo,foo)
      Packages.register(:bar,bar)
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(false)
      bar.stub!(:installed?).and_return(false)
      foo.should_receive(:install)
      bar.should_receive(:install)
      Packages.install(:baz)
    end

    it "should remove all packages" do
      foo = mock(:foo)
      bar = mock(:bar)
      Packages.register(:foo,foo)
      Packages.register(:bar,bar)
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(true)
      foo.should_receive(:remove)
      bar.should_receive(:remove)
      Packages.remove(:baz)
    end
  end
end
