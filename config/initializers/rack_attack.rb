# Rack::Attack — Brute-Force und Abuse-Schutz
# Dokumentation: https://github.com/rack/rack-attack

class Rack::Attack
  # Login: max. 10 Versuche pro 20 Sekunden pro IP
  throttle("login/ip", limit: 10, period: 20.seconds) do |req|
    req.ip if req.path == "/session" && req.post?
  end

  # Login: max. 5 Versuche pro Minute pro E-Mail-Adresse
  throttle("login/email", limit: 5, period: 1.minute) do |req|
    if req.path == "/session" && req.post?
      req.params["email_address"].to_s.downcase.strip.presence
    end
  end

  # Registrierung: max. 5 neue Accounts pro Stunde pro IP
  throttle("register/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/register" && req.post?
  end

  # Account-Lockout: nach 20 Login-Versuchen pro Stunde pro IP für 1 Stunde gesperrt
  throttle("login/ip/lockout", limit: 20, period: 1.hour) do |req|
    req.ip if req.path == "/session" && req.post?
  end

  # Antwort bei Überschreitung
  self.throttled_responder = lambda do |req|
    [ 429,
      { "Content-Type" => "text/plain" },
      [ "[!] Too many requests. Please try again later." ] ]
  end
end
