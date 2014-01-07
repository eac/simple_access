simple_access
=============

Simple interface for querying authorization models.

Example:
```ruby
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

  # user = User.new
  # user.editable = false
  #
  # authorizor.can?(:edit, user)
  # => false
  def edit?(other_user)
    other_user.editable == true
  end

  # authorizor.can?(:delete, User)
  def delete?
    true
  end

end

class TicketPolicy

  def initialize(user)
    @user = user
  end

  # authorizor.can?(:edit, Ticket.new)
  def edit?(ticket)
    false
  end

  # authorizor.can?(:delete, Ticket)
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
```
