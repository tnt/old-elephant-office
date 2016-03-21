class EmailCheckerWorker < BackgrounDRb::MetaWorker
  set_worker_name :email_checker_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    add_periodic_timer(120) { check_mail }
  end


  def check_mail
    logger.info '  ---------------- EmailChecker -------------------------------'
  end
end

