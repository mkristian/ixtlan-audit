require 'dm-core'
require 'dm-migrations'
require 'slf4r/ruby_logger'
require 'ixtlan/audit/manager'

class Audit
  include DataMapper::Resource

  property :id, Serial

  property :login, String
  property :path, String
  property :message, String

  property :created_at, DateTime

  before :save do
    self.created_at = DateTime.now
  end
end

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.finalize
DataMapper.repository.auto_migrate!

describe Ixtlan::Audit::Manager do

  before { subject.model = Audit }

  it 'should collect log events and the save them all in one go' do
    size = Audit.all.size
    subject.push( "login1", "path1", "msg1" )
    subject.push( "login2", "path2", "msg2" )
    subject.push( "login3", "path3", "msg3" )
    subject.save_all

    Audit.all.size.should == size + 3
  end

  it "should clean up audit logs" do
    Audit.create(:message => "msg", :login => "login")
    Audit.all.size.should > 0
    subject.keep_logs = 0
    Audit.all.size.should == 0
    subject.push( "login1", "path1", "msg1" )
    subject.push( "login2", "path2", "msg2" )
    subject.save_all
    Audit.all.size.should == 2
  end
end
