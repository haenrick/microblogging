class ErrorLoggerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue => exception
    ErrorLog.log(exception, request: ActionDispatch::Request.new(env))
    raise
  end
end
