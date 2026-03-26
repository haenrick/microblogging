# Content Security Policy — schützt gegen XSS-Angriffe
# Erlaubt nur Ressourcen von vertrauenswürdigen Quellen.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, "https://fonts.gstatic.com"
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, "https://fonts.googleapis.com"
    policy.connect_src :self
    policy.frame_ancestors :none
  end

  # Nonce für inline Scripts (Turbo, Stimulus)
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
