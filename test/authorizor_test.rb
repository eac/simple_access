require_relative 'helper'
require 'simple_access/authorizor'

class StandardAuthorizor < SimpleAccess::Authorizor

  def authorization_models
    @authorization_models ||= {
      User   => UserPolicy,
      Ticket => TicketPolicy
    }
  end

end

class UserPolicy

  def initialize(user)
    @user = user
  end

  def edit?(other_user)
    other_user.editable == true
  end

  def delete?
    true
  end

end

class TicketPolicy

  def initialize(user)
    @user = user
  end

  def edit?(ticket)
    false
  end

  def delete?
    false
  end

end

class User

  attr_accessor :editable

  def editable
    defined?(@editable) ? @editable : true
  end

end

class Ticket
end

describe SimpleAccess::Authorizor do
  before do
    user        = User.new
    @authorizor = StandardAuthorizor.new(user)
  end

  describe "can?" do

    it "queries the mapped authorization model" do
      assert_equal true,  @authorizor.can?(:edit, User.new)
      assert_equal false, @authorizor.can?(:edit, Ticket.new)

      assert_equal true,  @authorizor.can?(:delete, User)
      assert_equal false, @authorizor.can?(:delete, Ticket)
    end

    it "provides the parameter to the check when it's an instance" do
      user = User.new
      assert_equal true,  @authorizor.can?(:edit, user)

      user = User.new
      user.editable = false

      assert_equal false, @authorizor.can?(:edit, user)
    end

    it "only provides the parameter when the check accepts it" do
      # This would just blow up otherwise
      assert_equal true, @authorizor.can?(:delete, User.new)
    end

    it "raises an AuthorizorNotFound error when no corresponding authorization model is defined" do
      assert_raises(SimpleAccess::Authorizor::AuthorizorNotFound) do
        @authorizor.can?(:edit, Object)
      end
    end

  end


end
