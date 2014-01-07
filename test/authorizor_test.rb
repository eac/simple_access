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

    describe "when checking an instance" do

      it "queries the authorization model mapped to the instance's class" do
        assert_equal true,  @authorizor.can?(:edit, User.new)
        assert_equal false, @authorizor.can?(:edit, Ticket.new)
      end

      it "provides the instance to the permission check method" do
        user = User.new
        assert_equal true,  @authorizor.can?(:edit, user)

        user = User.new
        user.editable = false

        assert_equal false, @authorizor.can?(:edit, user)
      end

    end

    describe "when checking a class" do

      it "queries the mapped authorization model" do
        assert_equal true,  @authorizor.can?(:delete, User)
        assert_equal false, @authorizor.can?(:delete, Ticket)
      end

      it "does not provide the class to the permission check method" do
        # This would just blow up otherwise
        assert_equal true, @authorizor.can?(:delete, User)
      end

    end

    it "raises an AuthorizorNotFound error when no corresponding authorization model is defined" do
      assert_raises(SimpleAccess::Authorizor::AuthorizorNotFound) do
        @authorizor.can?(:edit, Object)
      end
    end

  end


end
