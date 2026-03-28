require 'securerandom'

module Natuition
  class NatuitionSynchronizationsController < Backend::BaseController
    def perform
      Natuition::FetchTransactionsJob.perform_later(user: current_user)
      notify_success(:cash_transactions_synchronizing.tl)

      redirect_to backend_ride_sets_path
    end
  end
end
