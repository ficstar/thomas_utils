module ThomasUtils
  module Observer
    extend Forwardable

    def_delegators :@observation,
                   :on_success,
                   :on_failure,
                   :on_complete,
                   :on_timed,
                   :join,
                   :then,
                   :none_fallback,
                   :fallback,
                   :ensure,
                   :on_success_ensure,
                   :on_failure_ensure
  end
end
