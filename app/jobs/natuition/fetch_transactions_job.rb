module Natuition
  class FetchTransactionsJob < ActiveJob::Base
    queue_as :default
    include Rails.application.routes.url_helpers

    def perform(user:)
      begin
        # get transactions for current cash aacounts
        Natuition::NatuitionIntegration.robot_sessions.execute do |c|
          c.success do |list|
            list.each do |robot_session|
              Natuition::NatuitionIntegration.robot_session(robot_session[:id]).execute do |d|
                d.success do |list|
                  puts list.inspect.red
                end
              end
            end
          end
        end
        user.notifications.create!(success_notification_params)
      rescue StandardError => error
        Rails.logger.error $ERROR_INFO
        Rails.logger.error $ERROR_INFO.backtrace.join("\n")
        ExceptionNotifier.notify_exception($ERROR_INFO, data: { message: error })
        user.notifications.create!(error_notification_params(error))
      end
    end

    private

    def error_notification_params(error)
      {
        message: :error_during_transactions_synchronization.tl,
        level: :error,
        interpolations: {
          message: error
        }
      }
    end

      def success_notification_params
        {
          message: :cash_transactions_synchronized.tl,
          level: :success,
          interpolations: {}
        }
      end
  end
end
