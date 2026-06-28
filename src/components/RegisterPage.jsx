import { useState } from "react";
import { useAuth } from "../context/AuthContext";

const inputStyle = {
  width: "100%", height: 40, padding: "0 12px", borderRadius: 10,
  background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)",
  color: "#F1F5F9", fontSize: 13, outline: "none", boxSizing: "border-box",
  transition: "all 0.2s ease", fontFamily: "inherit",
};

const labelStyle = {
  display: "block", fontSize: 11, color: "rgba(241,245,249,0.55)",
  fontWeight: 600, marginBottom: 5, letterSpacing: "0.2px",
};

const focusProps = {
  onFocus: (e) => { e.target.style.borderColor = "rgba(99,102,241,0.5)"; e.target.style.background = "rgba(99,102,241,0.06)"; e.target.style.boxShadow = "0 0 0 3px rgba(99,102,241,0.12)"; },
  onBlur: (e) => { e.target.style.borderColor = "rgba(255,255,255,0.08)"; e.target.style.background = "rgba(255,255,255,0.04)"; e.target.style.boxShadow = "none"; },
};

const INDIGO = "#6366F1";
const INDIGO_LIGHT = "#818CF8";

function Logo({ size = 28 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <defs>
        <linearGradient id="logoGradR" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor={INDIGO_LIGHT}/>
          <stop offset="100%" stopColor={INDIGO}/>
        </linearGradient>
      </defs>
      <polyline points="6,34 16,34 22,20 28,48 34,26 38,38 44,30 50,34 58,34"
        fill="none" stroke="url(#logoGradR)" strokeWidth="4.5"
        strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function Background() {
  return (
    <>
      <div className="bg-grid" style={{ position: "fixed", inset: 0, opacity: 0.6, pointerEvents: "none", zIndex: 0 }} />
      <div style={{ position: "fixed", top: 0, left: 0, width: "100%", height: "100%", pointerEvents: "none", zIndex: 0 }}>
        <div style={{ position: "absolute", top: "-200px", left: "-200px", width: 720, height: 720, borderRadius: "50%", background: INDIGO, filter: "blur(150px)", opacity: 0.32 }} />
        <div style={{ position: "absolute", bottom: "-180px", right: "-180px", width: 560, height: 560, borderRadius: "50%", background: "#0EA5E9", filter: "blur(150px)", opacity: 0.22 }} />
      </div>
      <div style={{ position: "fixed", top: "50%", left: "50%", transform: "translate(-50%, -50%)", fontSize: 180, fontWeight: 800, letterSpacing: 28, color: "white", opacity: 0.025, whiteSpace: "nowrap", userSelect: "none", pointerEvents: "none", zIndex: 0 }}>UNIPULSE</div>
    </>
  );
}

export default function RegisterPage({ onSwitch }) {
  const { register, loginWithGoogle } = useAuth();
  const [fullName, setFullName] = useState("");
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [terms, setTerms] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [basarili, setBasarili] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");

    if (password !== confirmPassword) {
      setError("Şifreler eşleşmiyor");
      return;
    }

    if (!terms) {
      setError("Kullanım koşullarını kabul etmeniz gerekiyor");
      return;
    }

    if (!username || !/^[a-zA-Z0-9_.-]+$/.test(username)) {
      setError("Lütfen geçerli bir kullanıcı adı girin (Boşluksuz harf, rakam, alt çizgi).");
      return;
    }

    setLoading(true);
    try {
      const data = await register(email, password, fullName, username, null);
      if (data.session) {
        // Otomatik giriş yapıldı
      } else {
        setBasarili(true);
      }
    } catch (err) {
      setError(err.message === "User already registered" ? "Bu e-posta adresi zaten kayıtlı" : err.message);
    } finally {
      setLoading(false);
    }
  }

  if (basarili) {
    return (
      <div style={{
        minHeight: "100vh", background: "#070B14",
        fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
        display: "flex", alignItems: "center", justifyContent: "center",
        position: "relative", overflow: "hidden",
      }}>
        <Background />
        <div style={{
          width: 400, background: "rgba(15, 22, 35, 0.7)",
          backdropFilter: "blur(24px) saturate(180%)", WebkitBackdropFilter: "blur(24px) saturate(180%)",
          borderRadius: 20, border: "1px solid rgba(255,255,255,0.08)",
          padding: "32px 32px 28px", position: "relative", zIndex: 1,
          boxShadow: "0 25px 50px -12px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04) inset, 0 0 80px rgba(99,102,241,0.08)",
          textAlign: "center",
        }}>
          <div style={{
            width: 60, height: 60, borderRadius: 16,
            background: "rgba(16,185,129,0.1)", border: "1px solid rgba(16,185,129,0.25)",
            display: "flex", alignItems: "center", justifyContent: "center",
            margin: "0 auto 22px",
          }}>
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#34D399" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
          </div>
          <h1 style={{ margin: "0 0 10px", fontSize: 21, fontWeight: 700, color: "#F1F5F9", letterSpacing: -0.3 }}>Hesabınız Oluşturuldu!</h1>
          <p style={{ margin: "0 0 6px", fontSize: 13, color: "rgba(241,245,249,0.6)", lineHeight: 1.55 }}>
            <strong style={{ color: "#F1F5F9" }}>{email}</strong> adresine doğrulama e-postası gönderdik.
          </p>
          <p style={{ margin: "0 0 22px", fontSize: 12, color: "rgba(241,245,249,0.4)", lineHeight: 1.55 }}>
            E-posta kutunuzu kontrol edin ve doğrulama bağlantısına tıklayın.
          </p>
          <div style={{ background: "rgba(245,158,11,0.06)", border: "1px solid rgba(245,158,11,0.18)", borderRadius: 10, padding: "12px 16px", marginBottom: 22, display: "flex", alignItems: "center", gap: 8 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FBBF24" strokeWidth="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <div style={{ fontSize: 12, color: "#FBBF24", fontWeight: 500 }}>E-posta gelen kutunuzda görünmüyorsa spam klasörünü kontrol edin.</div>
          </div>
          <button onClick={onSwitch} style={{
            width: "100%", height: 46, borderRadius: 10, border: "none",
            background: `linear-gradient(135deg, ${INDIGO} 0%, ${INDIGO_LIGHT} 100%)`,
            color: "#fff", cursor: "pointer", fontWeight: 600, fontSize: 14,
            fontFamily: "inherit", boxShadow: "0 8px 20px rgba(99,102,241,0.35), 0 0 0 1px rgba(99,102,241,0.2) inset",
          }}>Giriş Yap</button>
        </div>
      </div>
    );
  }

  return (
    <div style={{
      minHeight: "100vh", background: "#070B14",
      fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
      display: "flex", alignItems: "center", justifyContent: "center",
      position: "relative", overflow: "hidden",
    }}>
      <Background />

      {/* Card */}
      <div style={{
        width: 460, background: "rgba(15, 22, 35, 0.7)",
        backdropFilter: "blur(24px) saturate(180%)", WebkitBackdropFilter: "blur(24px) saturate(180%)",
        borderRadius: 20, border: "1px solid rgba(255,255,255,0.08)",
        padding: "28px 32px 26px", position: "relative", zIndex: 1,
        boxShadow: "0 25px 50px -12px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04) inset, 0 0 80px rgba(99,102,241,0.08)",
        maxHeight: "92vh", overflowY: "auto",
      }}>
        {/* Brand */}
        <div style={{ textAlign: "center", marginBottom: 22 }}>
          <div style={{
            display: "inline-flex", justifyContent: "center", alignItems: "center",
            width: 48, height: 48, background: "rgba(99,102,241,0.08)",
            borderRadius: 13, marginBottom: 12, border: "1px solid rgba(99,102,241,0.2)",
            boxShadow: "0 8px 24px rgba(99,102,241,0.18)",
          }}>
            <Logo size={28} />
          </div>
          <h1 style={{
            margin: "0 0 4px", fontSize: 21, fontWeight: 700, letterSpacing: "-0.5px",
            color: "#F1F5F9",
          }}>UniPulse</h1>
          <p style={{ margin: 0, fontSize: 11.5, color: "rgba(241,245,249,0.5)" }}>
            Üniversite hayatının kontrol merkezi
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit}>
          {/* Ad Soyad */}
          <div style={{ marginBottom: 12 }}>
            <label style={labelStyle}>Ad Soyad</label>
            <input type="text" value={fullName} onChange={(e) => setFullName(e.target.value)} placeholder="Adınız Soyadınız" required style={inputStyle} {...focusProps} />
          </div>

          {/* E-posta */}
          <div style={{ marginBottom: 12 }}>
            <label style={labelStyle}>E-posta</label>
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="ornek@university.edu.tr" required style={inputStyle} {...focusProps} />
          </div>

          {/* Şifre / Şifre Tekrar */}
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 12 }}>
            <div>
              <label style={labelStyle}>Şifre</label>
              <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="••••••••" required minLength={6} style={inputStyle} {...focusProps} />
            </div>
            <div>
              <label style={labelStyle}>Şifre Tekrar</label>
              <input type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} placeholder="••••••••" required minLength={6} style={inputStyle} {...focusProps} />
            </div>
          </div>

          {/* Kullanıcı Adı */}
          <div style={{ marginBottom: 12 }}>
            <label style={labelStyle}>Kullanıcı Adı</label>
            <input type="text" value={username} onChange={(e) => setUsername(e.target.value)} placeholder="kullanici_adi" required style={inputStyle} {...focusProps} />
          </div>

          {/* Agreement */}
          <div style={{ marginBottom: 16 }}>
            <label style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 11.5, color: "rgba(241,245,249,0.55)", cursor: "pointer", userSelect: "none" }}>
              <input type="checkbox" checked={terms} onChange={(e) => setTerms(e.target.checked)} style={{ display: "none" }} />
              <span style={{
                width: 15, height: 15, border: "1.5px solid rgba(255,255,255,0.12)",
                borderRadius: 5, display: "flex", justifyContent: "center", alignItems: "center",
                transition: "all 0.2s ease", background: "rgba(255,255,255,0.04)", flexShrink: 0,
                ...(terms ? { background: `linear-gradient(135deg, ${INDIGO}, ${INDIGO_LIGHT})`, borderColor: "transparent" } : {}),
              }}>
                {terms && <svg width="9" height="9" viewBox="0 0 10 10" fill="none"><path d="M2 5L4 7L8 3" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>}
              </span>
              <span>Kullanım koşullarını kabul ediyorum</span>
            </label>
          </div>

          {error && (
            <div style={{ background: "rgba(239,68,68,0.08)", border: "1px solid rgba(239,68,68,0.2)", borderRadius: 10, padding: "10px 14px", marginBottom: 14, color: "#FCA5A5", fontSize: 12, display: "flex", alignItems: "center", gap: 8 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
              {error}
            </div>
          )}

          <button type="submit" disabled={loading} style={{
            width: "100%", height: 44, borderRadius: 10, border: "none",
            background: loading ? "rgba(99,102,241,0.3)" : `linear-gradient(135deg, ${INDIGO} 0%, ${INDIGO_LIGHT} 100%)`,
            color: "#fff", cursor: loading ? "default" : "pointer",
            fontWeight: 600, fontSize: 13.5, fontFamily: "inherit",
            transition: "all 0.25s ease",
            boxShadow: loading ? "none" : "0 8px 20px rgba(99,102,241,0.35), 0 0 0 1px rgba(99,102,241,0.2) inset",
          }}
            onMouseEnter={(e) => { if (!loading) { e.currentTarget.style.transform = "translateY(-1px)"; e.currentTarget.style.boxShadow = "0 12px 28px rgba(99,102,241,0.45), 0 0 0 1px rgba(99,102,241,0.3) inset"; }}}
            onMouseLeave={(e) => { if (!loading) { e.currentTarget.style.transform = "translateY(0)"; e.currentTarget.style.boxShadow = "0 8px 20px rgba(99,102,241,0.35), 0 0 0 1px rgba(99,102,241,0.2) inset"; }}}
          >{loading ? "Kayıt yapılıyor..." : "Kayıt Ol"}</button>
        </form>

        {/* Divider */}
        <div style={{ display: "flex", alignItems: "center", margin: "18px 0" }}>
          <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.06)" }} />
          <span style={{ padding: "0 12px", fontSize: 11, color: "rgba(241,245,249,0.4)", fontWeight: 500 }}>veya</span>
          <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.06)" }} />
        </div>

        {/* Google Button */}
        <button onClick={loginWithGoogle} style={{
          width: "100%", height: 42, borderRadius: 10,
          background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)",
          color: "#F1F5F9", cursor: "pointer", fontSize: 13, fontWeight: 600,
          fontFamily: "inherit", transition: "all 0.2s ease",
          display: "flex", justifyContent: "center", alignItems: "center", gap: 10,
        }}
          onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(255,255,255,0.07)"; e.currentTarget.style.borderColor = "rgba(255,255,255,0.14)"; }}
          onMouseLeave={(e) => { e.currentTarget.style.background = "rgba(255,255,255,0.04)"; e.currentTarget.style.borderColor = "rgba(255,255,255,0.08)"; }}
        >
          <svg width="14" height="14" viewBox="0 0 18 18">
            <path d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.875 2.684-6.615z" fill="#4285F4"/>
            <path d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332C2.438 15.983 5.482 18 9 18z" fill="#34A853"/>
            <path d="M3.964 10.71c-.18-.54-.282-1.117-.282-1.71s.102-1.17.282-1.71V4.958H.957C.347 6.173 0 7.548 0 9s.348 2.827.957 4.042l3.007-2.332z" fill="#FBBC05"/>
            <path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0 5.482 0 2.438 2.017.957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z" fill="#EA4335"/>
          </svg>
          Google ile Devam Et
        </button>

        {/* Footer */}
        <div style={{ textAlign: "center", marginTop: 18, fontSize: 12.5, color: "rgba(241,245,249,0.5)" }}>
          Zaten hesabın var mı?{" "}
          <button type="button" onClick={onSwitch} style={{ background: "none", border: "none", color: INDIGO_LIGHT, cursor: "pointer", fontWeight: 600, fontSize: 12.5, padding: 0, fontFamily: "inherit", transition: "color 0.15s" }}
            onMouseEnter={(e) => e.target.style.color = "#A5B4FC"}
            onMouseLeave={(e) => e.target.style.color = INDIGO_LIGHT}
          >Giriş Yap</button>
        </div>
      </div>
    </div>
  );
}
