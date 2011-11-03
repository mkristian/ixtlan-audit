require 'dm-core'
require 'dm-migrations'
require 'slf4r/ruby_logger'
require 'ixtlan/audit/manager'

class Audit
  include DataMapper::Resource

  property :id, Serial

  property :login, String
  property :message, String

  property :created_at, DateTime

  before :save do
    self.created_at = DateTime.now
  end
end

class Fixnum
  def days
    self
  end
  def ago
    DateTime.now - 86000 * self
  end
end
DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.finalize
DataMapper.repository.auto_migrate!

describe Ixtlan::Audit::Manager do

  it 'should collect log events and the save them all in one go' do
    size = Audit.all.size
    subject.push("msg1", "login1")
    subject.push("msg2", "login2")
    subject.push("msg3", "login3")
    subject.save_all

    Audit.all.size.should == size + 3
  end

  it "should clean up audit logs" do
    Audit.create(:message => "msg", :login => "login")
    Audit.all.size.should > 0
    subject.keep_logs = 0
    Audit.all.size.should == 0
    subject.push("msg", "login")
    subject.push("msg", "login")
    subject.save_all
    Audit.all.size.should == 2
  end
end
