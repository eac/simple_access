module SimpleAccess
  class Authorizor
    class AuthorizorNotFound < StandardError

      def initialize(action, klass_or_instance)
        @action            = action
        @klass_or_instance = klass_or_instance
      end

      def message
        "Cannot find authorizor for #{@action}: #{@klass_or_instance.class} #{@klass_or_instance.inspect}"
      end

    end

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def defer?(action, klass_or_instance)
      can?(action, klass_or_instance)
    end

    def can?(action, klass_or_instance)
      query_authorizor(action, klass_or_instance) || false
    end

    def query_authorizor(action, klass_or_instance)
      authorizor = find_authorizor(klass_or_instance) || raise(AuthorizorNotFound.new(action, klass_or_instance))
      method_id  = "#{action}?"
      if klass_or_instance.is_a?(Class) || static_method?(authorizor, method_id)
        authorizor.__send__(method_id)
      else
        authorizor.__send__(method_id, klass_or_instance)
      end
    end

    def static_method?(authorizor, method_id)
      authorizor.method(method_id).arity == 0
    end

    def find_authorizor(klass_or_instance)
      klass = klass_or_instance.respond_to?(:allocate) ? klass_or_instance : klass_or_instance.class

      if authorization_model = authorization_model_for(klass)
        authorizors[klass] ||= authorization_model.new(user)
        authorizors[klass]
      end
    end

    def authorization_model_for(klass)
      authorization_models[klass]
    end

    def authorization_models
      raise "Must define authorization models: { User => UserPolicy }"
    end

    def authorizors
      @authorizors ||= {}
    end

  end
end
