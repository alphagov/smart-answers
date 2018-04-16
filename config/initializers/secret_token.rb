# We don't use sessions in this application, but Rails needs a secret key base anyway.
SmartAnswers::Application.config.secret_key_base = SecureRandom.hex
