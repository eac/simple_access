simple_access
=============

Simple interface for querying authorization models.

```ruby
authorizor = StandardAuthorizor.new(user)
authorizor.can?(:edit, Ticket)
# => true
```


### Usage

Define a mapping of classes to authorization models.

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
```

Define the authorization models. The `initialize` method requires an actor as the argument.

```ruby
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

  # This method doesn't operate on an instance,
  # so provide the class instead.
  #
  # authorizor.can?(:delete, User)
  # => true
  def delete?
    true
  end

end

class TicketPolicy

  def initialize(user)
    @user = user
  end

  # authorizor.can?(:edit, Ticket.new)
  # => false
  def edit?(ticket)
    false
  end

  # authorizor.can?(:delete, Ticket)
  # => false
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
