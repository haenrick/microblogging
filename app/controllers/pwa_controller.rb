class PwaController < ApplicationController
  allow_unauthenticated_access
  layout false

  def manifest; end

  def service_worker; end
end
