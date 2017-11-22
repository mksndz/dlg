# This class wraps an ActiveRecord database transaction, and contains a workaround
# for a memory bloat issue that happens when you create a large number of ActiveRecord
# model instances within a database transaction, and those model classes use the
# paper_trail gem for versioning.
#
# This workaround temporarily removes transaction callbacks registered on ActiveRecord
# classes by paper_trail, and then manually calls these callbacks once the transaction
# has finished.  The presence of the transaction callbacks is what causes ActiveRecord
# to hold onto the model instances until the transaction finishes.  ActiveRecord will
# not hold onto the model instances if no transaction callbacks are defined.
#
# Usage:
#
# DatabaseTransaction.new.perform do
#   # Your code that creates a large number of ActiveRecord models
# end
#
# See https://github.com/airblade/paper_trail/issues/962 for more details.

class DbTransaction
  def initialize(klass)
    @callbacks = {}
    @class = klass
  end

  def perform
    fail ArgumentError, 'Missing block' unless block_given?
    begin
      clear_transaction_callbacks
      transaction_committed = false
      @class.transaction do
        begin
          yield
          transaction_committed = true
        rescue ActiveRecord::Rollback => ex
          raise ex
        end
      end
      if transaction_committed
        run_transaction_callbacks(:commit)
      else
        run_transaction_callbacks(:rollback)
      end
    ensure
      restore_transaction_callbacks
    end
  end

  private

  def clear_transaction_callbacks
    # First capture the transaction callbacks for this model class
    # so they can be restored later on
    @callbacks = {
      commit: @class._commit_callbacks.dup,
      rollback: @class._rollback_callbacks.dup
    }
    # Now clear the transaction callbacks for this model class
    @class._commit_callbacks.clear
    @class._rollback_callbacks.clear
  end

  def restore_transaction_callbacks
    if @callbacks.any?
      # Restore the commit callbacks for this model class
      commit_callbacks = @callbacks[:commit]
      commit_callbacks.each do |callback|
        @class._commit_callbacks.append(callback)
      end
      # Restore the rollback callbacks for this model class
      rollback_callbacks = @callbacks[:rollback]
      rollback_callbacks.each do |callback|
        @class._rollback_callbacks.append(callback)
      end
    end
  end

  def run_transaction_callbacks(type)
    if @callbacks.any?
      transaction_callbacks = @callbacks[type]
      transaction_callbacks.compile
    end
  end
end