class MailingWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailing

  def perform(mailing_id)
    mailing = MailingLetter.find mailing_id
    User.where(activation_state: 'active').each { |user| ListMailer.delay.mailing(mailing, user) }
    mailing.update done: true
  end

end
