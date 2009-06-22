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
    Package.clear_registered_packages
  end

  describe "register" do
    it "should increment @@registered_packages.count" do
      lambda {
        Package.new(:foo).register
      }.should change(Package.registered_packages, :count).from(0).to(1)
    end
  end
end

describe "package method" do 
  after(:each) do 
    Package.clear_registered_packages
  end
  
  it "should register a new package" do
    package(:foo) {}
    Package.registered_packages.count.should eql(1)
    lambda { Package.lookup(:foo) }.should_not raise_error
  end

  describe "defaults" do
    foo = nil
    before(:all) do
      foo = package(:foo) {}
    end

    it "should set install to do_nothing" do
      foo.install_callback.should eql($do_nothing)
      lambda { foo.install }.should_not raise_error
    end

    it "should set remove to do_nothing" do 
      foo.remove_callback.should eql($do_nothing)
      lambda { foo.remove }.should_not raise_error
    end

    it "should set installed? to do_nothing" do 
      foo.installed_callback.should eql($do_nothing)
      lambda { foo.installed? }.should_not raise_error
    end
  end

  it "should set install_callback" do
    package(:foo) {
      install {
        "I install"
      }
      installed? { false }
    }
    Package.install(:foo).should eql("I install")
  end

  it "should set remove_callback" do
    package(:foo) {
      remove {
        "I remove"
      }
      installed? { true }
    }
    Package.remove(:foo).should eql("I remove")
  end

  it "should set installed_callback" do 
    package(:foo) {
      installed? {
        "I'm installed" 
      }
    }
    Package.installed?(:foo).should eql("I'm installed")
  end

  it "should set install_hooks" do 
    flag = false
    package(:foo) {
      before_install {
        flag = true
      }
    }
    Package.run_install_hooks(:foo)
    flag.should be_true
  end

  it "should set remove_hooks" do
    flag = false
    package(:foo) {
      before_remove {
        flag = true
      }
    }
    Package.run_remove_hooks(:foo)
    flag.should be_true
  end
end
  
describe "meta_package method" do
  before(:each) do
    Package.clear_registered_packages
  end

  it "should register a package" do
    meta_package(:foo) {}
    Package.registered_packages.count.should eql(1)
  end

  describe "consists_of" do
    before(:each) do 
      Package.clear_registered_packages
    end

    it "should be installed if all packages are installed" do 
      foo = mock(:foo)
      bar = mock(:bar)
      Package.registered_packages[:foo] = foo
      Package.registered_packages[:bar] = bar
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(true)
      Package.installed?(:baz).should eql(true)
    end

    it "should install all packages" do
      foo = mock(:foo)
      bar = mock(:bar)
      Package.registered_packages[:foo] = foo
      Package.registered_packages[:bar] = bar
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(false)
      bar.stub!(:installed?).and_return(false)
      foo.should_receive(:install)
      bar.should_receive(:install)
      Package.install(:baz)
    end

    it "should remove all packages" do
      foo = mock(:foo)
      bar = mock(:bar)
      Package.registered_packages[:foo] = foo
      Package.registered_packages[:bar] = bar
      meta_package(:baz) {
        consists_of :foo, :bar
      }
      foo.stub!(:installed?).and_return(true)
      bar.stub!(:installed?).and_return(true)
      foo.should_receive(:remove)
      bar.should_receive(:remove)
      Package.remove(:baz)
    end
  end
end
